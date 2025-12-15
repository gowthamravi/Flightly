import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var navigateToMain = false

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "airplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 50)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .disableAutocorrection(true)

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

                Button("Login") {
                    // TODO: Implement actual login logic
                    if isValidLogin() {
                        navigateToMain = true
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty)

                Spacer()

                NavigationLink(destination: ContentView(), isActive: $navigateToMain) {
                    EmptyView()
                }
            }
            .navigationTitle("Flight Search")
        }
    }

    func isValidLogin() -> Bool {
        // Basic validation for demonstration purposes
        return username == "user" && password == "password"
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
