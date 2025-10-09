import SwiftUI
import PhotosUI

struct UploadView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var uploadViewModel = UploadViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    Text("Upload CT Scan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    // Image Preview
                    if let image = uploadViewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                
                                Text("No image selected")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upload Buttons
                    HStack(spacing: 15) {
                        Button(action: {
                            imagePickerSourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            Label("Photo Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            imagePickerSourceType = .camera
                            showCamera = true
                        }) {
                            Label("Camera", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if !uploadViewModel.errorMessage.isEmpty {
                        Text(uploadViewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Analyze Button
                    Button(action: {
                        uploadViewModel.analyzeImage(useRemote: true)
                    }) {
                        if uploadViewModel.isAnalyzing {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Analyzing...")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            Text("Submit for Analysis")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(uploadViewModel.selectedImage != nil ? Color.green : Color.gray)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(uploadViewModel.selectedImage == nil || uploadViewModel.isAnalyzing)
                    
                    Spacer()
                }
                .navigationBarItems(trailing: Button("Logout") {
                    authViewModel.logout()
                })
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $uploadViewModel.selectedImage, sourceType: imagePickerSourceType)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $uploadViewModel.selectedImage, sourceType: .camera)
        }
        .fullScreenCover(isPresented: $uploadViewModel.showResults) {
            ResultsView(
                predictions: uploadViewModel.predictions,
                image: uploadViewModel.selectedImage,
                annotatedImageBase64: uploadViewModel.annotatedImageBase64
            ) {
                uploadViewModel.reset()
            }
        }
    }
}

// Image Picker Helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    UploadView()
        .environmentObject(AuthViewModel())
}
