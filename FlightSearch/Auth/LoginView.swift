import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel? = nil) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            // Create the default ViewModel on the main actor to satisfy actor isolation
            let defaultVM: LoginViewModel = {
                if Thread.isMainThread {
                    return LoginViewModel(authService: MockAuthenticationService())
                } else {
                    // If somehow not on main, synchronously hop to main
                    return DispatchQueue.main.sync {
                        LoginViewModel(authService: MockAuthenticationService())
                    }
                }
            }()
            _viewModel = StateObject(wrappedValue: defaultVM)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    headerView
                    
                    emailField
                    
                    passwordField
                    
                    if let errorMessage = viewModel.errorMessage {
                        errorTextView(message: errorMessage)
                    }
                    
                    loginButton
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Login")
                .navigationBarTitleDisplayMode(.inline)
                
                // Loading overlay
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            // In a real app, this would be handled by a coordinator or root view
            // to navigate to the main content after successful login.
            .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
                Text("Welcome! You are logged in.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Welcome Back")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.vertical, 20)
    }
    
    private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
    
    private func errorTextView(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
    
    private var loginButton: some View {
        Button(action: viewModel.login) {
            Text("Login")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(viewModel.isLoginButtonDisabled ? Color.gray : Color.blue)
                .cornerRadius(10)
        }
        .disabled(viewModel.isLoginButtonDisabled)
        .padding(.top, 10)
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                ProgressView("Logging In...")
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .tint(.primary)
            }
    }
}
