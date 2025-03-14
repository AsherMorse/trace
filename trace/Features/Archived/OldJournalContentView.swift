import SwiftUI

struct OldJournalContentView: View {
    @Bindable var viewModel: JournalViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedTab: JournalSection = .dailyCheckIn
    
    // MARK: - Temporary UI State (not persisted to disk)
    // Work section state
    @State private var workItemStatuses: [Int: String] = [0: "arrow.clockwise", 1: "circle", 2: "checkmark.circle", 3: "exclamationmark.triangle"]
    @State private var workItemPriorities: [Int: String] = [0: "High", 1: "Med", 2: "Low", 3: "High"]
    @State private var workItemTexts: [Int: String] = [:]
    @State private var meetingTitles: [Int: String] = [0: "Team Standup", 1: ""]
    @State private var meetingKeyPoints: [Int: String] = [:]
    @State private var meetingActionItems: [Int: String] = [:]
    
    // Daily Check-in section state
    @State private var selectedMood: String? = nil
    @State private var highlightText: String = ""
    @State private var overviewText: String = ""
    
    // Personal Growth section state
    @State private var reflectionsText: String = ""
    @State private var achievementsText: String = ""
    @State private var challengesText: String = ""
    @State private var goalsText: String = ""
    
    // Well-being section state
    @State private var energyLevel: Double = 3.0
    @State private var physicalActivityText: String = ""
    @State private var mentalHealthText: String = ""
    
    // Creativity & Learning section state
    @State private var ideasText: String = ""
    @State private var learningText: String = ""
    @State private var projectsText: String = ""
    @State private var mediaItems: [Int: (title: String, author: String)] = [:]
    @State private var mediaStatus: [Int: String] = [:]
    
    // Social section state
    @State private var interactionPeople: [Int: String] = [:]
    @State private var interactionNotes: [Int: String] = [:]
    @State private var relationshipText: String = ""
    @State private var socialEventsText: String = ""
    
    // Work and Career section state
    @State private var challengesWorkText: String = ""
    @State private var winsText: String = ""
    @State private var workIdeasText: String = ""
    
    enum JournalSection: String, CaseIterable, Identifiable {
        case dailyCheckIn = "Daily Check-in"
        case personalGrowth = "Personal Growth"
        case wellbeing = "Well-being"
        case creativityLearning = "Creativity & Learning"
        case social = "Social"
        case workCareer = "Work and Career"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .dailyCheckIn: return "calendar.badge.clock"
            case .personalGrowth: return "chart.line.uptrend.xyaxis"
            case .wellbeing: return "heart.fill"
            case .creativityLearning: return "lightbulb.fill"
            case .social: return "person.2.fill"
            case .workCareer: return "briefcase.fill"
            }
        }
    }
    
    // MARK: - Reusable Components
    
    /// Standard journal text editor with consistent styling and local state
    private func JournalTextEditor(title: String, placeholder: String = "", text: Binding<String>, height: CGFloat = 80) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextEditor(text: text)
                .frame(minHeight: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.secondary)
                                .padding(.leading, 5)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
    }
    
    /// Reusable section container with calendar-style appearance
    private func SectionContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    /// Reusable add button with app-consistent styling
    private func AddButton(label: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus")
                Text(label)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var contentView: some View {
        Group {
            if viewModel.selectedDate == nil {
                emptyStateView
            } else if viewModel.isLoading {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else {
                journalEntryView
            }
        }
    }
    
    private var emptyStateView: some View {
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
                viewModel.openTodaysEntry()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let date = viewModel.selectedDate {
                Text(viewModel.formatDate(date))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text("Error loading entry")
                .font(.title)
                .fontWeight(.medium)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 16) {
                Button("Try Again") {
                    if let date = viewModel.selectedDate {
                        viewModel.loadContent(for: date)
                    }
                }
                .buttonStyle(.bordered)
                
                if let date = viewModel.selectedDate {
                    Button("Create New Entry") {
                        viewModel.createEntry(for: date)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var journalEntryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            dateHeaderView
            
            Divider().opacity(0.5)
            
            if viewModel.isEditing {
                editView
            } else {
                tabbedJournalView
            }
        }
        .padding()
    }
    
    private var tabbedJournalView: some View {
        VStack(spacing: 0) {
            sectionTabBar
                .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            
            Divider().opacity(0.5)
            
            // Replace TabView with custom view switching implementation
            VStack {
                switch selectedTab {
                case .dailyCheckIn:
                    dailyCheckInView
                case .personalGrowth:
                    personalGrowthView
                case .wellbeing:
                    wellbeingView
                case .creativityLearning:
                    creativityLearningView
                case .social:
                    socialView
                case .workCareer:
                    workCareerView
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    private var sectionTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(JournalSection.allCases) { section in
                    Button(action: {
                        selectedTab = section
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: section.iconName)
                                .font(.system(size: 16))
                            
                            Text(section.rawValue)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            selectedTab == section ?
                            Color(NSColor.controlBackgroundColor) :
                            Color.clear
                        )
                        .contentShape(Rectangle())
                    }
                    .foregroundColor(selectedTab == section ?
                                    .primary :
                                    .secondary)
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal, -8)
    }
    
    // MARK: - Section Views
    
    private var dailyCheckInView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Daily Check-in")
                
                SectionContainer {
                    // Mood selection with app-consistent styling
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            ForEach(["😔", "😕", "😐", "🙂", "😊"], id: \.self) { emoji in
                                Button(action: {
                                    selectedMood = emoji
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 30))
                                        .opacity(selectedMood == emoji ? 1.0 : 0.7)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Highlight with local state
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Highlight")
                            .font(.headline)
                        
                        TextField("Best moment of the day", text: $highlightText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.bottom, 8)
                    }
                    
                    JournalTextEditor(
                        title: "Overview",
                        placeholder: "Write about your day...",
                        text: $overviewText,
                        height: 120
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private var personalGrowthView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Personal Growth")
                
                SectionContainer {
                    JournalTextEditor(
                        title: "Reflections",
                        placeholder: "What insights or realizations did you have today?",
                        text: $reflectionsText,
                        height: 100
                    )
                    
                    JournalTextEditor(
                        title: "Achievements",
                        placeholder: "What did you accomplish today?",
                        text: $achievementsText
                    )
                    
                    JournalTextEditor(
                        title: "Challenges",
                        placeholder: "What difficulties did you face?",
                        text: $challengesText
                    )
                    
                    JournalTextEditor(
                        title: "Goals",
                        placeholder: "What progress did you make on your goals? Any new goals?",
                        text: $goalsText
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private var wellbeingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Well-being")
                
                SectionContainer {
                    // Energy Level with standard slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Energy Level")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(energyLevel))/5")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Low")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Slider(value: $energyLevel, in: 1...5, step: 1)
                                .padding(.horizontal)
                            
                            Text("High")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    JournalTextEditor(
                        title: "Physical Activity",
                        placeholder: "Exercise, movement, steps taken today...",
                        text: $physicalActivityText
                    )
                    
                    JournalTextEditor(
                        title: "Mental Health",
                        placeholder: "Stress level, thoughts, emotions...",
                        text: $mentalHealthText
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private var creativityLearningView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Creativity & Learning")
                
                SectionContainer {
                    JournalTextEditor(
                        title: "Ideas & Inspiration",
                        placeholder: "New thoughts or creative ideas that came to mind...",
                        text: $ideasText
                    )
                    
                    JournalTextEditor(
                        title: "Learning Log",
                        placeholder: "What did you learn today?",
                        text: $learningText
                    )
                    
                    // Books/Media with List Interface and local state
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Books/Media")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                HStack {
                                    Image(systemName: ["book", "film", "music.note"][index % 3])
                                        .foregroundColor(.primary)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        TextField("Title", text: Binding(
                                            get: { self.mediaItems[index]?.title ?? "" },
                                            set: {
                                                let author = self.mediaItems[index]?.author ?? ""
                                                self.mediaItems[index] = (title: $0, author: author)
                                            }
                                        ))
                                        .textFieldStyle(.roundedBorder)
                                        
                                        TextField("Author/Creator", text: Binding(
                                            get: { self.mediaItems[index]?.author ?? "" },
                                            set: {
                                                let title = self.mediaItems[index]?.title ?? ""
                                                self.mediaItems[index] = (title: title, author: $0)
                                            }
                                        ))
                                        .font(.caption)
                                        .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status menu with local state
                                    Menu {
                                        Button(action: { mediaStatus[index] = "In Progress" }) {
                                            Label("In Progress", systemImage: "book")
                                        }
                                        Button(action: { mediaStatus[index] = "Completed" }) {
                                            Label("Completed", systemImage: "checkmark.circle")
                                        }
                                        Button(action: { mediaStatus[index] = "Want to Read/Watch" }) {
                                            Label("Want to Read/Watch", systemImage: "heart")
                                        }
                                    } label: {
                                        Text(mediaStatus[index] ?? "Status")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                                            .cornerRadius(4)
                                    }
                                    .menuStyle(.borderlessButton)
                                }
                                .padding(8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            
                            AddButton(label: "Add media item")
                        }
                    }
                    
                    JournalTextEditor(
                        title: "Projects",
                        placeholder: "Updates on personal projects...",
                        text: $projectsText
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private var socialView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Social")
                
                SectionContainer {
                    // Meaningful Interactions with local state
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meaningful Interactions")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<2, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("Person", text: Binding(
                                        get: { interactionPeople[index] ?? "" },
                                        set: { interactionPeople[index] = $0 }
                                    ))
                                    .font(.subheadline.bold())
                                    .textFieldStyle(.roundedBorder)
                                    
                                    TextField("What made this interaction meaningful?", text: Binding(
                                        get: { interactionNotes[index] ?? "" },
                                        set: { interactionNotes[index] = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                                .padding(8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            
                            AddButton(label: "Add interaction")
                        }
                    }
                    
                    JournalTextEditor(
                        title: "Relationship Updates",
                        placeholder: "Changes or notes about relationships...",
                        text: $relationshipText
                    )
                    
                    JournalTextEditor(
                        title: "Social Events",
                        placeholder: "Gatherings, meetups, outings...",
                        text: $socialEventsText
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private var workCareerView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Work and Career")
                
                SectionContainer {
                    // Work Items with interactive status and priority
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Work Items")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { index in
                                HStack(alignment: .center, spacing: 12) {
                                    // Status indicator with interactive menu
                                    Menu {
                                        Button(action: {
                                            workItemStatuses[index] = "circle"
                                        }) {
                                            Label("To Do", systemImage: "circle")
                                        }
                                        
                                        Button(action: {
                                            workItemStatuses[index] = "arrow.clockwise"
                                        }) {
                                            Label("In Progress", systemImage: "arrow.clockwise")
                                        }
                                        
                                        Button(action: {
                                            workItemStatuses[index] = "checkmark.circle"
                                        }) {
                                            Label("Complete", systemImage: "checkmark.circle")
                                        }
                                        
                                        Button(action: {
                                            workItemStatuses[index] = "exclamationmark.triangle"
                                        }) {
                                            Label("Blocked", systemImage: "exclamationmark.triangle")
                                        }
                                    } label: {
                                        Image(systemName: workItemStatuses[index] ?? statusIcon(for: index))
                                            .foregroundColor(statusColor(for: index))
                                    }
                                    .menuStyle(.borderlessButton)
                                    
                                    // Task description - interactive text field
                                    TextField("Task description", text: Binding(
                                        get: { self.workItemTexts[index] ?? self.workItemExample(for: index) },
                                        set: { self.workItemTexts[index] = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    
                                    // Priority tag with interactive menu
                                    Menu {
                                        Button(action: {
                                            workItemPriorities[index] = "High"
                                        }) {
                                            Label("High", systemImage: "flag.fill")
                                                .foregroundColor(.red)
                                        }
                                        
                                        Button(action: {
                                            workItemPriorities[index] = "Med"
                                        }) {
                                            Label("Medium", systemImage: "flag.fill")
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Button(action: {
                                            workItemPriorities[index] = "Low"
                                        }) {
                                            Label("Low", systemImage: "flag.fill")
                                                .foregroundColor(.blue)
                                        }
                                    } label: {
                                        Text(workItemPriorities[index] ?? priorityText(for: index))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                                            .cornerRadius(4)
                                    }
                                    .menuStyle(.borderlessButton)
                                }
                                .padding(8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            
                            AddButton(label: "Add work item")
                        }
                    }
                    
                    // Meetings with structured interface and local state
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meetings")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<2, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        TextField("Meeting Title", text: Binding(
                                            get: { meetingTitles[index] ?? (index == 0 ? "Team Standup" : "") },
                                            set: { meetingTitles[index] = $0 }
                                        ))
                                        .font(.headline)
                                        .textFieldStyle(.roundedBorder)
                                        
                                        Spacer()
                                        
                                        Text(index == 0 ? "10:00 AM" : "2:30 PM")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Divider().opacity(0.5)
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Image(systemName: "list.bullet")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Key Points")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            TextField("Notes", text: Binding(
                                                get: { meetingKeyPoints[index] ?? "" },
                                                set: { meetingKeyPoints[index] = $0 }
                                            ))
                                            .textFieldStyle(.roundedBorder)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Image(systemName: "checkmark")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Action Items")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            TextField("Follow-ups", text: Binding(
                                                get: { meetingActionItems[index] ?? "" },
                                                set: { meetingActionItems[index] = $0 }
                                            ))
                                            .textFieldStyle(.roundedBorder)
                                        }
                                    }
                                }
                                .padding(8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                            
                            AddButton(label: "Add meeting")
                        }
                    }
                    
                    JournalTextEditor(
                        title: "Challenges",
                        placeholder: "Work-specific obstacles or problems...",
                        text: $challengesWorkText
                    )
                    
                    JournalTextEditor(
                        title: "Wins",
                        placeholder: "Professional achievements or progress...",
                        text: $winsText
                    )
                    
                    JournalTextEditor(
                        title: "Work Ideas",
                        placeholder: "Improvements or solutions that came to mind...",
                        text: $workIdeasText
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
    
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                Text(viewModel.fileContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                Button("Edit") {
                    viewModel.startEditing()
                }
                .keyboardShortcut("e", modifiers: [.command])
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
    
    private var editView: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $viewModel.editedContent)
                .font(.body)
                .focused($isTextFieldFocused)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollContentBackground(.hidden)
                .background(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .padding(.bottom, 8)
            
            HStack {
                Button("Cancel") {
                    viewModel.cancelEditing()
                    isTextFieldFocused = false
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut("s", modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
    }
    
    private var dateHeaderView: some View {
        HStack {
            if let date = viewModel.selectedDate {
                VStack(alignment: .leading) {
                    Text(viewModel.formatDate(date))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.formatDay(date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No Date Selected")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.openTodaysEntry()
                }) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Go to today's entry")
                
                if let date = viewModel.selectedDate, Calendar.current.isDateInToday(date) == false {
                    Button(action: {
                        viewModel.createEntry(for: date)
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Create new entry for this date")
                }
            }
        }
    }
    
    /// Handles saving changes using the view model
    private func saveChanges() {
        Task {
            do {
                try await viewModel.saveEdits()
                isTextFieldFocused = false
            } catch {
                // Error is already handled by the view model
            }
        }
    }
    
    // Helper functions for work items
    private func statusIcon(for index: Int) -> String {
        switch index {
        case 0: return "arrow.clockwise"  // In Progress
        case 1: return "circle"           // To Do
        case 2: return "checkmark.circle" // Complete
        case 3: return "exclamationmark.triangle" // Blocked
        default: return "circle"
        }
    }
    
    private func statusColor(for index: Int) -> Color {
        let status = workItemStatuses[index] ?? statusIcon(for: index)
        
        switch status {
        case "arrow.clockwise": return .blue    // In Progress
        case "circle": return .gray             // To Do
        case "checkmark.circle": return .green  // Complete
        case "exclamationmark.triangle": return .orange // Blocked
        default: return .gray
        }
    }
    
    private func priorityText(for index: Int) -> String {
        switch index {
        case 0, 3: return "High"
        case 1: return "Med"
        case 2: return "Low"
        default: return "Med"
        }
    }
    
    private func priorityColorForText(_ text: String) -> Color {
        switch text {
        case "High": return .red
        case "Med": return .orange
        case "Low": return .blue
        default: return .gray
        }
    }
    
    private func priorityColor(for index: Int) -> Color {
        let priority = workItemPriorities[index] ?? priorityText(for: index)
        return priorityColorForText(priority)
    }
    
    private func workItemExample(for index: Int) -> String {
        switch index {
        case 0: return "Finish project proposal"
        case 1: return "Research new framework"
        case 2: return "Update documentation"
        case 3: return "Fix server issue - waiting on IT"
        default: return ""
        }
    }
    
    // Helper function for priority colors (used by other sections)
    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 1: return .red
        case 2: return .orange
        case 3: return .blue
        default: return .gray
        }
    }
}
