import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = false
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("component") // Assuming 'component' is a logo or relevant image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 40)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button {
                    // TODO: Implement login/signup logic
                    if email.isEmpty || password.isEmpty {
                        alertMessage = "Please enter both email and password."
                        showingAlert = true
                    } else {
                        // Placeholder for actual authentication logic
                        alertMessage = isLoginMode ? "Login successful!" : "Sign up successful!"
                        showingAlert = true
                    }
                } label: {
                    Text(isLoginMode ? "Log In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Image("button").resizable().scaledToFill())
                        .cornerRadius(8)
                }
                .padding(.top)

                Button {
                    isLoginMode.toggle()
                } label: {
                    Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK"))) //.
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
