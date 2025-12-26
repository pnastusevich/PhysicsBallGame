import SwiftUI
import PhotosUI
import Photos
import Combine
import AVFoundation

@MainActor
final class PhotoLibraryService: ObservableObject {
    static let shared = PhotoLibraryService()
    
    private let logerService = LoggerService.shared
    
    @Published var hasPermission = false
    
    private init() {
        _ = checkPermission()
    }
    
    func checkPermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let hasAccess = status == .authorized || status == .limited
        hasPermission = hasAccess
        return hasAccess
    }
    
    func requestPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            hasPermission = true
            logerService.log("Photo library permission already granted", level: .info)
            return true
            
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            let granted = newStatus == .authorized || newStatus == .limited
            hasPermission = granted
            
            if granted {
                logerService.log("Photo library permission granted", level: .info)
            } else {
                logerService.log("Photo library permission denied", level: .warning)
            }
            return granted
            
        case .denied, .restricted:
            hasPermission = false
            logerService.log("Photo library permission denied or restricted", level: .warning)
            return false
            
        @unknown default:
            hasPermission = false
            return false
        }
    }
    
    func loadImageData(from item: PhotosPickerItem) async throws -> Data? {
        logerService.logAsyncOperationStart(operation: "Load image from photo library")
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                logerService.logAsyncOperationError(operation: "Load image from photo library", error: "Failed to load image data")
                return nil
            }
            
            logerService.logAsyncOperationComplete(operation: "Load image from photo library")
            return data
        } catch {
            logerService.logAsyncOperationError(operation: "Load image from photo library", error: error.localizedDescription)
            throw error
        }
    }
    
    func createImage(from data: Data) -> Image? {
        guard let uiImage = UIImage(data: data) else {
            logerService.log("Failed to create UIImage from data", level: .error)
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    func checkCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}

