import SwiftUI

struct GuestView: View {
    var body: some View {
        VStack {
            Text("Welcome Guest")
                .font(.title)
                .padding()
            
            Button("Continue") {
                // Action here
            }
            .flightlyButtonStyle()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    GuestView()
}