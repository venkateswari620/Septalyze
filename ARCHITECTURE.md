# System Architecture - Choncha Analyzer

## 🏛️ Complete System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FEDERATED LEARNING PHASE                        │
│                    (Privacy-Preserving Training)                    │
└─────────────────────────────────────────────────────────────────────┘

                         ┌──────────────────┐
                         │   FL Server      │
                         │   (fl_server.py) │
                         │                  │
                         │  FedAvg Strategy │
                         │  Aggregates      │
                         │  Model Weights   │
                         └────────┬─────────┘
                                  │
                    ┼─────────────┼─────────────┼
                    │             │             │
            ┌───────▼──────┐ ┌───▼──────┐ ┌───▼──────┐
            │   Client 1   │ │ Client 2 │ │ Client 3 │
            │ (Hospital A) │ │(Hospital B)│(Hospital C)│
            │              │ │           │ │          │
            │fl_client.py  │ │fl_client.py││fl_client.py│
            └──────┬───────┘ └─────┬─────┘└─────┬────┘
                   │               │            │
            ┌──────▼───────┐ ┌────▼─────┐ ┌────▼─────┐
            │  Local Data  │ │Local Data│ │Local Data│
            │  CT Scans    │ │ CT Scans │ │ CT Scans │
            │  + Labels    │ │ + Labels │ │ + Labels │
            └──────────────┘ └──────────┘ └──────────┘
                   ↑               ↑            ↑
                   └───────────────┴────────────┘
                   Data NEVER leaves hospital!

                         ┌──────────────────┐
                         │  Global Model    │
                         │  (global_model.pt)│
                         └────────┬─────────┘
                                  │
                         ┌────────▼─────────┐
                         │   export.py      │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
            ┌───────▼────────┐         ┌───────▼────────┐
            │  ONNX Format   │         │ CoreML Format  │
            │(.onnx)         │         │(.mlmodel)      │
            │Cross-platform  │         │iOS only        │
            └────────────────┘         └────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        INFERENCE PHASE                              │
│                    (Production Deployment)                          │
└─────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │    iOS App           │
                    │  (ChonchaAnalyzer)   │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │  IntroView     │  │
                    │  └───────┬────────┘  │
                    │          │           │
                    │  ┌───────▼────────┐  │
                    │  │ Login/SignUp   │  │
                    │  └───────┬────────┘  │
                    │          │           │
                    │  ┌───────▼────────┐  │
                    │  │  UploadView    │  │
                    │  │  (Camera/Lib)  │  │
                    │  └───────┬────────┘  │
                    │          │           │
                    └──────────┼───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Choose Inference:   │
                    └──────────┬───────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
        ┌───────▼────────┐           ┌───────▼────────┐
        │  Remote API    │           │  On-Device     │
        │  (APIClient)   │           │  (CoreML)      │
        └───────┬────────┘           └───────┬────────┘
                │                            │
        ┌───────▼────────┐           ┌───────▼────────┐
        │  FastAPI       │           │  Vision +      │
        │  Server        │           │  CoreML        │
        │                │           │  Framework     │
        │ infer_api/     │           └────────────────┘
        │ main.py        │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │  YOLOv8 Model  │
        │  Inference     │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │  Predictions   │
        │  + Annotated   │
        │  Image         │
        └───────┬────────┘
                │
                └──────────────┐
                               │
                    ┌──────────▼───────────┐
                    │    iOS App           │
                    │  ┌────────────────┐  │
                    │  │  ResultsView   │  │
                    │  │                │  │
                    │  │  • Bounding    │  │
                    │  │    Boxes       │  │
                    │  │  • Confidence  │  │
                    │  │  • Labels      │  │
                    │  └────────────────┘  │
                    └──────────────────────┘
```

## 🔄 Data Flow

### Training Flow (Federated Learning)

```
1. Server initializes global model
   ↓
2. Server broadcasts model to all clients
   ↓
3. Each client trains on LOCAL data
   ↓
4. Clients send ONLY weights back (not data!)
   ↓
5. Server aggregates weights (FedAvg)
   ↓
6. Repeat steps 2-5 for N rounds
   ↓
7. Final global model saved
```

### Inference Flow (iOS App)

```
User opens app
   ↓
Intro → Login/SignUp
   ↓
Upload CT scan (camera/library)
   ↓
Choose inference method:
   ├─→ Remote API
   │      ↓
   │   Send image to FastAPI
   │      ↓
   │   YOLOv8 inference
   │      ↓
   │   Return predictions + annotated image
   │
   └─→ On-Device CoreML
          ↓
       Vision framework processes image
          ↓
       CoreML model inference
          ↓
       Return predictions
   ↓
Display results with bounding boxes
```

## 📊 Component Responsibilities

### ML Components

| Component | Purpose | Input | Output |
|-----------|---------|-------|--------|
| `fl_server.py` | Aggregate model updates | Client weights | Global model |
| `fl_client.py` | Local training | CT images + labels | Updated weights |
| `train_local.py` | Standalone training | Dataset | Trained model |
| `export.py` | Model conversion | .pt weights | ONNX/CoreML |
| `infer_api/main.py` | Inference server | CT image | Predictions |

### iOS Components

| Component | Purpose | Responsibility |
|-----------|---------|----------------|
| `ChonchaAnalyzerApp.swift` | App entry | Navigation logic |
| `AuthViewModel` | Authentication | Login/signup state |
| `UploadViewModel` | Image handling | Upload & analysis |
| `APIClient` | Remote inference | HTTP requests |
| `CoreMLPredictor` | Local inference | On-device ML |
| `IntroView` | Onboarding | Welcome screen |
| `LoginView` | Auth UI | Login form |
| `SignUpView` | Auth UI | Registration |
| `UploadView` | Upload UI | Image picker |
| `ResultsView` | Results UI | Display detections |

## 🔐 Security & Privacy

### Federated Learning Privacy

```
Hospital A Data ──┐
                  │
Hospital B Data ──┼──→ [Encrypted Weights] ──→ Server
                  │                              (Aggregates)
Hospital C Data ──┘                                 │
                                                    ↓
                                              Global Model
                                              (No raw data!)
```

**Privacy Guarantees:**
- ✅ Raw CT scans never transmitted
- ✅ Only model parameters shared
- ✅ Differential privacy (optional)
- ✅ Secure aggregation (optional)

### API Security (Production)

```
iOS App ──→ [HTTPS/TLS] ──→ API Server
              │                  │
              │                  ↓
         [JWT Token]      [Authentication]
              │                  │
              ↓                  ↓
         [Encrypted]      [Rate Limiting]
              │                  │
              ↓                  ↓
         [Validated]      [Inference]
```

## 🎯 Detection Pipeline

### YOLOv8 Detection Process

```
Input Image (640x640)
       ↓
[Preprocessing]
  • Resize
  • Normalize
  • Tensor conversion
       ↓
[YOLOv8 Backbone]
  • Feature extraction
  • Multi-scale detection
       ↓
[Detection Head]
  • Bounding boxes
  • Class probabilities
  • Confidence scores
       ↓
[Post-processing]
  • NMS (Non-max suppression)
  • Confidence filtering
       ↓
Output Predictions
  • bone_deviation
  • air_pocket_left
  • air_pocket_right
```

### Bounding Box Format

```
Prediction {
  cls: "bone_deviation",
  conf: 0.94,
  x1: 100,  // Top-left X
  y1: 150,  // Top-left Y
  x2: 200,  // Bottom-right X
  y2: 250   // Bottom-right Y
}
```

## 🚀 Deployment Options

### Option 1: Cloud Deployment

```
┌─────────────┐
│   iOS App   │
└──────┬──────┘
       │ HTTPS
┌──────▼──────────────┐
│  Load Balancer      │
│  (AWS ALB/GCP LB)   │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  API Servers        │
│  (Auto-scaling)     │
│  • FastAPI          │
│  • YOLOv8 Model     │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Model Storage      │
│  (S3/GCS)           │
└─────────────────────┘
```

### Option 2: On-Premise

```
┌─────────────┐
│   iOS App   │
└──────┬──────┘
       │ VPN
┌──────▼──────────────┐
│  Hospital Server    │
│  • FastAPI          │
│  • YOLOv8 Model     │
│  • Local GPU        │
└─────────────────────┘
```

### Option 3: Hybrid

```
┌─────────────┐
│   iOS App   │
└──────┬──────┘
       │
       ├──→ [CoreML] (On-device)
       │
       └──→ [API] (Cloud/On-prem)
```

## 📈 Scalability

### Horizontal Scaling

```
                    ┌─────────────┐
                    │   Clients   │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │Load Balancer│
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐        ┌────▼────┐       ┌────▼────┐
   │ API     │        │ API     │       │ API     │
   │ Server 1│        │ Server 2│       │ Server 3│
   └─────────┘        └─────────┘       └─────────┘
```

### Model Versioning

```
┌─────────────────────────────────┐
│     Model Registry              │
│                                 │
│  • v1.0 (baseline)              │
│  • v1.1 (improved accuracy)     │
│  • v2.0 (new classes)           │
│  • v2.1 (federated update)      │
└─────────────────────────────────┘
         │
         ↓
   [A/B Testing]
         │
    ┌────┴────┐
    │         │
  [v1.1]   [v2.1]
    │         │
  [50%]    [50%]
```

## 🔧 Technology Stack Summary

```
┌─────────────────────────────────────────┐
│           Frontend (iOS)                │
│  • Swift 5.9+                           │
│  • SwiftUI                              │
│  • Alamofire (networking)               │
│  • Vision + CoreML (on-device ML)       │
└─────────────────────────────────────────┘
                    │
                    ↓
┌─────────────────────────────────────────┐
│           Backend (API)                 │
│  • FastAPI (Python)                     │
│  • Uvicorn (ASGI server)                │
│  • Pydantic (validation)                │
└─────────────────────────────────────────┘
                    │
                    ↓
┌─────────────────────────────────────────┐
│         ML Framework                    │
│  • PyTorch 2.0+                         │
│  • Ultralytics YOLOv8                   │
│  • Flower (Federated Learning)          │
│  • ONNX/CoreML (export)                 │
└─────────────────────────────────────────┘
```

## 📝 File Dependencies

```
ChonchaAnalyzerApp.swift
    ├── AuthViewModel.swift
    │   └── (manages auth state)
    │
    ├── IntroView.swift
    │   └── uses AuthViewModel
    │
    ├── LoginView.swift
    │   └── uses AuthViewModel
    │
    ├── SignUpView.swift
    │   └── uses AuthViewModel
    │
    └── UploadView.swift
        ├── uses UploadViewModel
        │   ├── APIClient.swift
        │   │   └── Prediction.swift
        │   └── CoreMLPredictor.swift
        │       └── Prediction.swift
        │
        └── ResultsView.swift
            └── uses Prediction.swift
```

## 🎯 Success Metrics

### Training Metrics
- **mAP@50**: Mean Average Precision at IoU 0.5
- **mAP@50-95**: Mean Average Precision at IoU 0.5-0.95
- **Precision**: True positives / (True positives + False positives)
- **Recall**: True positives / (True positives + False negatives)

### Inference Metrics
- **Latency**: Time from upload to results
- **Throughput**: Requests per second
- **Accuracy**: Detection accuracy on test set

### User Metrics
- **Upload Success Rate**: % successful uploads
- **Analysis Completion**: % completed analyses
- **User Satisfaction**: Feedback scores

---

**This architecture supports:**
- ✅ Privacy-preserving training (FL)
- ✅ Scalable inference (API)
- ✅ Offline capability (CoreML)
- ✅ Multi-hospital collaboration
- ✅ Production deployment
