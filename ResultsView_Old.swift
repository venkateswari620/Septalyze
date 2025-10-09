import SwiftUI

struct ResultsView: View {
    let predictions: [Prediction]
    let image: UIImage?
    let annotatedImageBase64: String?
    let onDismiss: () -> Void
    
    @State private var annotatedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Title
                        Text("Analysis Results")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // Annotated Image
                        if let annotatedImage = annotatedImage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Annotated Scan")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Image(uiImage: annotatedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        } else if let image = image {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Original Scan")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Detections Summary
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Detections")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if predictions.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("No abnormalities detected")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                ForEach(predictions) { prediction in
                                    DetectionCard(prediction: prediction)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 15) {
                            Button(action: {
                                onDismiss()
                            }) {
                                Text("Upload New Scan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                shareResults()
                            }) {
                                Label("Share Results", systemImage: "square.and.arrow.up")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                onDismiss()
            })
        }
        .onAppear {
            loadAnnotatedImage()
        }
    }
    
    private func loadAnnotatedImage() {
        guard let base64String = annotatedImageBase64,
              let imageData = Data(base64Encoded: base64String),
              let image = UIImage(data: imageData) else {
            return
        }
        annotatedImage = image
    }
    
    private func shareResults() {
        // Implement share functionality
        guard let image = annotatedImage ?? image else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct DetectionCard: View {
    let prediction: Prediction
    
    var cardColor: Color {
        switch prediction.cls {
        case "bone_deviation":
            return .green
        case "air_pocket_left":
            return .orange
        case "air_pocket_right":
            return .red
        default:
            return .blue
        }
    }
    
    var body: some View {
        HStack {
            // Icon
            Circle()
                .fill(cardColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: iconName)
                        .foregroundColor(cardColor)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(prediction.displayName)
                    .font(.headline)
                
                Text("Confidence: \(prediction.confidencePercent)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Location: (\(prediction.x1), \(prediction.y1)) - (\(prediction.x2), \(prediction.y2))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Confidence Badge
            Text(prediction.confidencePercent)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(cardColor)
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    var iconName: String {
        switch prediction.cls {
        case "bone_deviation":
            return "arrow.left.and.right"
        case "air_pocket_left":
            return "arrow.left.circle.fill"
        case "air_pocket_right":
            return "arrow.right.circle.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

#Preview {
    ResultsView(
        predictions: [
            Prediction(cls: "bone_deviation", conf: 0.94, x1: 100, y1: 150, x2: 200, y2: 250),
            Prediction(cls: "air_pocket_left", conf: 0.88, x1: 50, y1: 100, x2: 120, y2: 180)
        ],
        image: nil,
        annotatedImageBase64: nil,
        onDismiss: {}
    )
}
