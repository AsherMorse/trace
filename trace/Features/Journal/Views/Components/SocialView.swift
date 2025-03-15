import SwiftUI

struct SocialView: View {
    @State private var relationshipUpdates: String = ""
    @State private var socialEvents: String = ""
    @State private var interactions: [Interaction] = []
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
                
                JournalTextEditor(
                    title: "Social Events",
                    text: $socialEvents
                )
                .frame(minHeight: 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    }
    
    private func resetNewInteractionFields() {
        newInteractionPerson = ""
        newInteractionNotes = ""
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
    SocialView()
        .frame(width: 600)
        .padding()
} 