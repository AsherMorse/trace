import SwiftUI

@Observable
final class PersonalGrowthViewModel {
    var reflections: String = ""
    var achievements: String = ""
    var challenges: String = ""
    var goals: String = ""
    var id = UUID()
    
    var isValid: Bool {
        !reflections.isEmpty || !achievements.isEmpty || !challenges.isEmpty
    }
    
    init(entry: JournalPersonalGrowth? = nil) {
        if let entry = entry {
            self.reflections = entry.reflections
            self.achievements = entry.achievements
            self.challenges = entry.challenges
            self.goals = entry.goals
        }
    }
    
    func toModel() -> JournalPersonalGrowth {
        var model = JournalPersonalGrowth()
        model.reflections = reflections
        model.achievements = achievements
        model.challenges = challenges
        model.goals = goals
        return model
    }
    
    func reset() {
        reflections = ""
        achievements = ""
        challenges = ""
        goals = ""
    }
} 