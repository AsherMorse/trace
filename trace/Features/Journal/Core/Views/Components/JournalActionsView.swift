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
    
    private var headerView: some View {
        Text("Quick Actions")
            .font(.headline)
            .fontWeight(.bold)
            .padding(.bottom, 4)
    }
    
    private var quickActionsButtons: some View {
        VStack(spacing: 10) {
            newEntryButton
            todaysEntryButton
            recentEntriesButton
            searchButton
            resetFolderButton
        }
    }
    
    private var newEntryButton: some View {
        
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
        
        Button(action: {
            
            print("Recent entries button tapped")
        }) {
            Label("Recent Entries", systemImage: "clock")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.indigo)
        .disabled(true) 
        .help("View recently created journal entries")
    }
    
    private var searchButton: some View {
        
        Button(action: {
            
            print("Search button tapped")
        }) {
            Label("Search Journal", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.purple)
        .disabled(true) 
        .help("Search for content in your journal entries")
    }
    
    private var resetFolderButton: some View {
        
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
    
    private func createNewEntry() {
        print("📔 createNewEntry called")
    }
} 
