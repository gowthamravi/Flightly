import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoginSuccessful = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("AppLogo") // Assuming you have an app logo image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 40)

                TextField("Email Address", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Login") {
                    loginUser()
                }
                .buttonStyle(PrimaryButtonStyle()) // Assuming a custom button style
                .disabled(email.isEmpty || password.isEmpty)

                HStack {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)

                Spacer()

                Text("Or continue with:")
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "globe") // Placeholder for Google
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            // Handle Google sign-in
                        }

                    Image(systemName: "applelogo") // Placeholder for Apple
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .onTapGesture {
                            // Handle Apple sign-in
                        }
                }
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationBarHidden(true) // Hides the default navigation bar for a cleaner look
            .alert(isPresented: $showError) {
                Alert(title: Text("Login Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isLoginSuccessful) {
                // Navigate to the next view after successful login
                // Replace FlightSearchView() with your actual next view
                FlightSearchView()
            }
        }
    }

    func loginUser() {
        // Basic validation - in a real app, this would involve API calls
        if isValidEmail(email) && password.count >= 8 {
            // Simulate a successful login
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate network delay
                isLoginSuccessful = true
            }
        } else {
            if !isValidEmail(email) {
                errorMessage = "Please enter a valid email address."
            } else if password.count < 8 {
                errorMessage = "Password must be at least 8 characters long."
            }
            showError = true
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        // Simple email validation regex
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

// Custom Button Style (Example)
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
