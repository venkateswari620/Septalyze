import Foundation
import UIKit
import Alamofire

class APIClient {
    static let shared = APIClient()
    
    // Update this to your server URL
    // Use localhost:8000 for Simulator, or your Mac's IP for real device
    private let baseURL = "http://10.198.222.141:8000"  // Your Mac's IP
    
    private init() {}
    
    func predict(image: UIImage, completion: @escaping (Result<InferenceResponse, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "APIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        
        let url = "\(baseURL)/infer"
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image", fileName: "scan.jpg", mimeType: "image/jpeg")
            },
            to: url
        )
        .validate()
        .responseDecodable(of: InferenceResponse.self) { response in
            switch response.result {
            case .success(let inferenceResponse):
                completion(.success(inferenceResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
