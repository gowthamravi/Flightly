import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToMainView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "airplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Text("Flight Finder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button("Login") {
                    // TODO: Implement actual login logic
                    // For now, navigate on button tap for demo purposes
                    navigateToMainView = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(username.isEmpty || password.isEmpty)

                NavigationLink(destination: MainView(), isActive: $navigateToMainView) {
                    EmptyView()
                }
                .hidden()
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    Button("Sign Up") {
                        // TODO: Implement Sign Up navigation
                    }
                }
                .foregroundColor(.blue)
            }
            .padding()
            .navigationBarTitle("Welcome", displayMode: .inline)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
