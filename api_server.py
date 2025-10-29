#!/usr/bin/env python3
"""
Standalone FastAPI Inference Server for YOLOv8 Concha Analyzer
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from ultralytics import YOLO
import cv2
import numpy as np
import base64
from pydantic import BaseModel
from typing import List
import argparse
import uvicorn


# Pydantic models
class Box(BaseModel):
    cls: str
    conf: float
    x1: int
    y1: int
    x2: int
    y2: int


class InferenceResponse(BaseModel):
    boxes: List[Box]
    width: int
    height: int
    annotated_image_base64: str


app = FastAPI(title="Concha Analyzer API")

# Global model instance
model = None
MODEL_PATH = "global_model.pt"


def draw_boxes(img, boxes, names):
    """Draw bounding boxes on image"""
    annotated = img.copy()
    
    for box in boxes:
        x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
        cls_id = int(box.cls[0].item())
        conf = float(box.conf[0].item())
        cls_name = names[cls_id]
        
        # Draw rectangle
        color = (0, 255, 0)  # Green
        cv2.rectangle(annotated, (x1, y1), (x2, y2), color, 2)
        
        # Draw label
        label = f"{cls_name} {conf:.2f}"
        (w, h), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        cv2.rectangle(annotated, (x1, y1 - h - 10), (x1 + w, y1), color, -1)
        cv2.putText(annotated, label, (x1, y1 - 5), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1)
    
    return annotated


@app.on_event("startup")
async def load_model():
    global model
    print(f"🔄 Loading model from {MODEL_PATH}")
    model = YOLO(MODEL_PATH)
    print("✅ Model loaded successfully")


@app.get("/")
async def root():
    return {"message": "Concha Analyzer API", "status": "running", "model": MODEL_PATH}


@app.get("/health")
async def health():
    return {"status": "healthy", "model_loaded": model is not None}


@app.post("/infer", response_model=InferenceResponse)
async def infer(image: UploadFile = File(...)):
    """
    Perform inference on uploaded CT scan image
    Returns bounding boxes and annotated image
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        # Read image
        contents = await image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format")
        
        # Run inference with balanced confidence threshold
        # conf=0.35 balances between detecting abnormalities and avoiding false positives
        # iou=0.45 removes duplicate detections
        results = model(img, verbose=False, conf=0.35, iou=0.45)[0]
        
        # Extract boxes
        boxes = []
        print(f"🔍 Total detections: {len(results.boxes)}")
        
        # Check if no abnormalities detected
        if len(results.boxes) == 0:
            print("  ✓ No abnormalities detected - Image is NORMAL")
            # Add a "Normal" detection with full image bounds
            boxes.append(Box(
                cls="Normal",
                conf=1.0,
                x1=0, y1=0, 
                x2=img.shape[1], y2=img.shape[0]
            ))
        else:
            # Process detected abnormalities
            for box in results.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                cls_id = int(box.cls[0].item())
                conf = float(box.conf[0].item())
                cls_name = results.names[cls_id]
                
                print(f"  ✓ Detected: {cls_name} (confidence: {conf:.2f})")
                
                boxes.append(Box(
                    cls=cls_name,
                    conf=conf,
                    x1=x1, y1=y1, x2=x2, y2=y2
                ))
        
        # Draw annotations
        annotated_img = draw_boxes(img, results.boxes, results.names)
        
        # If normal, add text overlay
        if len(results.boxes) == 0:
            # Add "NORMAL" text to image
            h, w = img.shape[:2]
            cv2.putText(annotated_img, "NORMAL - No Abnormalities Detected", 
                       (int(w*0.1), int(h*0.5)), 
                       cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 255, 0), 3)
        
        # Encode to base64
        _, buffer = cv2.imencode('.jpg', annotated_img)
        img_base64 = base64.b64encode(buffer).decode('utf-8')
        
        return InferenceResponse(
            boxes=boxes,
            width=img.shape[1],
            height=img.shape[0],
            annotated_image_base64=img_base64
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=str, default="global_model.pt", help="Path to model weights")
    parser.add_argument("--host", type=str, default="0.0.0.0", help="Host to bind to")
    parser.add_argument("--port", type=int, default=8000, help="Port to bind to")
    args = parser.parse_args()
    
    MODEL_PATH = args.model
    
    print(f"""
╔══════════════════════════════════════════════════════════╗
║         Concha Analyzer API Server                      ║
╚══════════════════════════════════════════════════════════╝

📦 Model: {MODEL_PATH}
🌐 Host: {args.host}:{args.port}
🔗 API Docs: http://localhost:{args.port}/docs

Starting server...
""")
    
    uvicorn.run(app, host=args.host, port=args.port)
