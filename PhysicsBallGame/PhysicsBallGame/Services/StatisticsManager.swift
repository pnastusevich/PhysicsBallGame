import SwiftUI
import Combine

@MainActor
final class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var currentVelocity: CGVector = .zero
    
    @Published var maxHeight: CGFloat = 0
    
    @Published var bounceCount: Int = 0
    
    @Published var heightHistory: [CGFloat] = []
    
    private init() {}
    
    func updateFromSimulation(
        velocity: CGVector,
        currentHeight: CGFloat,
        maxHeight: CGFloat,
        bounceCount: Int
    ) {
        currentVelocity = velocity
        
        self.maxHeight = maxHeight
        
        self.bounceCount = bounceCount
        
        heightHistory.append(currentHeight)
        if heightHistory.count > 50 {
            heightHistory.removeFirst()
        }
    }
}

