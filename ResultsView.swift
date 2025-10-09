import SwiftUI

struct PatientInfo {
    var name: String = ""
    var age: String = ""
    var gender: String = "Male"
    var patientID: String = ""
    var scanDate: Date = Date()
    var referringDoctor: String = ""
    var notes: String = ""
}

struct ResultsView: View {
    let predictions: [Prediction]
    let image: UIImage?
    let annotatedImageBase64: String?
    let onDismiss: () -> Void
    
    @State private var annotatedImage: UIImage?
    @State private var showPatientForm = false
    @State private var patientInfo = PatientInfo()
    
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
                            
                            if predictions.isEmpty || predictions.first?.cls == "Normal" {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("No Abnormalities Detected")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Scan appears normal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
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
                                showPatientForm = true
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
            .sheet(isPresented: $showPatientForm) {
                PatientInfoSheet(
                    patientInfo: $patientInfo,
                    predictions: predictions,
                    image: annotatedImage ?? image,
                    onShare: { shareResultsWithPatientInfo() }
                )
            }
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
    
    private func shareResultsWithPatientInfo() {
        let reportText = generateReport()
        let itemsToShare: [Any] = [reportText] + (annotatedImage != nil ? [annotatedImage!] : [])
        
        let activityVC = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func generateReport() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var report = """
        ═══════════════════════════════════════
        CT SCAN ANALYSIS REPORT
        ═══════════════════════════════════════
        
        PATIENT INFORMATION:
        Name: \(patientInfo.name.isEmpty ? "N/A" : patientInfo.name)
        Age: \(patientInfo.age.isEmpty ? "N/A" : patientInfo.age)
        Gender: \(patientInfo.gender)
        Patient ID: \(patientInfo.patientID.isEmpty ? "N/A" : patientInfo.patientID)
        Scan Date: \(dateFormatter.string(from: patientInfo.scanDate))
        Referring Doctor: \(patientInfo.referringDoctor.isEmpty ? "N/A" : patientInfo.referringDoctor)
        
        ═══════════════════════════════════════
        ANALYSIS RESULTS:
        ═══════════════════════════════════════
        
        """
        
        if predictions.isEmpty || predictions.first?.cls == "Normal" {
            report += "✓ NO ABNORMALITIES DETECTED\n"
            report += "  The scan appears normal with no significant findings.\n\n"
        } else {
            report += "DETECTED ABNORMALITIES:\n\n"
            for (index, prediction) in predictions.enumerated() {
                report += "\(index + 1). \(prediction.displayName)\n"
                report += "   Confidence: \(prediction.confidencePercent)\n"
                report += "   Location: (\(prediction.x1), \(prediction.y1)) - (\(prediction.x2), \(prediction.y2))\n\n"
            }
        }
        
        if !patientInfo.notes.isEmpty {
            report += "═══════════════════════════════════════\n"
            report += "ADDITIONAL NOTES:\n"
            report += "\(patientInfo.notes)\n\n"
        }
        
        report += """
        ═══════════════════════════════════════
        DISCLAIMER:
        This is an AI-assisted analysis tool.
        Results should be verified by a qualified
        medical professional before making any
        clinical decisions.
        ═══════════════════════════════════════
        
        Generated by Concha Analyzer
        """
        
        return report
    }
}

struct PatientInfoSheet: View {
    @Binding var patientInfo: PatientInfo
    let predictions: [Prediction]
    let image: UIImage?
    let onShare: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Patient Details")) {
                    TextField("Patient Name", text: $patientInfo.name)
                    TextField("Age", text: $patientInfo.age)
                        .keyboardType(.numberPad)
                    
                    Picker("Gender", selection: $patientInfo.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    
                    TextField("Patient ID", text: $patientInfo.patientID)
                }
                
                Section(header: Text("Scan Information")) {
                    DatePicker("Scan Date", selection: $patientInfo.scanDate, displayedComponents: .date)
                    TextField("Referring Doctor", text: $patientInfo.referringDoctor)
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $patientInfo.notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        dismiss()
                        onShare()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Report")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Patient Information")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct DetectionCard: View {
    let prediction: Prediction
    
    var cardColor: Color {
        if prediction.cls == "Normal" {
            return .green
        }
        switch prediction.cls.lowercased() {
        case let cls where cls.contains("deviated"):
            return .orange
        case let cls where cls.contains("cb"):
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
                
                if prediction.cls != "Normal" {
                    Text("Location: (\(prediction.x1), \(prediction.y1)) - (\(prediction.x2), \(prediction.y2))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
        if prediction.cls == "Normal" {
            return "checkmark.circle.fill"
        }
        switch prediction.cls.lowercased() {
        case let cls where cls.contains("left") && cls.contains("deviated"):
            return "arrow.left"
        case let cls where cls.contains("right") && cls.contains("deviated"):
            return "arrow.right"
        case let cls where cls.contains("left") && cls.contains("cb"):
            return "circle.lefthalf.filled"
        case let cls where cls.contains("right") && cls.contains("cb"):
            return "circle.righthalf.filled"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}
