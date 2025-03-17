import SwiftUI

@Observable
class DailyCheckInViewModel {
    var mood: String = ""
    var todaysHighlight: String = ""
    var dailyOverview: String = ""
    var id = UUID()
    
    var isValid: Bool {
        !mood.isEmpty
    }
    
    init(entry: JournalDailyCheckIn? = nil) {
        if let entry = entry {
            self.mood = entry.mood
            self.todaysHighlight = entry.todaysHighlight
            self.dailyOverview = entry.dailyOverview
        }
    }
    
    func toModel() -> JournalDailyCheckIn {
        var model = JournalDailyCheckIn()
        model.mood = mood
        model.todaysHighlight = todaysHighlight
        model.dailyOverview = dailyOverview
        return model
    }
    
    func reset() {
        mood = ""
        todaysHighlight = ""
        dailyOverview = ""
    }
} 