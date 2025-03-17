import SwiftUI

struct CreativityLearningView: View {
    @Bindable var viewModel: CreativityLearningViewModel
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                // Text editors
                JournalTextEditor(
                    title: "Ideas",
                    text: $viewModel.ideas,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Learning Log",
                    text: $viewModel.learningLog,
                    minHeight: 100
                )
                
                // Media section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Books & Media")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showingAddMedia = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Book/Media")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if viewModel.showingAddMedia {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $viewModel.newMediaTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Author/Creator", text: $viewModel.newMediaCreator)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            JournalTextEditor(
                                title: "Notes",
                                text: $viewModel.newMediaNotes,
                                minHeight: 80
                            )
                            
                            HStack {
                                Text("Status:")
                                Picker("", selection: $viewModel.newMediaStatus) {
                                    Text("Not Started").tag("Not Started")
                                    Text("In Progress").tag("In Progress")
                                    Text("Completed").tag("Completed")
                                    Text("On Hold").tag("On Hold")
                                }
                            }
                            
                            HStack {
                                Button("Add") {
                                    viewModel.addMediaItem()
                                }
                                .disabled(viewModel.newMediaTitle.isEmpty)
                                
                                Button("Cancel") {
                                    viewModel.showingAddMedia = false
                                    viewModel.resetNewMediaFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    if viewModel.mediaItems.isEmpty {
                        Text("No books or media items")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 4)
                    } else {
                        ForEach(0..<viewModel.mediaItems.count, id: \.self) { index in
                            MediaItemRow(item: viewModel.mediaItems[index]) { updatedStatus in
                                viewModel.updateMediaItemStatus(index: index, status: updatedStatus)
                            }
                        }
                    }
                }
                
                JournalTextEditor(
                    title: "Projects",
                    text: $viewModel.projects,
                    minHeight: 100
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// Simple read-only row component for media items with status update
struct MediaItemRow: View {
    var item: JournalMediaItem
    var onStatusUpdate: (String) -> Void
    
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
                
                Picker("Status", selection: Binding(
                    get: { item.status },
                    set: { onStatusUpdate($0) }
                )) {
                    Text("Not Started").tag("Not Started")
                    Text("In Progress").tag("In Progress")
                    Text("Completed").tag("Completed")
                    Text("On Hold").tag("On Hold")
                }
                .frame(maxWidth: 150)
                .pickerStyle(MenuPickerStyle())
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
    CreativityLearningView(viewModel: CreativityLearningViewModel())
        .frame(width: 600)
        .padding()
} 