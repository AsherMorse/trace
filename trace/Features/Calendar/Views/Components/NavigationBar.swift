import SwiftUI

struct NavigationBar: View {
    let title: String
    let leadingAction: () -> Void
    let trailingAction: () -> Void
    
    @State private var isLeadingHovered = false
    @State private var isTrailingHovered = false
    
    var body: some View {
        HStack {
            HoverButton(systemName: "chevron.left", isHovered: $isLeadingHovered, action: leadingAction)
            Spacer()
            Text(title).font(Theme.titleFont)
            Spacer()
            HoverButton(systemName: "chevron.right", isHovered: $isTrailingHovered, action: trailingAction)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }
} 
