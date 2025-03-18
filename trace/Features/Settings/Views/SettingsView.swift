import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var isSecureTextEntry = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                Text("OpenAI API Key")
                    .font(.headline)
                
                HStack {
                    if isSecureTextEntry {
                        SecureField("Enter API Key", text: $viewModel.apiKey)
                    } else {
                        TextField("Enter API Key", text: $viewModel.apiKey)
                    }
                    
                    Button(action: { isSecureTextEntry.toggle() }) {
                        Image(systemName: isSecureTextEntry ? "eye" : "eye.slash")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if viewModel.showAPIKeyError {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            
            Section {
                HStack {
                    Button("Save") {
                        viewModel.saveAPIKey()
                    }
                    .keyboardShortcut(.defaultAction)
                    
                    Button("Test Connection") {
                        viewModel.testConnection()
                    }
                    
                    if viewModel.hasAPIKey {
                        Button("Delete Key") {
                            viewModel.deleteAPIKey()
                        }
                        .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450)
        .onAppear {
            viewModel.loadAPIKey()
        }
    }
}

#Preview {
    let settings = SettingsViewModel(settingsManager: AppSettingsManager())
    return SettingsView(viewModel: settings)
} 
