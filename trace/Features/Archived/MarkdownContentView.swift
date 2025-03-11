import SwiftUI

struct MarkdownContentView: View {
    let fileURL: URL?
    @State private var fileContent: String = ""
    @State private var originalContent: String = ""
    @State private var loadingError: String? = nil
    @State private var showingSaveButton: Bool = false
    @State private var saveSuccess: Bool = false
    
    var body: some View {
        Group {
            if let error = loadingError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Error loading file")
                    Text(error)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if fileURL == nil {
                Text("No file selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    // Editor toolbar
                    if showingSaveButton {
                        HStack {
                            Spacer()
                            
                            Button(action: saveContent) {
                                HStack {
                                    Image(systemName: saveSuccess ? "checkmark" : "square.and.arrow.down")
                                    Text(saveSuccess ? "Saved!" : "Save")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    
                    ScrollView {
                        TextEditor(text: $fileContent)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .onChange(of: fileContent) { _, newValue in
                                // Show save button if content has changed
                                showingSaveButton = newValue != originalContent
                                // Clear save success message when content changes again
                                if saveSuccess {
                                    saveSuccess = false
                                }
                            }
                    }
                }
            }
        }
        .onAppear {
            loadFileContentIfNeeded()
        }
        .onChange(of: fileURL) { _, _ in
            loadFileContentIfNeeded()
        }
        .onChange(of: saveSuccess) { _, newValue in
            // Reset success state after 2 seconds
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    saveSuccess = false
                }
            }
        }
    }
    
    private func loadFileContentIfNeeded() {
        guard let url = fileURL else {
            fileContent = ""
            originalContent = ""
            showingSaveButton = false
            return
        }
        
        loadingError = nil
        
        Task {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                
                await MainActor.run {
                    fileContent = content
                    originalContent = content
                    showingSaveButton = false
                }
            } catch {
                await MainActor.run {
                    loadingError = error.localizedDescription
                }
            }
        }
    }
    
    private func saveContent() {
        guard let url = fileURL else { return }
        
        Task {
            do {
                try fileContent.write(to: url, atomically: true, encoding: .utf8)
                
                await MainActor.run {
                    originalContent = fileContent
                    showingSaveButton = false
                    saveSuccess = true
                }
            } catch {
                await MainActor.run {
                    loadingError = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
} 