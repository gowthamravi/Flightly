import SwiftUI

struct FromView: View {
    @State private var selectedStation: String = "BLR"
    @State private var selectedCity: String = "Bengaluru"
    @State private var isShowingStationList = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("From")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Content
            Button(action: {
                isShowingStationList = true
            }) {
                HStack(spacing: 12) {
                    // Station Code Circle
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 40, height: 40)
                        
                        Text(selectedStation)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // City and Station Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedCity)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Kempegowda International Airport")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Arrow Icon
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .sheet(isPresented: $isShowingStationList) {
            StationView(isPresented: $isShowingStationList, stationType: .origin)
        }
    }
}

#Preview {
    FromView()
        .padding()
        .background(Color.backgroundGray)
}