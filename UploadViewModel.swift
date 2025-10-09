import SwiftUI
import PhotosUI

class UploadViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isAnalyzing = false
    @Published var errorMessage = ""
    @Published var predictions: [Prediction] = []
    @Published var annotatedImageBase64: String?
    @Published var showResults = false
    
    func selectImage(_ image: UIImage) {
        selectedImage = image
        errorMessage = ""
    }
    
    func analyzeImage(useRemote: Bool = true) {
        guard let image = selectedImage else {
            errorMessage = "Please select an image first"
            return
        }
        
        isAnalyzing = true
        errorMessage = ""
        
        if useRemote {
            analyzeWithAPI(image: image)
        } else {
            analyzeWithCoreML(image: image)
        }
    }
    
    private func analyzeWithAPI(image: UIImage) {
        APIClient.shared.predict(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                switch result {
                case .success(let response):
                    self?.predictions = response.boxes
                    self?.annotatedImageBase64 = response.annotatedImageBase64
                    self?.showResults = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func analyzeWithCoreML(image: UIImage) {
        CoreMLPredictor.shared.predict(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                switch result {
                case .success(let predictions):
                    self?.predictions = predictions
                    self?.showResults = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func reset() {
        selectedImage = nil
        predictions = []
        annotatedImageBase64 = nil
        showResults = false
        errorMessage = ""
    }
}
