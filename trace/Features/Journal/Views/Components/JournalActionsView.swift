import SwiftUI

struct JournalActionsView: View {
    var viewModel: JournalViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            
            quickActionsButtons
            
            Spacer()
        }
        .padding()
        .background(Theme.backgroundSecondary)
    }
    
    // MARK: - Private Views
    
    private var headerView: some View {
        // STUB: Header for quick actions section
        Text("Quick Actions")
            .font(.headline)
            .fontWeight(.bold)
            .padding(.bottom, 4)
    }
    
    private var quickActionsButtons: some View {
        // STUB: Quick action buttons for common journal operations
        VStack(spacing: 10) {
            newEntryButton
            todaysEntryButton
            recentEntriesButton
            searchButton
            resetFolderButton
        }
    }
    
    private var newEntryButton: some View {
        // STUB: Button to create a new entry
        Button(action: {
            createNewEntry()
        }) {
            Label("Record New Entry", systemImage: "square.and.pencil")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .help("Create a new journal entry for the selected date or today")
    }
    
    private var todaysEntryButton: some View {
        // STUB: Button to show today's entry
        Button(action: {
            viewModel.openTodaysEntry()
        }) {
            Label("Today's Entry", systemImage: "calendar.badge.clock")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.green)
        .help("View or create an entry for today")
    }
    
    private var recentEntriesButton: some View {
        // STUB: Button to show recent entries (non-functional in stub)
        Button(action: {
            // Not implemented in stub
            print("Recent entries button tapped")
        }) {
            Label("Recent Entries", systemImage: "clock")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.indigo)
        .disabled(true) // Disabled in stub
        .help("View recently created journal entries")
    }
    
    private var searchButton: some View {
        // STUB: Button to search entries (non-functional in stub)
        Button(action: {
            // Not implemented in stub
            print("Search button tapped")
        }) {
            Label("Search Journal", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.purple)
        .disabled(true) // Disabled in stub
        .help("Search for content in your journal entries")
    }
    
    private var resetFolderButton: some View {
        // STUB: Button to reset folder selection
        Button(action: {
            viewModel.resetFolderSelection()
        }) {
            Label("Reset Folder Selection", systemImage: "folder.badge.minus")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .help("Clear the current journal folder selection")
    }
    
    // MARK: - Private Methods
    
    private func createNewEntry() {
        print("📔 createNewEntry called")
    }
} 
