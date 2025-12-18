import SwiftUI

struct FlightlyButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.flightlyPrimary)
                .cornerRadius(10)
        }
    }
}

extension Color {
    static let flightlyPrimary = Color(red: 227/255, green: 143/255, blue: 188/255)
}

#Preview {
    FlightlyButton(title: "Search Flights") {
        print("Button tapped")
    }
    .padding()
}