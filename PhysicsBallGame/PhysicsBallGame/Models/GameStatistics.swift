import Foundation

struct DifficultyStatistics: Codable {
    var cubesCaught: Int = 0
    var maxTime: Double = 0.0
    var maxScore: Int = 0
    
    mutating func update(cubesCaught: Int, time: Double, score: Int) {
        self.cubesCaught += cubesCaught
        self.maxTime = max(self.maxTime, time)
        self.maxScore = max(self.maxScore, score)
    }
}

struct GameStatistics: Codable {
    var easy: DifficultyStatistics = DifficultyStatistics()
    var normal: DifficultyStatistics = DifficultyStatistics()
    var hard: DifficultyStatistics = DifficultyStatistics()
    
    mutating func update(difficulty: GameDifficulty, cubesCaught: Int, time: Double, score: Int) {
        switch difficulty {
        case .easy:
            easy.update(cubesCaught: cubesCaught, time: time, score: score)
        case .normal:
            normal.update(cubesCaught: cubesCaught, time: time, score: score)
        case .hard:
            hard.update(cubesCaught: cubesCaught, time: time, score: score)
        }
    }
    
    func getStatistics(for difficulty: GameDifficulty) -> DifficultyStatistics {
        switch difficulty {
        case .easy:
            return easy
        case .normal:
            return normal
        case .hard:
            return hard
        }
    }
}

enum Achievement: String, CaseIterable, Codable {
    case firstCatch = "first_catch"
    case catch10 = "catch_10"
    case catch50 = "catch_50"
    case catch100 = "catch_100"
    case score10 = "score_10"
    case score50 = "score_50"
    case score100 = "score_100"
    case time20 = "time_20"
    case time30 = "time_30"
    case perfectGame = "perfect_game"
    
    var title: String {
        switch self {
        case .firstCatch:
            return "First Catch"
        case .catch10:
            return "Beginner"
        case .catch50:
            return "Hunter"
        case .catch100:
            return "Master"
        case .score10:
            return "First Ten"
        case .score50:
            return "Fifty"
        case .score100:
            return "Hundred"
        case .time20:
            return "Endurance"
        case .time30:
            return "Tireless"
        case .perfectGame:
            return "Perfect Game"
        }
    }
    
    var description: String {
        switch self {
        case .firstCatch:
            return "Catch your first cube"
        case .catch10:
            return "Catch 10 cubes"
        case .catch50:
            return "Catch 50 cubes"
        case .catch100:
            return "Catch 100 cubes"
        case .score10:
            return "Score 10 points"
        case .score50:
            return "Score 50 points"
        case .score100:
            return "Score 100 points"
        case .time20:
            return "Play for 20 seconds"
        case .time30:
            return "Play for 30 seconds"
        case .perfectGame:
            return "Score 50+ points on hard level"
        }
    }
    
    var icon: String {
        switch self {
        case .firstCatch:
            return "star.fill"
        case .catch10:
            return "star.circle.fill"
        case .catch50:
            return "star.square.fill"
        case .catch100:
            return "crown.fill"
        case .score10:
            return "bolt.fill"
        case .score50:
            return "trophy.fill"
        case .score100:
            return "trophy.circle.fill"
        case .time20:
            return "clock.fill"
        case .time30:
            return "clock.circle.fill"
        case .perfectGame:
            return "flame.fill"
        }
    }
}

