import SwiftUI
import AuthenticationServices // For Sign in with Apple

// Assuming ActivityIndicator is defined in FlightSearch/Extensions/ActivityIndicator.swift
// and is a SwiftUI View.
struct ActivityIndicator: View {
    var isAnimating: Bool
    var style: UIActivityIndicatorView.Style = .medium

    var body: some View {
        if isAnimating {
            // Using a simple Text here to avoid direct UIKit in this example if the original isn't accessible.
            // In a real app, use UIActivityIndicatorView wrapped in UIViewRepresentable or an actual SwiftUI spinner.
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.colorScheme) var colorScheme // For Apple button styling
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    appLogo
                    
                    emailInput
                    
                    passwordInput
                    
                    forgotPasswordButton
                    
                    primaryLoginButton
                    
                    socialLoginDivider
                    
                    socialLoginButtons
                }
                .padding()
                .alert("Login Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK") { viewModel.errorMessage = nil }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .alert("Login Successful", isPresented: $viewModel.showLoginSuccessAlert) {
                    Button("OK") { viewModel.showLoginSuccessAlert = false }
                } message: {
                    Text("You have successfully logged in!")
                }
                .disabled(viewModel.isLoading) // Disable interaction when loading
            }
            .navigationTitle("") // Hide default navigation title
            .navigationBarHidden(true) // Hide navigation bar completely
            .overlay(alignment: .center) { // Show activity indicator over the whole view
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ActivityIndicator(isAnimating: true)
                }
            }
        }
    }
    
    // MARK: - UI Components
    private var appLogo: some View {
        Image("AppLogoPlaceholder") // Use your actual App Logo asset name
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .padding(.bottom, 20)
    }
    
    private var emailInput: some View {
        VStack(alignment: .leading) {
            TextField("Email address", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let message = viewModel.emailValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var passwordInput: some View {
        SecureField("Password", text: $viewModel.password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
    
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button("Forgot Password?") {
                viewModel.forgotPassword()
            }
            .font(.footnote)
            .padding(.trailing)
        }
    }
    
    private var primaryLoginButton: some View {
        Button(action: {
            Task { await viewModel.loginWithEmailPassword() }
        }) {
            Text("Log In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoginButtonDisabled ? Color.gray : Color.blue) // Brand color
                .cornerRadius(10)
        }
        .disabled(viewModel.isLoginButtonDisabled)
        .padding(.horizontal)
    }
    
    private var socialLoginDivider: some View {
        HStack {
            VStack { Divider() }.padding(.leading)
            Text("Or continue with")
                .font(.caption)
                .foregroundColor(.secondary)
            VStack { Divider() }.padding(.trailing)
        }
        .padding(.vertical)
    }
    
    private var socialLoginButtons: some View {
        VStack(spacing: 15) {
            // Sign in with Apple Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            Task { @MainActor in
                                await viewModel.signInWithApple(credential: appleIDCredential)
                            }
                        }
                    case .failure(let error):
                        // Error handled by AuthViewModel's `authorizationController(didCompleteWithError:)`
                        // For SwiftUI wrapper, we can also set the error here directly if needed.
                        viewModel.isLoading = false // Ensure loading is reset
                        viewModel.errorMessage = AuthError.appleSignInError(error).errorDescription
                    }
                }
            )
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(height: 50)
            .padding(.horizontal)
            
            // Sign in with Google Button (Custom)
            Button(action: {
                Task { await viewModel.signInWithGoogle() }
            }) {
                HStack {
                    Image("GoogleGLogo") // Assuming you have a 'GoogleGLogo' asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.horizontal)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

// MARK: - Placeholder for App Logo and Google Logo assets
// In a real project, these would be added to your Assets.xcassets.
// For preview purposes, you can create dummy assets or omit the images if they cause build errors.
// Example usage in Assets.xcassets:
// - AppLogoPlaceholder (Image Set)
// - GoogleGLogo (Image Set)
