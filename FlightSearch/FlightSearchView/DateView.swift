import SwiftUI

struct DateView: View {
    let title: String
    @Binding var date: Date
    let isSelected: Bool
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    var body: some View {
        DatePicker("", selection: $date, displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .overlay(
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dateFormatter.string(from: date))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(monthFormatter.string(from: date))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(dayFormatter.string(from: date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(red: 0.2, green: 0.4, blue: 0.8) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .allowsHitTesting(false)
            )
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(
            title: "Departure",
            date: .constant(Date()),
            isSelected: true
        )
        .padding()
    }
}