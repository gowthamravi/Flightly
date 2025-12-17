import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var loginSuccessful: Bool = false

    init(viewModel: LoginViewModel = LoginViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(BrandColor.primary)

                Text("Flightly")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
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
                }

                loginButton

                Button("Forgot Password?") {
                    // Handle forgot password action
                }
                .font(.subheadline)
                .foregroundColor(BrandColor.primary)

                Spacer()

                guestAndSignUpFooter
            }
            .padding()
            .navigationDestination(isPresented: $loginSuccessful) {
                // Navigate to the main app view upon successful login
                MainView()
            }
            .onChange(of: viewModel.loginSuccessful) {
                if viewModel.loginSuccessful {
                    loginSuccessful = true
                }
            }
        }
    }

    private var loginButton: some View {
        Button(action: {
            Task {
                await viewModel.login()
            }
        }) {
            HStack {
                if viewModel.isLoggingIn {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Login")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(BrandColor.primary)
            .cornerRadius(10)
        }
        .disabled(viewModel.isLoginDisabled)
        .opacity(viewModel.isLoginDisabled ? 0.6 : 1.0)
    }

    private var guestAndSignUpFooter: some View {
        VStack(spacing: 15) {
            NavigationLink(destination: GuestView()) {
                 Text("Continue as Guest")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(BrandColor.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(BrandColor.primary, lineWidth: 1)
                    )
            }

            HStack {
                Text("Don't have an account?")
                Button("Sign Up") {
                    // Handle sign up navigation
                }
                .foregroundColor(BrandColor.primary)
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
