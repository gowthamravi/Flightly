import SwiftUI

struct FareView: View {
    let fare: Double
    let onSelect: () -> Void

    private var formattedFare: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR" // Should be dynamic based on data
        return formatter.string(from: NSNumber(value: fare)) ?? "N/A"
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(formattedFare)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            Button(action: onSelect) {
                Text("Select")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.leading, 12)
    }
}

struct FareView_Previews: PreviewProvider {
    static var previews: some View {
        FareView(fare: 120.99, onSelect: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
