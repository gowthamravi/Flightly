import SwiftUI

struct FromComponent: View {
    let fromText: String
    let locationText: String
    
    init(fromText: String = "From", locationText: String = "Mumbai") {
        self.fromText = fromText
        self.locationText = locationText
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(fromText)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(locationText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Image("Vector")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 280, height: 52)
        .background(Color.backgroundWhite)
        .cornerRadius(8)
    }
}

#Preview {
    FromComponent()
        .padding()
}