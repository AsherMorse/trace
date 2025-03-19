import SwiftUI

struct HoverButton: View {
    let systemName: String
    @Binding var isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 6).fill(isHovered ? Color.primary.opacity(0.1) : Color.clear)
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isHovered ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 36, height: 36)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
} 
