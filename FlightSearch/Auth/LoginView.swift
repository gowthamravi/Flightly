import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isAuthenticated {
                    Text("Login Successful!")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .onAppear {
                            // In a real app, trigger navigation to the main content view here.
                        }
                } else {
                    loginForm
                }
            }
            .navigationTitle("Login")
            .padding()
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 24) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
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
            
            if viewModel.isLoading {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            } else {
                loginButton
            }
            
            Spacer()
            
            registrationLink
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            viewModel.login()
        }) {
            Text("Login")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoginButtonDisabled ? Color.gray : Color.blue)
                .cornerRadius(8)
        }
        .disabled(viewModel.isLoginButtonDisabled)
    }
    
    private var registrationLink: some View {
        HStack {
            Text("Don't have an account?")
            Button(action: {
                // TODO: Handle navigation to registration screen
            }) {
                Text("Register")
                    .fontWeight(.semibold)
            }
        }
        .font(.footnote)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
