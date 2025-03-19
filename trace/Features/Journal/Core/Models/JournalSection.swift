import SwiftUI

enum JournalSection: String, CaseIterable, Identifiable {
    case dailyCheckIn = "Daily Check-in"
    case personalGrowth = "Personal Growth"
    case wellbeing = "Well-being"
    case creativityLearning = "Creativity & Learning"
    case social = "Social"
    case workCareer = "Work and Career"
    
    var id: String { rawValue }
    
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
