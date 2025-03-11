import SwiftUI
import Combine

class JournalViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var fileContent: String = ""
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let fileManager = FileManager.default
    private let calendar = Calendar.current
    
    private var journalFolder: URL? {
        return FolderManager.shared.selectedFolderURL
    }
    
    init() {
        $selectedDate
            .dropFirst()
            .sink { [weak self] date in
                self?.loadContent(for: date)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func resetFolderSelection() {
        FolderManager.shared.resetFolderSelection()

        selectedDate = nil
        fileContent = ""
        hasError = false
    }
    
    func loadContent(for date: Date?) {
        guard let date = date else {
            fileContent = ""
            hasError = false
            return
        }
        
        isLoading = true
        hasError = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let url = self.fileURLFor(date: date),
               let content = try? String(contentsOf: url, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.fileContent = content
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.fileContent = ""
                    self.hasError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func createEntry(for date: Date) {
        guard let folder = ensureJournalFolder() else {
            hasError = true
            return
        }
        
        guard let fileURL = fileURLFor(date: date, createIntermediates: true) else {
            hasError = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let dateString = dateFormatter.string(from: date)
        let content = "# Journal Entry: \(dateString)\n\n"
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            self.fileContent = content
            hasError = false
        } catch {
            hasError = true
        }
    }
    
    func openTodaysEntry() {
        selectedDate = Date()
    }
    
    // MARK: - Private Methods
    
    private func fileURLFor(date: Date, createIntermediates: Bool = false) -> URL? {
        guard let components = calendar.dateComponents([.year, .month, .day], from: date).year,
              let month = calendar.dateComponents([.year, .month, .day], from: date).month,
              let day = calendar.dateComponents([.year, .month, .day], from: date).day,
              let baseFolder = journalFolder else {
            return nil
        }
        
        let yearString = String(components)
        let monthString = String(month)
        
        let yearFolder = baseFolder.appendingPathComponent(yearString)
        let monthFolder = yearFolder.appendingPathComponent(monthString)
        
        if createIntermediates {
            do {
                try fileManager.createDirectory(at: monthFolder, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        
        return monthFolder.appendingPathComponent("\(day).md")
    }
    
    private func ensureJournalFolder() -> URL? {
        guard let folder = journalFolder else { return nil }
        
        if !fileManager.fileExists(atPath: folder.path) {
            do {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        
        return folder
    }
}