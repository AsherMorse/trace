import SwiftUI

@Observable
final class JournalCoordinatorViewModel {
    var dailyCheckInViewModel: DailyCheckInViewModel
    var personalGrowthVM: PersonalGrowthViewModel
    var wellbeingVM: WellbeingViewModel
    var creativityLearningVM: CreativityLearningViewModel
    var socialVM: SocialViewModel
    var workCareerVM: WorkCareerViewModel
    
    var selectedDate: Date?
    var error: Error?
    var isLoading = false
    var hasError: Bool = false
    var errorMessage: String?
    
    private let storageManager: JournalStorageManagerProtocol
    
    init(
        dailyCheckInVM: DailyCheckInViewModel = DailyCheckInViewModel(),
        personalGrowthVM: PersonalGrowthViewModel = PersonalGrowthViewModel(),
        wellbeingVM: WellbeingViewModel = WellbeingViewModel(),
        creativityLearningVM: CreativityLearningViewModel = CreativityLearningViewModel(),
        socialVM: SocialViewModel = SocialViewModel(),
        workCareerVM: WorkCareerViewModel = WorkCareerViewModel(),
        selectedDate: Date? = Date(),
        storageManager: JournalStorageManagerProtocol = JournalStorageManager()
    ) {
        self.dailyCheckInViewModel = dailyCheckInVM
        self.personalGrowthVM = personalGrowthVM
        self.wellbeingVM = wellbeingVM
        self.creativityLearningVM = creativityLearningVM
        self.socialVM = socialVM
        self.workCareerVM = workCareerVM
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
        entry.personalGrowth = personalGrowthVM.toModel()
        entry.wellbeing = wellbeingVM.toModel()
        entry.creativityLearning = creativityLearningVM.toModel()
        entry.social = socialVM.toModel()
        entry.workCareer = workCareerVM.toModel()
        
        return entry
    }
    
    private func updateViewModels(with entry: JournalEntry) {
        dailyCheckInViewModel = DailyCheckInViewModel(entry: entry.dailyCheckIn)
        personalGrowthVM = PersonalGrowthViewModel(entry: entry.personalGrowth)
        wellbeingVM = WellbeingViewModel(entry: entry.wellbeing)
        creativityLearningVM = CreativityLearningViewModel(entry: entry.creativityLearning)
        socialVM = SocialViewModel(entry: entry.social)
        workCareerVM = WorkCareerViewModel(entry: entry.workCareer)
    }
    
    private func resetViewModels() {
        dailyCheckInViewModel.reset()
        personalGrowthVM.reset()
        wellbeingVM.reset()
        creativityLearningVM.reset()
        socialVM.reset()
        workCareerVM.reset()
    }
    
    func sectionViewModel(for section: JournalSection) -> Any {
        switch section {
        case .dailyCheckIn:
            return dailyCheckInViewModel
        case .personalGrowth:
            return personalGrowthVM
        case .wellbeing:
            return wellbeingVM
        case .creativityLearning:
            return creativityLearningVM
        case .social:
            return socialVM
        case .workCareer:
            return workCareerVM
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
            return personalGrowthVM.isValid
        case .wellbeing:
            return wellbeingVM.isValid
        case .creativityLearning:
            return creativityLearningVM.isValid
        case .social:
            return socialVM.isValid
        case .workCareer:
            return workCareerVM.isValid
        }
    }
} 
