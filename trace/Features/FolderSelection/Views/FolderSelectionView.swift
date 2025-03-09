import SwiftUI

struct FolderSelectionView: View {
    @ObservedObject var viewModel: FolderSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Journal Folder")
                .font(.title)
                .fontWeight(.semibold)
            
            FolderPathDisplayView(
                path: viewModel.displayPath,
                hasSelectedFolder: viewModel.hasSelectedFolder,
                isValidFolder: viewModel.isValidFolder
            )
            
            if viewModel.hasError {
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Select Folder") {
                    viewModel.selectFolder()
                    
                    viewModel.onFolderSelected = { success in
                        if success {
                            dismiss()
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 500, height: 250)
        .onAppear {
            viewModel.validateSelectedFolder()
        }
    }
}

struct FolderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FolderSelectionView(viewModel: FolderSelectionViewModel())
    }
} 
