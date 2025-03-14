import SwiftUI

struct NotFoundStateView: View {
    let date: Date
    let formatDate: (Date) -> String
    let onCreateEntry: () -> Void
    
    init(
        date: Date,
        formatDate: @escaping (Date) -> String = { $0.formatted(date: .abbreviated, time: .omitted) },
        onCreateEntry: @escaping () -> Void
    ) {
        self.date = date
        self.formatDate = formatDate
        self.onCreateEntry = onCreateEntry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding()
            
            Text("No Entry Found")
                .font(.title)
                .fontWeight(.medium)
            
            Text("There is no journal entry for \(formatDate(date)).")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Create New Entry") {
                onCreateEntry()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotFoundStateView(
        date: Date(),
        onCreateEntry: {}
    )
} 