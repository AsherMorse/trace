import SwiftUI

struct JournalTextEditor: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat
    
    init(title: String, text: Binding<String>, minHeight: CGFloat = 80) {
        self.title = title
        self._text = text
        self.minHeight = minHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextEditor(text: $text)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        JournalTextEditor(title: "Empty", text: .constant(""), minHeight: 100)
        JournalTextEditor(title: "With Text", text: .constant("This is actual entered text"), minHeight: 100)
    }
    .padding()
    .frame(width: 400)
}
