import SwiftUI

struct WelcomeView: View {
    var viewModel: FolderSelectionViewModel
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Welcome to Trace Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("To get started, select a folder where your journal entries will be stored.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 450)
            }

            Image(systemName: "doc.text.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Your entries will be saved as Markdown files (.md)")
                    .font(.callout)

                Text("You can access them from any device or application")
                    .font(.callout)
            }
            .foregroundColor(.secondary)

            FolderPathDisplayView(
                path: viewModel.displayPath,
                hasSelectedFolder: viewModel.hasSelectedFolder,
                isValidFolder: viewModel.isValidFolder,
                onFolderOpen: viewModel.hasSelectedFolder ? { viewModel.openInFinder() } : nil
            )
            .padding(.horizontal)

            if viewModel.hasSelectedFolder {
                statusInfo
            }

            Spacer()

            VStack(spacing: 16) {
                Button(
                    action: { viewModel.selectFolder() },
                    label: {
                        Text(viewModel.hasSelectedFolder ? "Change Folder" : "Select Folder")
                            .frame(width: 200)
                    }
                )
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if viewModel.hasSelectedFolder && viewModel.isValidFolder {
                    Button(
                        action: { hasCompletedOnboarding = true },
                        label: {
                            Text("Continue")
                                .frame(width: 200)
                        }
                    )
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(40)
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            viewModel.validateSelectedFolder()
        }
    }

    private var statusInfo: some View {
        HStack {
            if viewModel.isValidFolder {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }

            Text(viewModel.statusMessage)
                .font(.callout)
                .foregroundColor(viewModel.hasError ? .red : .primary)
        }
        .padding(.top, 8)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(
                viewModel: FolderSelectionViewModel(),
                hasCompletedOnboarding: .constant(false)
            )
            .previewDisplayName("Initial State")

            WelcomeView(
                viewModel: FolderSelectionViewModel(),
                hasCompletedOnboarding: .constant(false)
            )
            .previewDisplayName("Folder Selected")
        }
    }
}
