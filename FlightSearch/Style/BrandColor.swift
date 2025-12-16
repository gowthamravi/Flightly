import SwiftUI

/// Defines the brand-specific colors used throughout the Flightly app.
public struct BrandColor {
    
    /// The primary color used for main actions and buttons.
    /// Updated per DP-12.
    public static let primaryButton = Color(red: 227 / 255, green: 143 / 255, blue: 188 / 255)
    
    /// The main text color.
    public static let textPrimary = Color.primary
    
    /// The secondary, lighter text color.
    public static let textSecondary = Color.secondary
    
    /// The background color for primary screens.
    public static let background = Color(.systemBackground)
}
