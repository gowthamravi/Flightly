import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordObscured = true
    @EnvironmentObject var navigationPath: NavigationPath

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "airplane.departure.curve")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                HStack {
                    if isPasswordObscured {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.leading)
                    } else {
                        TextField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.leading)
                    }

                    Button(action: {
                        isPasswordObscured.toggle()
                    }) {
                        Image(systemName: isPasswordObscured ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }

                Button(action: {
                    // TODO: Implement actual login logic
                    print("Username: \(username)")
                    print("Password: \(password)")
                    // For now, navigate to the main search view
                    navigationPath.path.append("FlightSearchView")
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(username.isEmpty || password.isEmpty)

                HStack {
                    Text("Don't have an account?")
                    Button("Sign Up") {
                        // TODO: Implement Sign Up navigation
                    }
                }
                .foregroundColor(.blue)

                Spacer()

                Button("Continue as Guest") {
                    // TODO: Implement Continue as Guest navigation
                    navigationPath.path.append("MainView")
                }
                .padding(.bottom)
                .foregroundColor(.blue)
            }
            .navigationBarTitle("Flight Finder", displayMode: .inline)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(NavigationPath())
    }
}
