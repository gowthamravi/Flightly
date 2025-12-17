import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Log in to continue your journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $viewModel.username)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: viewModel.login) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoginButtonDisabled)
                .opacity(viewModel.isLoginButtonDisabled ? 0.6 : 1.0)
                
                Spacer()
                Spacer()
                
                // Placeholder for successful navigation
                if viewModel.isAuthenticated {
                    Text("Login Successful! Navigating...")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .navigationTitle("Login")
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
