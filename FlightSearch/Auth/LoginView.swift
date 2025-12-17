import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    // This state would typically be managed by a higher-level coordinator or view router
    @State private var didLoginSuccessfully = false

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 16) {
                Spacer()
                
                Text("FlightSearch")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .padding(.bottom, 30)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }
                
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
                
                Spacer()
                Spacer()
            }
            .padding()
            .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    // In a real app, a coordinator would handle this navigation.
                    // Using a fullScreenCover for demonstration.
                    self.didLoginSuccessfully = true
                }
            }
            .fullScreenCover(isPresented: $didLoginSuccessfully) {
                // Placeholder for the main app view after successful login
                Text("Welcome! You are logged in.")
            }

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
