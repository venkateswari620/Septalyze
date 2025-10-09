import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasSeenIntro = false
    @Published var showSignUp = false
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func completeIntro() {
        hasSeenIntro = true
    }
    
    func toggleSignUp() {
        showSignUp.toggle()
        errorMessage = ""
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate login (replace with real auth)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            if self.email.contains("@") {
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Invalid email or password"
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Invalid email format"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate sign up (replace with real auth)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        isAuthenticated = false
        email = ""
        password = ""
        confirmPassword = ""
    }
}
