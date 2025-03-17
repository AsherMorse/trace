import SwiftUI

struct SocialView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var relationshipUpdates: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var socialEvents: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var interactions: [Interaction] = [] {
        didSet {
            updateViewModel()
        }
    }
    @State private var newInteractionPerson: String = ""
    @State private var newInteractionNotes: String = ""
    @State private var showingAddInteraction: Bool = false
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meaningful Interactions")
                        .font(.headline)
                    
                    if !interactions.isEmpty {
                        ForEach(interactions) { interaction in
                            InteractionRow(interaction: interaction)
                        }
                    }
                    
                    if showingAddInteraction {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Person", text: $newInteractionPerson)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Notes", text: $newInteractionNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Button("Add") {
                                    addInteraction()
                                }
                                .disabled(newInteractionPerson.isEmpty)
                                
                                Button("Cancel") {
                                    showingAddInteraction = false
                                    resetNewInteractionFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            showingAddInteraction = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Interaction")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                JournalTextEditor(
                    title: "Relationship Updates",
                    text: $relationshipUpdates
                )
                .frame(minHeight: 100)
                .onChange(of: relationshipUpdates) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Social Events",
                    text: $socialEvents
                )
                .frame(minHeight: 100)
                .onChange(of: socialEvents) { _, _ in
                    updateViewModel()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                loadFromViewModel()
            }
        }
    }
    
    private func addInteraction() {
        let interaction = Interaction(
            person: newInteractionPerson,
            notes: newInteractionNotes
        )
        interactions.append(interaction)
        showingAddInteraction = false
        resetNewInteractionFields()
        updateViewModel()
    }
    
    private func resetNewInteractionFields() {
        newInteractionPerson = ""
        newInteractionNotes = ""
    }
    
    private func updateViewModel() {
        var entry = viewModel.currentEntry ?? JournalEntry(date: viewModel.selectedDate ?? Date())
        
        let journalInteractions = interactions.map { interaction -> JournalInteraction in
            return JournalInteraction(
                person: interaction.person,
                notes: interaction.notes
            )
        }
        entry.social.meaningfulInteractions = journalInteractions
        entry.social.relationshipUpdates = relationshipUpdates
        entry.social.socialEvents = socialEvents
        
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            relationshipUpdates = entry.social.relationshipUpdates
            socialEvents = entry.social.socialEvents
            
            interactions = entry.social.meaningfulInteractions.map { item -> Interaction in
                return Interaction(
                    person: item.person,
                    notes: item.notes
                )
            }
        }
    }
}

struct Interaction: Identifiable {
    let id = UUID()
    var person: String
    var notes: String
    var date = Date()
}

struct InteractionRow: View {
    var interaction: Interaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(interaction.person)
                .font(.headline)
            
            if !interaction.notes.isEmpty {
                Text(interaction.notes)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    SocialView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
}
