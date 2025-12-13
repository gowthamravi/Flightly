import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordSecure = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToMainView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("appLogo") // Replace with your actual app logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 50)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                HStack {
                    if isPasswordSecure {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                HStack {
                    Spacer()
                    Button(isPasswordSecure ? "Show" : "Hide") {
                        isPasswordSecure.toggle()
                    }
                    .foregroundColor(.blue)
                }

                Button("Login") {
                    loginTapped()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Forgot Password?") {
                    // Action for forgot password
                }
                .foregroundColor(.blue)

                Spacer()

                NavigationLink(destination: MainView(), isActive: $navigateToMainView) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
        }
    }

    private func loginTapped() {
        // Basic validation (can be expanded)
        if email.isEmpty || password.isEmpty {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        // Simulate login attempt
        // In a real app, this would involve API calls
        if isValidEmail(email) {
            // Simulate successful login
            navigateToMainView = true
        } else {
            alertMessage = "Invalid email format."
            showAlert = true
        }
    }
    
    // Basic email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailPredicate.evaluate(with: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
