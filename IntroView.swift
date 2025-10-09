import SwiftUI

struct IntroView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                
                // Title
                Text("Choncha Analyzer")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                // Description
                Text("AI-powered CT scan analysis for detecting concha bullosa, bone deviation, and air pockets")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    authViewModel.completeIntro()
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    IntroView()
        .environmentObject(AuthViewModel())
}
