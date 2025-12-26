import Foundation

enum GameStage {
    case notStarted
    case playing
    case finished
}

enum GameDifficulty: String, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var gravity: Double {
        switch self {
        case .easy:
            return 1.5
        case .normal:
            return 1.7
        case .hard:
            return 2.0
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

