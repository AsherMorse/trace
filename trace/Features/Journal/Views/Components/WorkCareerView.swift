import SwiftUI

struct WorkCareerView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var workItems: [WorkItem] = [] {
        didSet {
            updateViewModel()
        }
    }
    @State private var meetings: [Meeting] = [] {
        didSet {
            updateViewModel()
        }
    }
    @State private var challenges: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var wins: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var workIdeas: String = "" {
        didSet {
            updateViewModel()
        }
    }
    
    // Work Item States
    @State private var showingAddWorkItem: Bool = false
    @State private var newWorkItemTitle: String = ""
    @State private var newWorkItemDescription: String = ""
    @State private var newWorkItemStatus: WorkItemStatus = .todo
    @State private var newWorkItemPriority: WorkItemPriority = .medium
    
    // Meeting States
    @State private var showingAddMeeting: Bool = false
    @State private var newMeetingTitle: String = ""
    @State private var newMeetingAttendees: String = ""
    @State private var newMeetingNotes: String = ""
    @State private var newMeetingActionItems: String = ""
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                // Work Items Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Items")
                        .font(.headline)
                    
                    if !workItems.isEmpty {
                        ForEach(workItems) { item in
                            WorkItemRow(item: item) { updatedItem in
                                if let index = workItems.firstIndex(where: { $0.id == updatedItem.id }) {
                                    workItems[index] = updatedItem
                                    updateViewModel()
                                }
                            }
                        }
                    }
                    
                    if showingAddWorkItem {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $newWorkItemTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Description", text: $newWorkItemDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Status: ", selection: $newWorkItemStatus) {
                                ForEach(WorkItemStatus.allCases, id: \.self) { status in
                                    Text(status.description).tag(status)
                                }
                            }
                            .frame(width: 150)
                            
                            
                            Picker("Priority: ", selection: $newWorkItemPriority) {
                                ForEach(WorkItemPriority.allCases, id: \.self) { priority in
                                    Text(priority.description).tag(priority)
                                }
                            }
                            .frame(width: 150)
                            
                            HStack {
                                Button("Add") {
                                    addWorkItem()
                                }
                                .disabled(newWorkItemTitle.isEmpty)
                                
                                Button("Cancel") {
                                    showingAddWorkItem = false
                                    resetNewWorkItemFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            showingAddWorkItem = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Work Item")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Meetings Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meetings")
                        .font(.headline)
                    
                    if !meetings.isEmpty {
                        ForEach(meetings) { meeting in
                            MeetingRow(meeting: meeting)
                        }
                    }
                    
                    if showingAddMeeting {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $newMeetingTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Attendees", text: $newMeetingAttendees)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Key Notes", text: $newMeetingNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Action Items", text: $newMeetingActionItems)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Button("Add") {
                                    addMeeting()
                                }
                                .disabled(newMeetingTitle.isEmpty)
                                
                                Button("Cancel") {
                                    showingAddMeeting = false
                                    resetNewMeetingFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            showingAddMeeting = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Meeting")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Text Editors
                JournalTextEditor(
                    title: "Challenges",
                    text: $challenges
                )
                .frame(minHeight: 100)
                .onChange(of: challenges) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Wins",
                    text: $wins
                )
                .frame(minHeight: 100)
                .onChange(of: wins) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Work Ideas",
                    text: $workIdeas
                )
                .frame(minHeight: 100)
                .onChange(of: workIdeas) { _, _ in
                    updateViewModel()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                loadFromViewModel()
            }
        }
    }
    
    private func addWorkItem() {
        let workItem = WorkItem(
            title: newWorkItemTitle,
            description: newWorkItemDescription,
            status: newWorkItemStatus,
            priority: newWorkItemPriority
        )
        workItems.append(workItem)
        showingAddWorkItem = false
        resetNewWorkItemFields()
        updateViewModel()
    }
    
    private func resetNewWorkItemFields() {
        newWorkItemTitle = ""
        newWorkItemDescription = ""
        newWorkItemStatus = .todo
        newWorkItemPriority = .medium
    }
    
    private func addMeeting() {
        let meeting = Meeting(
            title: newMeetingTitle,
            attendees: newMeetingAttendees,
            notes: newMeetingNotes,
            actionItems: newMeetingActionItems
        )
        meetings.append(meeting)
        showingAddMeeting = false
        resetNewMeetingFields()
        updateViewModel()
    }
    
    private func resetNewMeetingFields() {
        newMeetingTitle = ""
        newMeetingAttendees = ""
        newMeetingNotes = ""
        newMeetingActionItems = ""
    }
    
    private func updateViewModel() {
        // Create a JournalEntry with updated values and convert to markdown
        var entry = viewModel.currentEntry ?? JournalEntry(date: viewModel.selectedDate ?? Date())
        
        // Convert WorkItems to JournalWorkItems
        let journalWorkItems = workItems.map { item -> JournalWorkItem in
            return JournalWorkItem(
                title: item.title,
                status: item.status.rawValue,
                priority: item.priority.rawValue,
                description: item.description
            )
        }
        
        // Convert Meetings to JournalMeetings
        let journalMeetings = meetings.map { meeting -> JournalMeeting in
            return JournalMeeting(
                title: meeting.title,
                attendees: meeting.attendees,
                notes: meeting.notes,
                actionItems: meeting.actionItems
            )
        }
        
        // Update the entry
        entry.workCareer.workItems = journalWorkItems
        entry.workCareer.meetings = journalMeetings
        entry.workCareer.challenges = challenges
        entry.workCareer.wins = wins
        entry.workCareer.workIdeas = workIdeas
        
        // Update the viewModel's editedContent with new markdown
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            challenges = entry.workCareer.challenges
            wins = entry.workCareer.wins
            workIdeas = entry.workCareer.workIdeas
            
            // Convert JournalWorkItems to WorkItems
            workItems = entry.workCareer.workItems.map { item -> WorkItem in
                return WorkItem(
                    title: item.title,
                    description: item.description,
                    status: WorkItemStatus(rawValue: item.status) ?? .todo,
                    priority: WorkItemPriority(rawValue: item.priority) ?? .medium
                )
            }
            
            // Convert JournalMeetings to Meetings
            meetings = entry.workCareer.meetings.map { meeting -> Meeting in
                return Meeting(
                    title: meeting.title,
                    attendees: meeting.attendees,
                    notes: meeting.notes,
                    actionItems: meeting.actionItems
                )
            }
        }
    }
}

// MARK: - Work Item Models

struct WorkItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var status: WorkItemStatus
    var priority: WorkItemPriority
}

enum WorkItemStatus: String, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case completed = "Completed"
    case onHold = "On Hold"
    
    var description: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .todo:
            return Color.secondary
        case .inProgress:
            return Color.blue
        case .completed:
            return Color.green
        case .onHold:
            return Color.orange
        }
    }
}

enum WorkItemPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var description: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return Color.gray
        case .medium:
            return Color.blue
        case .high:
            return Color.orange
        case .critical:
            return Color.red
        }
    }
}

struct WorkItemRow: View {
    var item: WorkItem
    var onUpdate: (WorkItem) -> Void
    
    @State private var status: WorkItemStatus
    
    init(item: WorkItem, onUpdate: @escaping (WorkItem) -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        _status = State(initialValue: item.status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Priority indicator
                    Text(item.priority.description)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.priority.color.opacity(0.2))
                        .foregroundColor(item.priority.color)
                        .cornerRadius(4)
                    
                    // Status picker
                    Picker("Status", selection: $status) {
                        ForEach(WorkItemStatus.allCases, id: \.self) { status in
                            Text(status.description).tag(status)
                        }
                    }
                    .frame(width: 120)
                    .onChange(of: status) { newValue in
                        var updatedItem = item
                        updatedItem.status = newValue
                        onUpdate(updatedItem)
                    }
                }
            }
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - Meeting Models

struct Meeting: Identifiable {
    let id = UUID()
    var title: String
    var attendees: String
    var notes: String
    var actionItems: String
}

struct MeetingRow: View {
    var meeting: Meeting
    
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
            
            if !meeting.actionItems.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("Action Items:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(meeting.actionItems)
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
    WorkCareerView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
}
