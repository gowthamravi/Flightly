import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var showOnboarding = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryBlue,
                        Color.secondaryBlue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                .opacity(backgroundOpacity)
                
                // Background Pattern/Image
                Image("SpalshScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .opacity(0.3)
                
                // Main Content
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo/App Icon
                    VStack(spacing: 16) {
                        Image(systemName: "airplane")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        
                        Text("FlightSearch")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(logoOpacity)
                            .scaleEffect(logoScale)
                    }
                    
                    Spacer()
                    
                    // Loading Indicator
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                            .opacity(logoOpacity)
                        
                        Text("Preparing your journey...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(logoOpacity)
                    }
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
    
    private func startAnimations() {
        // Background fade in
        withAnimation(.easeInOut(duration: 0.5)) {
            backgroundOpacity = 1.0
        }
        
        // Logo animations
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            logoOpacity = 1.0
            logoScale = 1.0
        }
        
        // Rotation animation
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            isAnimating = true
        }
        
        // Navigate to onboarding after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    SplashView()
}