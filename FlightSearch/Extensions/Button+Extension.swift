import SwiftUI

struct FlightlyButton: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 227/255, green: 143/255, blue: 188/255))
            .clipShape(Capsule())
    }
}