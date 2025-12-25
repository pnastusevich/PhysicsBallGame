import SwiftUI
import PhotosUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: Image?
    @Published var profileImageData: Data?
    @Published var showPermissionAlert = false
    @Published var bestScore: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let userNameKey = "SettingsUserName"
    private let profileImageKey = "SettingsProfileImage"
    private let bestScoreKey = "GameBestScore"
    private let photoLibraryService = PhotoLibraryService.shared
    private let logerService = LoggerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var hasPhotoPermission: Bool {
        photoLibraryService.hasPermission
    }
    
    init() {
        loadSettings()
        loadBestScore()
        
        photoLibraryService.$hasPermission
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.loadBestScore()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadBestScore() {
        bestScore = userDefaults.integer(forKey: bestScoreKey)
    }
    
    func loadSettings() {
        userName = userDefaults.string(forKey: userNameKey) ?? ""
        
        if let imageData = userDefaults.data(forKey: profileImageKey),
           let uiImage = UIImage(data: imageData) {
            profileImage = Image(uiImage: uiImage)
            profileImageData = imageData
        }
    }
    
    func saveSettings() {
        userDefaults.set(userName, forKey: userNameKey)
        
        if let imageData = profileImageData {
            userDefaults.set(imageData, forKey: profileImageKey)
        }
        
        logerService.log("Settings saved: userName=\(userName.isEmpty ? "empty" : userName), hasProfileImage=\(profileImageData != nil)", level: .info)
    }
    
    func handlePhotoSelection(_ item: PhotosPickerItem?) {
        selectedPhoto = item
        
        guard let item = item else {
            profileImage = nil
            profileImageData = nil
            saveSettings()
            return
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                if let data = try await photoLibraryService.loadImageData(from: item) {
                    await MainActor.run {
                        self.profileImageData = data
                        self.profileImage = photoLibraryService.createImage(from: data)
                        self.saveSettings()
                        self.logerService.log("Profile photo selected and saved", level: .info)
                    }
                }
            } catch {
                await MainActor.run {
                    self.logerService.logAsyncOperationError(operation: "Load profile photo", error: error.localizedDescription)
                }
            }
        }
    }
    
    func userNameChanged(_ newValue: String) {
        userName = newValue
        saveSettings()
    }
    
    func requestPhotoLibraryPermission() async {
        let granted = await photoLibraryService.requestPermission()
        
        if !granted {
            showPermissionAlert = true
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}

