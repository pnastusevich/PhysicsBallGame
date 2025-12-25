import SwiftUI

@main
struct PhysicsBallGameApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            coordinator.makeTabView()
        }
    }
}
