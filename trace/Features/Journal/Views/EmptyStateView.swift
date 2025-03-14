import SwiftUI

struct EmptyStateView: View {
    let onCreateToday: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding()
            
            Text("No Date Selected")
                .font(.title)
                .fontWeight(.medium)
            
            Text("Select a date from the calendar to view or create a journal entry.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Create Today's Entry") {
                onCreateToday()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView {
        print("Create today's entry")
    }
} 