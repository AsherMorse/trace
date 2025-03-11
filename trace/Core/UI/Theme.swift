import SwiftUI
import AppKit

enum Theme {
    static var backgroundPrimary: some View {
        Rectangle().fill(Color(NSColor.windowBackgroundColor))
    }
    
    static var backgroundSecondary: some View {
        Rectangle().fill(Color(NSColor.controlBackgroundColor))
    }
    
    static var backgroundNav: some View {
        Rectangle().fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .background(Color(NSColor.windowBackgroundColor))
    }
    
    static var titleFont: Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }
    
    static var bodyFont: Font {
        .system(size: 14, weight: .regular)
    }
    
    static var secondaryFont: Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }
    
    static var primary: Color {
        .primary
    }
    
    static var secondary: Color {
        .secondary
    }
    
    static var tertiary: Color {
        Color(NSColor.tertiaryLabelColor)
    }
    
    static var backgroundFill: Color {
        Color(NSColor.windowBackgroundColor)
    }
}