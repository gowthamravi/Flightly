import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordSecure = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoginSuccessful = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)

                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.none)

                HStack {
                    if isPasswordSecure {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                HStack {
                    Spacer()
                    Button(action: {
                        isPasswordSecure.toggle()
                    }) {
                        Image(systemName: isPasswordSecure ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }

                Button(action: performLogin) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(username.isEmpty || password.isEmpty)

                Text("Or login with:")
                    .foregroundColor(.gray)

                HStack(spacing: 30) {
                    Button(action: {}) {
                        Image("google_logo") // Assume you have a Google logo image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }

                    Button(action: {}) {
                        Image("apple_logo") // Assume you have an Apple logo image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }

                Spacer()

                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Sign Up", destination: Text("Sign Up Screen Placeholder"))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationTitle("Login")
            .alert(isPresented: $showAlert, content: { 
                Alert(title: Text("Login Status"), message: Text(alertMessage), dismissButton: .default(Text("OK"))) 
            })
            .background(
                NavigationLink(
                    destination: Text("Main App Screen"), // Placeholder for the next screen
                    isActive: $isLoginSuccessful,
                    label: { EmptyView() })
            )
        }
    }

    func performLogin() {
        // Dummy login logic
        if username == "testuser" && password == "password123" {
            alertMessage = "Login Successful!"
            isLoginSuccessful = true
        } else {
            alertMessage = "Invalid username or password. Please try again."
            showAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
