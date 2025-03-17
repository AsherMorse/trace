import SwiftUI

struct WorkCareerView: View {
    @Bindable var viewModel: WorkCareerViewModel
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                // 1. Work Items section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Work Items")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showingAddWorkItem = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Work Item")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if viewModel.showingAddWorkItem {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $viewModel.newWorkItemTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Description", text: $viewModel.newWorkItemDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("Status:")
                                Picker("", selection: $viewModel.newWorkItemStatus) {
                                    Text("To Do").tag("To Do")
                                    Text("In Progress").tag("In Progress")
                                    Text("Completed").tag("Completed")
                                    Text("On Hold").tag("On Hold")
                                }
                            }
                            
                            HStack {
                                Text("Priority:")
                                Picker("", selection: $viewModel.newWorkItemPriority) {
                                    Text("Low").tag("Low")
                                    Text("Medium").tag("Medium")
                                    Text("High").tag("High")
                                    Text("Critical").tag("Critical")
                                }
                            }
                            
                            HStack {
                                Button("Add") {
                                    viewModel.addWorkItem(
                                        title: viewModel.newWorkItemTitle,
                                        description: viewModel.newWorkItemDescription,
                                        status: viewModel.newWorkItemStatus,
                                        priority: viewModel.newWorkItemPriority
                                    )
                                }
                                .disabled(viewModel.newWorkItemTitle.isEmpty)
                                
                                Button("Cancel") {
                                    viewModel.showingAddWorkItem = false
                                    viewModel.resetNewWorkItemFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    if viewModel.items.isEmpty {
                        Text("No work items")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 4)
                    } else {
                        ForEach(0..<viewModel.items.count, id: \.self) { index in
                            WorkItemRow(item: viewModel.items[index])
                        }
                    }
                }
                
                // 2. Meetings section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Meetings")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showingAddMeeting = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Meeting")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if viewModel.showingAddMeeting {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $viewModel.newMeetingTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Attendees", text: $viewModel.newMeetingAttendees)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            JournalTextEditor(
                                title: "Notes",
                                text: $viewModel.newMeetingNotes,
                                minHeight: 100
                            )
                            
                            HStack {
                                Button("Add") {
                                    viewModel.addMeeting(
                                        title: viewModel.newMeetingTitle,
                                        attendees: viewModel.newMeetingAttendees,
                                        notes: viewModel.newMeetingNotes
                                    )
                                }
                                .disabled(viewModel.newMeetingTitle.isEmpty)
                                
                                Button("Cancel") {
                                    viewModel.showingAddMeeting = false
                                    viewModel.resetNewMeetingFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    if viewModel.meetings.isEmpty {
                        Text("No meetings")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 4)
                    } else {
                        ForEach(0..<viewModel.meetings.count, id: \.self) { index in
                            MeetingRow(meeting: viewModel.meetings[index])
                        }
                    }
                }
                
                // 3. Text editors
                JournalTextEditor(
                    title: "Challenges",
                    text: $viewModel.challenges,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Work Accomplishments",
                    text: $viewModel.achievements,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Career Goals",
                    text: $viewModel.ideas,
                    minHeight: 100
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// Simple read-only row component for work items
struct WorkItemRow: View {
    var item: JournalWorkItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.headline)
                
                Spacer()
                
                Text(item.status)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            if !item.priority.isEmpty {
                Text("Priority: \(item.priority)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch item.status {
        case "To Do":
            return Color.secondary
        case "In Progress":
            return Color.blue
        case "Completed":
            return Color.green
        case "On Hold":
            return Color.orange
        default:
            return Color.blue
        }
    }
}

// Simple read-only row component for meetings
struct MeetingRow: View {
    var meeting: JournalMeeting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meeting.title)
                .font(.headline)
            
            if !meeting.attendees.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("Attendees:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(meeting.attendees)
                        .font(.subheadline)
                }
            }
            
            if !meeting.notes.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("Notes:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(meeting.notes)
                        .font(.subheadline)
                }
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    WorkCareerView(viewModel: WorkCareerViewModel())
        .frame(width: 600)
        .padding()
}