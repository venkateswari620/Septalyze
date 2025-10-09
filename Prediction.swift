import Foundation

struct Prediction: Identifiable, Codable {
    let id = UUID()
    let cls: String
    let conf: Double
    let x1: Int
    let y1: Int
    let x2: Int
    let y2: Int
    
    var displayName: String {
        cls.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var confidencePercent: String {
        String(format: "%.0f%%", conf * 100)
    }
}

struct InferenceResponse: Codable {
    let boxes: [Prediction]
    let width: Int
    let height: Int
    let annotatedImageBase64: String?
    
    enum CodingKeys: String, CodingKey {
        case boxes, width, height
        case annotatedImageBase64 = "annotated_image_base64"
    }
}
