import SwiftUI

struct BrandColor {
    // Existing colors would be here, e.g.:
    static var background: Color {
        Color("backgroundColor")
    }
    
    static var text: Color {
        Color("textColor")
    }
    
    /// The primary pink color for main call-to-action buttons.
    /// RGB: (227, 143, 188)
    static var flightlyPink: Color {
        Color(red: 227/255, green: 143/255, blue: 188/255)
    }
}
