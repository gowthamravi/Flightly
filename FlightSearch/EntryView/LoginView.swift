import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @Environment("navigationPath") private var navigationPath: Binding<NavigationPath>

    var body: some View {
        VStack {
            Image("AppLogo") // Assuming you have an app logo image
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 50)

            Text("Welcome Back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("Log in to your account")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)

            // Username Field
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .autocapitalization(.none)

            // Password Field
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)

            HStack {
                Spacer()
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal)

            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Action for forgot password
                }
                .padding(.top, 5)
                .padding(.trailing)
            }

            // Login Button
            Button("Login") {
                // Action for login
                // Dummy navigation for now
                navigationPath.wrappedValue.append("FlightSearch")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 30)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

            Spacer()

            // Sign Up Button
            HStack {
                Text("Don't have an account?")
                Button("Sign Up") {
                    // Action for sign up
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
