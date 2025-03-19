import SwiftUI

@Observable
final class SocialViewModel {
    var meaningfulInteractions: [JournalInteraction] = []
    var relationshipUpdates: String = ""
    var socialEvents: String = ""
    var id = UUID()
    
    var newInteractionPerson: String = ""
    var newInteractionNotes: String = ""
    var showingAddInteraction: Bool = false
    
    var isValid: Bool {
        !relationshipUpdates.isEmpty || !socialEvents.isEmpty || !meaningfulInteractions.isEmpty
    }
    
    var canAddInteraction: Bool {
        !newInteractionPerson.isEmpty
    }
    
    init(entry: JournalSocial? = nil) {
        if let entry = entry {
            self.meaningfulInteractions = entry.meaningfulInteractions
            self.relationshipUpdates = entry.relationshipUpdates
            self.socialEvents = entry.socialEvents
        }
    }
    
    func toModel() -> JournalSocial {
        var model = JournalSocial()
        model.meaningfulInteractions = meaningfulInteractions
        model.relationshipUpdates = relationshipUpdates
        model.socialEvents = socialEvents
        return model
    }
    
    func reset() {
        meaningfulInteractions = []
        relationshipUpdates = ""
        socialEvents = ""
        resetNewInteractionFields()
    }
    
    func addInteraction() {
        guard !newInteractionPerson.isEmpty else { return }
        
        let interaction = JournalInteraction(
            person: newInteractionPerson,
            notes: newInteractionNotes
        )
        meaningfulInteractions.append(interaction)
        resetNewInteractionFields()
        showingAddInteraction = false
    }
    
    func resetNewInteractionFields() {
        newInteractionPerson = ""
        newInteractionNotes = ""
    }
} 
