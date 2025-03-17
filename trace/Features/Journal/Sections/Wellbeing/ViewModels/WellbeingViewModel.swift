import SwiftUI

@Observable
final class WellbeingViewModel {
    var energyLevel: Int = 5
    var physicalActivity: String = ""
    var mentalHealth: String = ""
    var id = UUID()
    
    var isValid: Bool {
        !physicalActivity.isEmpty || !mentalHealth.isEmpty
    }
    
    init(entry: JournalWellbeing? = nil) {
        if let entry = entry {
            self.energyLevel = entry.energyLevel
            self.physicalActivity = entry.physicalActivity
            self.mentalHealth = entry.mentalHealth
        }
    }
    
    func toModel() -> JournalWellbeing {
        var model = JournalWellbeing()
        model.energyLevel = energyLevel
        model.physicalActivity = physicalActivity
        model.mentalHealth = mentalHealth
        return model
    }
    
    func reset() {
        energyLevel = 5
        physicalActivity = ""
        mentalHealth = ""
    }
} 
