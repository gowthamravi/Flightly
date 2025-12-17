import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    
    // This closure would be used by a coordinator or parent view to dismiss the login screen
    var onLoginSuccess: () -> Void

    init(viewModel: LoginViewModel = LoginViewModel(), onLoginSuccess: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLoginSuccess = onLoginSuccess
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button(action: viewModel.login) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isLoginButtonDisabled ? Color.gray : Color.blue)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isLoginButtonDisabled)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    Button("Sign Up") {
                        // TODO: Handle sign up navigation
                    }
                }
                .font(.footnote)

            }
            .padding()
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    onLoginSuccess()
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onLoginSuccess: {
            print("Login successful!")
        })
    }
}
