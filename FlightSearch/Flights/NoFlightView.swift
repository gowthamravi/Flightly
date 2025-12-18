import SwiftUI

struct NoFlightView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Flights Found", systemImage: "airplane.circle")
        } description: {
            Text("There are no available flights for the selected route and date. Please try changing your search criteria.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoFlightView_Previews: PreviewProvider {
    static var previews: some View {
        NoFlightView()
    }
}
