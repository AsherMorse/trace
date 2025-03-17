import SwiftUI

struct SectionContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    SectionContainer {
        Text("Section Title")
            .font(.headline)
        
        Text("Section content goes here")
            .padding(.top, 4)
    }
    .padding()
    .frame(width: 400)
} 