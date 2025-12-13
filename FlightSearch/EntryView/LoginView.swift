import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var navigateToMainView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("AppIcon") // Assuming you have an app icon named "AppIcon"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 40)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .modifier(BorderedView())

                SecureField("Password", text: $password)
                    .modifier(BorderedView())

                HStack {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember Me")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading)
                    Spacer()
                    Button("Forgot Password?") {
                        // Action for forgot password
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.trailing)
                }

                Button("Login") {
                    // Action for login
                    print("Email: \(email)")
                    print("Password: \(password)")
                    print("Remember Me: \(rememberMe)")
                    // Simulate a successful login and navigate
                    navigateToMainView = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top)

                HStack {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Button("Sign Up") {
                        // Action for sign up
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color.white.ignoresSafeArea())
            .overlay(alignment: .bottom) {
                VStack {
                    Text("Or login with")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    HStack(spacing: 30) {
                        Button { /* Social Login Action */ } label: {
                            Image(systemName: "applelogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        Button { /* Social Login Action */ } label: {
                            Image(systemName: "g.circle.fill") // Google logo
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        Button { /* Social Login Action */ } label: {
                            Image(systemName: "f.circle.fill") // Facebook logo
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationDestination(isPresented: $navigateToMainView) {
                // Assuming MainView exists and is the next destination
                MainView()
            }
        }
    }
}

// Custom Button Style for the Login Button
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
