import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isPasswordObscured = true

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("AppIcon") // Replace with your actual app icon asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 40)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .accessibilityLabel("Username text field")

                HStack {
                    if isPasswordObscured {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityLabel("Password secure text field")
                    } else {
                        TextField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityLabel("Password text field")
                    }

                    Button(action: {
                        isPasswordObscured.toggle()
                    }) {
                        Image(systemName: isPasswordObscured ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel(isPasswordObscured ? "Show password button" : "Hide password button")
                }

                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        Image(systemName: rememberMe ? "checkmark.square" : "square")
                            .foregroundColor(rememberMe ? .blue : .gray)
                    }
                    .accessibilityLabel("Remember me toggle button")
                    Text("Remember Me")
                        .font(.caption)
                    Spacer()
                }

                Button("Login") {
                    // TODO: Implement login logic
                    print("Username: \(username)")
                    print("Password: \(password)")
                    print("Remember Me: \(rememberMe)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .accessibilityLabel("Login button")
                
                Button("Forgot Password?") {
                    // TODO: Implement forgot password logic
                }
                .foregroundColor(.blue)
                .accessibilityLabel("Forgot password button")

                Spacer()

                Button("Continue as Guest") {
                    // TODO: Implement continue as guest logic
                }
                .padding(.bottom)
                .foregroundColor(.blue)
                .accessibilityLabel("Continue as guest button")
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
