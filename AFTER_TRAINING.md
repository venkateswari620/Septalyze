# After Training - Next Steps

## 1. Extract Trained Model

After downloading `trained_model.zip` from Google Colab:

```bash
cd /Users/sail/Desktop/cb
unzip trained_model.zip
cp runs/concha_train/weights/best.pt global_model.pt
```

## 2. Start Inference API

```bash
python3 ml/infer_api/main.py --model global_model.pt --port 8000
```

Test it:
```bash
curl -X POST http://localhost:8000/infer -F "image=@test/images/sample.jpg"
```

## 3. Export to CoreML (for iOS on-device)

On macOS:
```bash
python3 ml/export.py --weights global_model.pt --imgsz 640
```

This creates `global_model.mlmodel` for iOS.

## 4. Build iOS App

Follow `ios/SETUP.md`:

1. Open Xcode
2. Create new iOS App project: **ChonchaAnalyzer**
3. Copy files from `ios/ChonchaAnalyzer/` to project
4. Add Alamofire package
5. Update API endpoint in `APIClient.swift`:
   ```swift
   private let baseURL = "http://localhost:8000"
   ```
6. (Optional) Drag `global_model.mlmodel` into Xcode for on-device inference
7. Build & Run!

## 5. Test the Complete System

1. **API Server**: Running on port 8000
2. **iOS App**: Running in simulator/device
3. **Upload CT scan** → Get predictions with bounding boxes

## Troubleshooting

**API not connecting:**
- Ensure server is running
- For device testing, use Mac's IP instead of localhost
- Check firewall allows port 8000

**Model not loading:**
- Verify `global_model.pt` exists
- Check file path in API server

**iOS build errors:**
- Clean build folder (Cmd+Shift+K)
- Reset package caches

---

**You're all set!** 🎉
