import SwiftUI

@Observable
final class JournalCoordinatorViewModel {
    var dailyCheckInViewModel: DailyCheckInViewModel
    var personalGrowthViewModel: PersonalGrowthViewModel
    var wellbeingViewModel: WellbeingViewModel
    var creativityLearningViewModel: CreativityLearningViewModel
    var socialViewModel: SocialViewModel
    var workCareerViewModel: WorkCareerViewModel
    
    var selectedDate: Date?
    var error: Error?
    var isLoading = false
    var hasError: Bool = false
    var errorMessage: String?
    
    private let storageManager: JournalStorageManagerProtocol
    
    init(
        dailyCheckInViewModel: DailyCheckInViewModel = DailyCheckInViewModel(),
        personalGrowthViewModel: PersonalGrowthViewModel = PersonalGrowthViewModel(),
        wellbeingViewModel: WellbeingViewModel = WellbeingViewModel(),
        creativityLearningViewModel: CreativityLearningViewModel = CreativityLearningViewModel(),
        socialViewModel: SocialViewModel = SocialViewModel(),
        workCareerViewModel: WorkCareerViewModel = WorkCareerViewModel(),
        selectedDate: Date? = Date(),
        storageManager: JournalStorageManagerProtocol = JournalStorageManager()
    ) {
        self.dailyCheckInViewModel = dailyCheckInViewModel
        self.personalGrowthViewModel = personalGrowthViewModel
        self.wellbeingViewModel = wellbeingViewModel
        self.creativityLearningViewModel = creativityLearningViewModel
        self.socialViewModel = socialViewModel
        self.workCareerViewModel = workCareerViewModel
        self.selectedDate = selectedDate
        self.storageManager = storageManager
        
        if let date = selectedDate {
            Task {
                await loadEntry(for: date)
            }
        }
    }
    
    func loadEntry(for date: Date) async {
        guard FolderManager.shared.hasSelectedFolder else {
            handleError(JournalFileError.folderNotSelected)
            return
        }
        
        selectedDate = date
        isLoading = true
        hasError = false
        
        do {
            if storageManager.entryExists(for: date) {
                let entry = try await storageManager.loadEntry(for: date)
                updateViewModels(with: entry)
            } else {
                resetViewModels()
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func saveEntry() async {
        guard let date = selectedDate else { return }
        guard FolderManager.shared.hasSelectedFolder else {
            handleError(JournalFileError.folderNotSelected)
            return
        }
        
        isLoading = true
        
        do {
            let entry = createJournalEntry(for: date)
            try await storageManager.saveEntry(entry)
            isLoading = false
        } catch {
            handleError(error)
        }
    }
    
    func createNewEntry(for date: Date) async {
        guard FolderManager.shared.hasSelectedFolder else {
            handleError(JournalFileError.folderNotSelected)
            return
        }
        
        selectedDate = date
        isLoading = true
        
        do {
            resetViewModels()
            let entry = createJournalEntry(for: date)
            try await storageManager.saveEntry(entry)
            isLoading = false
        } catch {
            handleError(error)
        }
    }
    
    private func createJournalEntry(for date: Date) -> JournalEntry {
        var entry = JournalEntry(date: date)
        
        entry.dailyCheckIn = dailyCheckInViewModel.toModel()
        entry.personalGrowth = personalGrowthViewModel.toModel()
        entry.wellbeing = wellbeingViewModel.toModel()
        entry.creativityLearning = creativityLearningViewModel.toModel()
        entry.social = socialViewModel.toModel()
        entry.workCareer = workCareerViewModel.toModel()
        
        return entry
    }
    
    private func updateViewModels(with entry: JournalEntry) {
        dailyCheckInViewModel = DailyCheckInViewModel(entry: entry.dailyCheckIn)
        personalGrowthViewModel = PersonalGrowthViewModel(entry: entry.personalGrowth)
        wellbeingViewModel = WellbeingViewModel(entry: entry.wellbeing)
        creativityLearningViewModel = CreativityLearningViewModel(entry: entry.creativityLearning)
        socialViewModel = SocialViewModel(entry: entry.social)
        workCareerViewModel = WorkCareerViewModel(entry: entry.workCareer)
    }
    
    private func resetViewModels() {
        dailyCheckInViewModel.reset()
        personalGrowthViewModel.reset()
        wellbeingViewModel.reset()
        creativityLearningViewModel.reset()
        socialViewModel.reset()
        workCareerViewModel.reset()
    }
    
    func sectionViewModel(for section: JournalSection) -> Any {
        switch section {
        case .dailyCheckIn:
            return dailyCheckInViewModel
        case .personalGrowth:
            return personalGrowthViewModel
        case .wellbeing:
            return wellbeingViewModel
        case .creativityLearning:
            return creativityLearningViewModel
        case .social:
            return socialViewModel
        case .workCareer:
            return workCareerViewModel
        }
    }
    
    func handleError(_ error: Error) {
        self.error = error
        hasError = true
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    func hasContentFor(section: JournalSection) -> Bool {
        switch section {
        case .dailyCheckIn:
            return dailyCheckInViewModel.isValid
        case .personalGrowth:
            return personalGrowthViewModel.isValid
        case .wellbeing:
            return wellbeingViewModel.isValid
        case .creativityLearning:
            return creativityLearningViewModel.isValid
        case .social:
            return socialViewModel.isValid
        case .workCareer:
            return workCareerViewModel.isValid
        }
    }
} 
