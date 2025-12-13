import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Background
            Rectangle() // Using a simple rectangle for now, can be replaced with an image
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.8, green: 0.85, blue: 1.0), Color(red: 1.0, green: 0.8, blue: 0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo and App Name
                HStack {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: Color(red: 1.0, green: 0.4, blue: 0.6), location: 0),
                                Gradient.Stop(color: Color(red: 0.4, green: 0.6, blue: 1.0), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)
                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                    
                    Text("photo")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 10)
                
                // Placeholder for the swirling background effect if needed
                // For now, we'll rely on the main ZStack background.
                
                Spacer()
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding(15)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding(15)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // Action for Login
                    }) {
                        Text("LOG IN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Action for Register
                    }) {
                        Text("REGISTER")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // User Info
                HStack {
                    Image(systemName: "person.circle.fill") // Placeholder for user avatar
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text("Pawel Czerwinski")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("@pawel_czerwinski")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
