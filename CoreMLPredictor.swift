import Foundation
import UIKit
import Vision
import CoreML

class CoreMLPredictor {
    static let shared = CoreMLPredictor()
    
    private var model: VNCoreMLModel?
    
    private init() {
        loadModel()
    }
    
    private func loadModel() {
        // Replace with your actual CoreML model name
        // Example: if you have ConchaAnalyzer.mlmodel
        /*
        guard let modelURL = Bundle.main.url(forResource: "ConchaAnalyzer", withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: modelURL),
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            print("Failed to load CoreML model")
            return
        }
        self.model = visionModel
        */
    }
    
    func predict(image: UIImage, completion: @escaping (Result<[Prediction], Error>) -> Void) {
        guard let model = model else {
            completion(.failure(NSError(domain: "CoreMLPredictor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded. Use API inference instead."])))
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            completion(.failure(NSError(domain: "CoreMLPredictor", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion(.failure(NSError(domain: "CoreMLPredictor", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid results"])))
                return
            }
            
            let predictions = results.map { observation -> Prediction in
                let bbox = observation.boundingBox
                let imageWidth = Int(image.size.width)
                let imageHeight = Int(image.size.height)
                
                // Convert normalized coordinates to pixel coordinates
                let x1 = Int(bbox.minX * CGFloat(imageWidth))
                let y1 = Int((1 - bbox.maxY) * CGFloat(imageHeight))
                let x2 = Int(bbox.maxX * CGFloat(imageWidth))
                let y2 = Int((1 - bbox.minY) * CGFloat(imageHeight))
                
                return Prediction(
                    cls: observation.labels.first?.identifier ?? "unknown",
                    conf: Double(observation.confidence),
                    x1: x1, y1: y1, x2: x2, y2: y2
                )
            }
            
            completion(.success(predictions))
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}
