import SwiftUI

struct FolderPathDisplayView: View {
    let path: String
    let hasSelectedFolder: Bool
    let isValidFolder: Bool
    var onFolderOpen: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current folder:")
                .font(.subheadline)

            HStack {
                Text(path)
                    .font(.body)
                    .foregroundColor(hasSelectedFolder ? .primary : .secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                if hasSelectedFolder && onFolderOpen != nil {
                    Button(
                        action: { onFolderOpen?() },
                        label: {
                            Image(systemName: "folder")
                                .font(.system(size: 14))
                        }
                    )
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Open in Finder")
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(validationColor, lineWidth: hasSelectedFolder && !isValidFolder ? 1 : 0)
                    )
            )
        }
    }

    private var validationColor: Color {
        if !hasSelectedFolder || isValidFolder {
            return .clear
        }
        return .red
    }
}

struct FolderPathDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FolderPathDisplayView(
                path: "/Users/example/Documents",
                hasSelectedFolder: true,
                isValidFolder: true,
                onFolderOpen: {}
            )
            .previewDisplayName("Selected Valid")

            FolderPathDisplayView(
                path: "/Users/example/Documents",
                hasSelectedFolder: true,
                isValidFolder: false,
                onFolderOpen: {}
            )
            .previewDisplayName("Selected Invalid")

            FolderPathDisplayView(
                path: "No folder selected",
                hasSelectedFolder: false,
                isValidFolder: false
            )
            .previewDisplayName("No Selection")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
