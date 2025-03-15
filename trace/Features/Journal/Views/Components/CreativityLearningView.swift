import SwiftUI

struct CreativityLearningView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var ideas: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var learningLog: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var projects: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var mediaItems: [MediaItem] = [] {
        didSet {
            updateViewModel()
        }
    }
    @State private var newMediaTitle: String = ""
    @State private var newMediaCreator: String = ""
    @State private var newMediaNotes: String = ""
    @State private var newMediaStatus: MediaStatus = .notStarted
    @State private var showingAddMedia: Bool = false
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                JournalTextEditor(
                    title: "Ideas",
                    text: $ideas
                )
                .frame(minHeight: 100)
                .onChange(of: ideas) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Learning Log",
                    text: $learningLog
                )
                .frame(minHeight: 100)
                .onChange(of: learningLog) { _, _ in
                    updateViewModel()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Books & Media")
                        .font(.headline)
                    
                    if !mediaItems.isEmpty {
                        ForEach(mediaItems) { item in
                            MediaItemRow(item: item) { updatedItem in
                                if let index = mediaItems.firstIndex(where: { $0.id == updatedItem.id }) {
                                    mediaItems[index] = updatedItem
                                    updateViewModel()
                                }
                            }
                        }
                    }
                    
                    if showingAddMedia {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $newMediaTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Author/Creator", text: $newMediaCreator)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Notes", text: $newMediaNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Status: ", selection: $newMediaStatus) {
                                ForEach(MediaStatus.allCases, id: \.self) { status in
                                    Text(status.description).tag(status)
                                }
                            }
                            .frame(maxWidth: 150)
                            .pickerStyle(MenuPickerStyle())
                            
                            HStack {
                                Button("Add") {
                                    addMediaItem()
                                }
                                .disabled(newMediaTitle.isEmpty)
                                
                                Button("Cancel") {
                                    showingAddMedia = false
                                    resetNewMediaFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            showingAddMedia = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Book/Media")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                JournalTextEditor(
                    title: "Projects",
                    text: $projects
                )
                .frame(minHeight: 100)
                .onChange(of: projects) { _, _ in
                    updateViewModel()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                loadFromViewModel()
            }
        }
    }
    
    private func addMediaItem() {
        let newItem = MediaItem(
            title: newMediaTitle,
            creator: newMediaCreator,
            notes: newMediaNotes,
            status: newMediaStatus
        )
        mediaItems.append(newItem)
        showingAddMedia = false
        resetNewMediaFields()
        updateViewModel()
    }
    
    private func resetNewMediaFields() {
        newMediaTitle = ""
        newMediaCreator = ""
        newMediaNotes = ""
        newMediaStatus = .notStarted
    }
    
    private func updateViewModel() {
        // Create a JournalEntry with updated values and convert to markdown
        var entry = viewModel.currentEntry ?? JournalEntry(date: viewModel.selectedDate ?? Date())
        
        // Convert MediaItems to JournalMediaItems
        let journalMediaItems = mediaItems.map { item -> JournalMediaItem in
            return JournalMediaItem(
                title: item.title,
                creator: item.creator,
                status: convertMediaStatus(item.status),
                notes: item.notes
            )
        }
        
        // Update the entry
        entry.creativityLearning.ideas = ideas
        entry.creativityLearning.learningLog = learningLog
        entry.creativityLearning.booksMedia = journalMediaItems
        entry.creativityLearning.projects = projects
        
        // Update the viewModel's editedContent with new markdown
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            ideas = entry.creativityLearning.ideas
            learningLog = entry.creativityLearning.learningLog
            projects = entry.creativityLearning.projects
            
            // Convert JournalMediaItems to MediaItems
            mediaItems = entry.creativityLearning.booksMedia.map { item -> MediaItem in
                return MediaItem(
                    title: item.title,
                    creator: item.creator,
                    notes: item.notes,
                    status: convertJournalMediaStatus(item.status)
                )
            }
        }
    }
    
    private func convertMediaStatus(_ status: MediaStatus) -> String {
        return status.rawValue
    }
    
    private func convertJournalMediaStatus(_ status: String) -> MediaStatus {
        return MediaStatus.allCases.first { $0.rawValue == status } ?? .notStarted
    }
}

struct MediaItem: Identifiable {
    let id = UUID()
    var title: String
    var creator: String
    var notes: String
    var status: MediaStatus
}

enum MediaStatus: String, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case onHold = "On Hold"
    
    var description: String {
        return self.rawValue
    }
}

struct MediaItemRow: View {
    var item: MediaItem
    var onUpdate: (MediaItem) -> Void
    
    @State private var status: MediaStatus
    
    init(item: MediaItem, onUpdate: @escaping (MediaItem) -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        _status = State(initialValue: item.status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                    
                    if !item.creator.isEmpty {
                        Text(item.creator)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Picker("Status", selection: $status) {
                    ForEach(MediaStatus.allCases, id: \.self) { status in
                        Text(status.description).tag(status)
                    }
                }
                .frame(maxWidth: 150)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: status) { oldValue, newValue in
                    var updatedItem = item
                    updatedItem.status = newValue
                    onUpdate(updatedItem)
                }
            }
            
            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 2)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    CreativityLearningView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
}
