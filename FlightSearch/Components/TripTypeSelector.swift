import SwiftUI

struct TripTypeSelector: View {
    @Binding var selectedTripType: TripType
    
    var body: some View {
        HStack(spacing: 0) {
            TripTypeButton(
                title: "One way",
                isSelected: selectedTripType == .oneWay,
                action: { selectedTripType = .oneWay }
            )
            
            TripTypeButton(
                title: "Round trip",
                isSelected: selectedTripType == .roundTrip,
                action: { selectedTripType = .roundTrip }
            )
        }
        .frame(width: 280, height: 52)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TripTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : Color.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    isSelected ? Color.blue : Color.clear
                )
                .cornerRadius(8)
                .padding(4)
        }
    }
}

enum TripType: CaseIterable {
    case oneWay
    case roundTrip
    
    var title: String {
        switch self {
        case .oneWay:
            return "One way"
        case .roundTrip:
            return "Round trip"
        }
    }
}

#Preview {
    TripTypeSelector(selectedTripType: .constant(.oneWay))
        .padding()
}