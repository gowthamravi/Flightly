import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let onboardingData = [
        OnboardingData(
            image: "Cover",
            title: "Welcome to FlightSearch",
            subtitle: "Find the best flights at the best prices",
            description: "Search and compare flights from hundreds of airlines to get the best deals for your next trip."
        ),
        OnboardingData(
            image: "OnBoarding",
            title: "Easy Booking",
            subtitle: "Book your flight in just a few taps",
            description: "Our streamlined booking process makes it simple to reserve your seat and get ready for takeoff."
        ),
        OnboardingData(
            image: "BoardingPass",
            title: "Digital Boarding Pass",
            subtitle: "Get your boarding pass instantly",
            description: "Receive your digital boarding pass immediately after booking and check in with ease."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Image Section
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(onboardingData[index].image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .frame(height: geometry.size.height * 0.4)
                                .scaleEffect(isAnimating ? 1.0 : 0.8)
                                .opacity(isAnimating ? 1.0 : 0.6)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: geometry.size.height * 0.55)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryBlue.opacity(0.1), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Bottom Content Section
                VStack(spacing: 32) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.primaryBlue : Color.borderGray)
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Content
                    VStack(spacing: 16) {
                        Text(onboardingData[currentPage].title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingData[currentPage].subtitle)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.primaryBlue)
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingData[currentPage].description)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        if currentPage == onboardingData.count - 1 {
                            // Get Started Button
                            Button(action: {
                                // Handle get started action
                            }) {
                                HStack {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.primaryBlue)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 24)
                            
                            // Skip Button
                            Button(action: {
                                // Handle skip action
                            }) {
                                Text("Skip for now")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                            }
                        } else {
                            // Next Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            }) {
                                HStack {
                                    Text("Next")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.primaryBlue)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 24)
                            
                            // Skip Button
                            Button(action: {
                                // Handle skip action
                            }) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                .background(Color.white)
                .cornerRadius(24, corners: [.topLeft, .topRight])
            }
        }
        .background(Color.backgroundGray)
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .onChange(of: currentPage) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct OnboardingData {
    let image: String
    let title: String
    let subtitle: String
    let description: String
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    OnboardingView()
}