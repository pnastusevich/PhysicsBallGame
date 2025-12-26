import SwiftUI
import PhotosUI
import Combine
import AVFoundation
import Photos

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: Image?
    @Published var profileImageData: Data?
    @Published var showPermissionAlert = false
    @Published var bestScore: Int = 0
    @Published var showImagePicker = false
    @Published var showPhotoLibraryPicker = false
    @Published var showCameraPicker = false
    @Published var permissionMessage = ""
    private var shouldOpenPhotoLibraryAfterPermission = false
    
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
    
    func userNameChanged(_ newValue: String) {
        userName = newValue
        saveSettings()
    }
    
    func openCamera() async {
        let hasPermission = await photoLibraryService.checkCameraPermission()
        if hasPermission {
            showCameraPicker = true
            logerService.log("Camera Picker Opened", level: .info)
        } else {
            permissionMessage = "Для использования камеры необходимо разрешить доступ в настройках приложения."
            showPermissionAlert = true
            logerService.log("Camera permission denied", level: .warning)
        }
    }
    
    func openPhotoLibrary() async {
        let hasPermission = await photoLibraryService.requestPermission()
        if hasPermission {
            showPhotoLibraryPicker = true
            logerService.log("Photo Library Picker Opened", level: .info)
        } else {
            permissionMessage = "Для доступа к галерее необходимо разрешить доступ в настройках приложения."
            shouldOpenPhotoLibraryAfterPermission = true
            showPermissionAlert = true
            logerService.log("Photo library permission denied", level: .warning)
        }
    }
    
    func checkAndOpenPhotoLibraryIfNeeded() async {
        if shouldOpenPhotoLibraryAfterPermission {
            let hasPermission = photoLibraryService.checkPermission()
            if hasPermission {
                shouldOpenPhotoLibraryAfterPermission = false
                showPhotoLibraryPicker = true
                logerService.log("Photo Library Picker Opened after permission granted", level: .info)
            }
        }
    }
    
    func loadPhoto(from item: PhotosPickerItem) async {
        do {
            if let data = try await photoLibraryService.loadImageData(from: item) {
                profileImageData = data
                profileImage = photoLibraryService.createImage(from: data)
                saveSettings()
                logerService.log("Profile photo selected and saved", level: .info)
            }
        } catch {
            logerService.logAsyncOperationError(operation: "Load profile photo", error: error.localizedDescription)
        }
    }
    
    func updateAvatar(_ image: UIImage?) {
        guard let image = image else {
            profileImage = nil
            profileImageData = nil
            saveSettings()
            return
        }
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            profileImageData = imageData
            profileImage = Image(uiImage: image)
            saveSettings()
            logerService.log("Profile photo updated from camera", level: .info)
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func cancelPermissionRequest() {
        shouldOpenPhotoLibraryAfterPermission = false
    }
    
    deinit {
        cancellables.removeAll()
    }
}

