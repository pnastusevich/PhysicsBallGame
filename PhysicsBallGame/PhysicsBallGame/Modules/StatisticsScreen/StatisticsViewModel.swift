import SwiftUI
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    private let statisticsManager = StatisticsManager.shared
    private let userDefaults = UserDefaults.standard
    private let gameStatisticsKey = "GameStatistics"
    private let achievementsKey = "Achievements"
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var gameStatistics: GameStatistics = GameStatistics()
    @Published private(set) var achievements: Set<Achievement> = []
    
    var currentVelocity: CGVector {
        statisticsManager.currentVelocity
    }
    
    var maxHeight: CGFloat {
        statisticsManager.maxHeight
    }
    
    var bounceCount: Int {
        statisticsManager.bounceCount
    }
    
    var heightHistory: [CGFloat] {
        statisticsManager.heightHistory
    }
    
    var velocityMagnitude: Double {
        sqrt(
            pow(currentVelocity.dx, 2) +
            pow(currentVelocity.dy, 2)
        )
    }
    
    var formattedVelocity: String {
        String(format: "%.2f px/s", velocityMagnitude)
    }
    
    var formattedMaxHeight: String {
        String(format: "%.2f px", maxHeight)
    }
    
    init() {
        gameStatistics = loadGameStatistics()
        achievements = loadAchievements()
        
        statisticsManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.gameStatistics = self?.loadGameStatistics() ?? GameStatistics()
                    self?.achievements = self?.loadAchievements() ?? []
                }
            }
            .store(in: &cancellables)
    }
    
    func loadGameStatistics() -> GameStatistics {
        guard let data = userDefaults.data(forKey: gameStatisticsKey),
              let statistics = try? JSONDecoder().decode(GameStatistics.self, from: data) else {
            return GameStatistics()
        }
        return statistics
    }
    
    func loadAchievements() -> Set<Achievement> {
        guard let data = userDefaults.data(forKey: achievementsKey),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return []
        }
        return Set(achievements)
    }
    
    func refresh() {
        Task { @MainActor in
            gameStatistics = loadGameStatistics()
            achievements = loadAchievements()
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}
