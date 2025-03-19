import SwiftUI

struct ErrorStateView: View {
    let errorMessage: String?
    let date: Date?
    let formatDate: (Date) -> String
    let onTryAgain: () -> Void
    let onCreateNew: () -> Void
    
    init(
        errorMessage: String? = nil,
        date: Date? = nil,
        formatDate: @escaping (Date) -> String = { $0.formatted(date: .abbreviated, time: .omitted) },
        onTryAgain: @escaping () -> Void,
        onCreateNew: @escaping () -> Void
    ) {
        self.errorMessage = errorMessage
        self.date = date
        self.formatDate = formatDate
        self.onTryAgain = onTryAgain
        self.onCreateNew = onCreateNew
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text("Error loading entry")
                .font(.title)
                .fontWeight(.medium)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            if let date = date {
                Text(formatDate(date))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                Button("Try Again") {
                    onTryAgain()
                }
                .buttonStyle(.bordered)
                
                Button("Create New Entry") {
                    onCreateNew()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorStateView(
        errorMessage: "The journal entry appears to be corrupted or couldn't be loaded.",
        date: Date(),
        onTryAgain: {},
        onCreateNew: {}
    )
} 
