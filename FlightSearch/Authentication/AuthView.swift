import SwiftUI
import AuthenticationServices // Required for ASAuthorizationAppleIDButton

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.colorScheme) var colorScheme // For adaptive Apple Sign-In button style

    var body: some View {
        NavigationView { // Embed in NavigationView for potential navigation bar or presentation
            ScrollView {
                VStack(spacing: 20) {
                    Image("AppLogo") // Assuming 'AppLogo' asset exists in Assets.xcassets
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .padding(.top, 50)
                        .accessibilityLabel("App Logo")

                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 15) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.email.isEmpty || viewModel.email.isValidEmail ? Color.clear : Color.red,
                                        lineWidth: 1
                                    )
                            )
                            .accessibilityIdentifier("EmailTextField")

                        if !viewModel.email.isEmpty && !viewModel.email.isValidEmail {
                            Text("Invalid email format")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }

                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .accessibilityIdentifier("PasswordSecureField")

                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // TODO: Implement navigation or action for forgot password
                                print("Forgot password tapped")
                            }
                            .font(.subheadline)
                            .foregroundColor(.accentColor) // Use app's accent color or brand color
                            .accessibilityIdentifier("ForgotPasswordButton")
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        viewModel.login()
                    } label: {
                        if viewModel.isLoading { // Show activity indicator when loading
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentColor.opacity(0.8)) // Slightly darker when loading
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text("Log In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(viewModel.isLoginButtonDisabled ? Color(.systemGray4) : Color.accentColor) // Disabled state color
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.isLoginButtonDisabled)
                    .padding(.horizontal)
                    .accessibilityIdentifier("LoginButton")

                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray3))
                        Text("Or continue with")
                            .font(.caption)
                            .foregroundColor(Color(.systemGray))
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray3))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    VStack(spacing: 15) {
                        // Sign in with Apple Button
                        SignInWithAppleButtonView(
                            type: ASAuthorizationAppleIDButton.ButtonType.signIn,
                            style: colorScheme == .dark ? ASAuthorizationAppleIDButton.Style.white : ASAuthorizationAppleIDButton.Style.black, // Adaptive style based on system theme
                            onCompletion: viewModel.handleAppleSignIn
                        )
                        .frame(height: 50) // Standard height for social login buttons
                        .padding(.horizontal)
                        .cornerRadius(10) // Match other button styles
                        .accessibilityIdentifier("AppleSignInButton")

                        // Sign in with Google Button
                        Button {
                            viewModel.handleGoogleSignIn()
                        } label: {
                            HStack {
                                Image("google_logo") // Assuming 'google_logo' asset exists
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24) // Google logo size
                                Text("Sign in with Google")
                                    .font(.headline)
                                    .foregroundColor(.black) // Google button text is typically black
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1) // Light gray border
                            )
                        }
                        .padding(.horizontal)
                        .accessibilityIdentifier("GoogleSignInButton")
                    }

                    Spacer()
                }
            }
            .alert("Login Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } } // Clear error message when alert is dismissed
            )) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

// MARK: - UIViewRepresentable for ASAuthorizationAppleIDButton
// This wrapper is necessary to use UIKit's ASAuthorizationAppleIDButton in SwiftUI.
struct SignInWithAppleButtonView: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton
    var type: ASAuthorizationAppleIDButton.ButtonType
    var style: ASAuthorizationAppleIDButton.Style
    var onCompletion: (ASAuthorization?, Error?) -> Void // Callback for authorization result

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // Update button style if needed (e.g., if colorScheme changes dynamically after init)
        // uiView.authorizationButtonStyle = style
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onCompletion: onCompletion)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleButtonView
        var onCompletion: (ASAuthorization?, Error?) -> Void

        init(_ parent: SignInWithAppleButtonView, onCompletion: @escaping (ASAuthorization?, Error?) -> Void) {
            self.parent = parent
            self.onCompletion = onCompletion
        }

        @objc func didTapButton() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email] // Request user's full name and email

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        // MARK: - ASAuthorizationControllerDelegate
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            onCompletion(authorization, nil)
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onCompletion(nil, error)
        }

        // MARK: - ASAuthorizationControllerPresentationContextProviding
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // Use the first window of the active scene for the presentation context
            guard let window = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?.windows
                .first else { fatalError("No active window for Apple Sign-In presentation.") }
            return window
        }
    }
}
