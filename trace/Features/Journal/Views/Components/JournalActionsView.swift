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
        // TODO: Implement header view
        Text("Quick Actions")
            .font(.headline)
            .padding(.bottom, 4)
    }
    
    private var quickActionsButtons: some View {
        // TODO: Implement quick action buttons
        VStack(spacing: 8) {
            newEntryButton
            todaysEntryButton
            recentEntriesButton
            searchButton
            resetFolderButton
        }
    }
    
    private var newEntryButton: some View {
        // TODO: Implement new entry button
        Button(action: {
            createNewEntry()
        }) {
            Label("Record New Entry", systemImage: "square.and.pencil")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
    }
    
    private var todaysEntryButton: some View {
        // TODO: Implement today's entry button
        Button(action: {
            viewModel.openTodaysEntry()
        }) {
            Label("Today's Entry", systemImage: "calendar.badge.clock")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
    }
    
    private var recentEntriesButton: some View {
        // TODO: Implement recent entries button
        Button(action: {
            // Not implemented yet
        }) {
            Label("Recent Entries", systemImage: "clock")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
    }
    
    private var searchButton: some View {
        // TODO: Implement search button
        Button(action: {
            // Not implemented yet
        }) {
            Label("Search Journal", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
    }
    
    private var resetFolderButton: some View {
        // TODO: Implement reset folder button
        Button(action: {
            viewModel.resetFolderSelection()
        }) {
            Label("Reset Folder Selection", systemImage: "folder.badge.minus")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .foregroundColor(.red)
    }
    
    // MARK: - Private Methods
    
    private func createNewEntry() {
        // TODO: Implement create new entry
        if let date = viewModel.selectedDate {
            viewModel.createEntry(for: date)
        } else {
            viewModel.createEntry(for: Date())
        }
    }
} 