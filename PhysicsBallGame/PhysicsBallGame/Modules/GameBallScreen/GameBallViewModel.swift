import SwiftUI
import Combine

@MainActor
final class GameBallViewModel: ObservableObject {
    @Published var gameStage: GameStage = .notStarted
    @Published var selectedDifficulty: GameDifficulty = .normal
    @Published var ballState = BallState(position: CGPoint(x: 0, y: 0))
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var cubes: [Cube] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Double = 10.0
    @Published var isPressingLeft = false
    @Published var isPressingRight = false
    @Published var finalScore: Int = 0
    
    private let physicsEngine: PhysicsEngine
    private let config = PhysicsConfig.shared
    private let logerService = LoggerService.shared
    private var updateTask: Task<Void, Never>?
    private var lastUpdateTime: Date?
    private var screenWidth: CGFloat = 375
    private var screenHeight: CGFloat = 812
    private var gameAreaWidth: CGFloat = 375
    private var gameAreaHeight: CGFloat = 812
    private var hasInitializedScreenSize = false
    private var cancellables = Set<AnyCancellable>()
    private var cubesCaught: Int = 0
    private var lastCubeSpawnTime: Date = Date()
    private var gameStartTime: Date?
    private let horizontalMoveSpeed: CGFloat = 300.0
    private let cubeSizeTransitionDuration: TimeInterval = 90.0
    
    var cubeMoveSpeed: CGFloat {
        switch selectedDifficulty {
        case .easy:
            return 150.0
        case .normal:
            return 280.0
        case .hard:
            return 350.0
        }
    }
    
    var cubeSpawnInterval: TimeInterval {
        switch selectedDifficulty {
        case .easy:
            return 1.2
        case .normal:
            return 0.9
        case .hard:
            return 0.8
        }
    }
    private let userDefaults = UserDefaults.standard
    private let bestScoreKey = "GameBestScore"
    private let gameStatisticsKey = "GameStatistics"
    private let achievementsKey = "Achievements"
    private var gameStartTimestamp: Date?
    
    var ballRadius: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(15.0)
    }
    
    var ballSize: CGFloat {
        ballRadius * 2
    }
    
    var cubeHeight: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(30.0)
    }
    
    var initialCubeWidth: CGFloat {
        gameAreaWidth / 3.0
    }
    
    var finalCubeWidth: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(30.0)
    }
    
    func currentCubeWidth() -> CGFloat {
        guard let startTime = gameStartTime else {
            return initialCubeWidth
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let progress = min(elapsedTime / cubeSizeTransitionDuration, 1.0)
        
        return initialCubeWidth - (initialCubeWidth - finalCubeWidth) * CGFloat(progress)
    }
    
    var initialBallX: CGFloat {
        gameAreaWidth / 2
    }
    
    var initialBallY: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaledHeight(50.0)
    }
    
    var isBallAtInitialPosition: Bool {
        ballState.position.x == 0 && ballState.position.y == 0
    }
    
    func setScreenSize(width: CGFloat, height: CGFloat) {
        let isFirstTime = !hasInitializedScreenSize
        screenWidth = width
        screenHeight = height
        
        if isFirstTime {
            hasInitializedScreenSize = true
            resetBall()
        }
    }
    
    func setGameAreaSize(width: CGFloat, height: CGFloat) {
        gameAreaWidth = width
        gameAreaHeight = height
    }
    
    var showStartButton: Bool {
        !isRunning
    }
    
    var showResumeButton: Bool {
        isRunning && isPaused
    }
    
    var showPauseButton: Bool {
        isRunning && !isPaused
    }
    
    @Published var bestScore: Int = 0
    
    init() {
        physicsEngine = PhysicsEngine(config: config)
        ballState = BallState(position: CGPoint(x: 0, y: 0))
        loadBestScore()
        
        config.$shouldResetSimulation
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.resetGame()
                self.config.shouldResetSimulation = false
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
    
    private func loadBestScore() {
        bestScore = userDefaults.integer(forKey: bestScoreKey)
    }
    
    func startGame() {
        guard !isRunning else { return }
        
        config.gravity = selectedDifficulty.gravity
        
        gameStage = .playing
        isRunning = true
        isPaused = false
        let now = Date()
        lastUpdateTime = now
        lastCubeSpawnTime = now
        gameStartTime = now
        gameStartTimestamp = now
        score = 0
        cubesCaught = 0
        timeRemaining = 10.0
        cubes = []
        resetBall()
        
        spawnCube()
        
        logerService.logSimulationStart()
        
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            await self.runGameLoop()
        }
    }
    
    func pauseGame() {
        guard isRunning else { return }
        
        isPaused = true
        logerService.logSimulationPause()
    }
    
    func resumeGame() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        lastUpdateTime = Date()
    }
    
    func resetGame() {
        updateTask?.cancel()
        updateTask = nil
        gameStage = .notStarted
        isRunning = false
        isPaused = false
        cubes = []
        score = 0
        cubesCaught = 0
        timeRemaining = 10.0
        isPressingLeft = false
        isPressingRight = false
        gameStartTime = nil
        gameStartTimestamp = nil
        finalScore = 0
        resetBall()
        logerService.logSimulationReset()
    }
    
    private func endGame() {
        updateTask?.cancel()
        updateTask = nil
        isRunning = false
        isPaused = false
        finalScore = score
        
        if finalScore > bestScore {
            userDefaults.set(finalScore, forKey: bestScoreKey)
            userDefaults.synchronize()
            Task { @MainActor in
                self.loadBestScore()
            }
            NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        }
        
        let initialTime: Double = 10.0
        let totalTime = initialTime + (10.0 - timeRemaining)
        saveGameStatistics(cubesCaught: cubesCaught, time: totalTime, score: finalScore)
        
        checkAndSaveAchievements()
        
        gameStage = .finished
        logerService.log("Game ended with score: \(finalScore)", level: .info)
    }
    
    private func saveGameStatistics(cubesCaught: Int, time: Double, score: Int) {
        var statistics: GameStatistics
        if let data = userDefaults.data(forKey: gameStatisticsKey),
           let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            statistics = decoded
        } else {
            statistics = GameStatistics()
        }
        
        statistics.update(difficulty: selectedDifficulty, cubesCaught: cubesCaught, time: time, score: score)
        
        guard let encoded = try? JSONEncoder().encode(statistics) else {
            return
        }
        
        userDefaults.set(encoded, forKey: gameStatisticsKey)
        userDefaults.synchronize()
    }
    
    private func checkAndSaveAchievements() {
        var unlockedAchievements: Set<Achievement>
        if let data = userDefaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            unlockedAchievements = Set(decoded)
        } else {
            unlockedAchievements = []
        }
        
        let statistics: GameStatistics
        if let data = userDefaults.data(forKey: gameStatisticsKey),
           let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            statistics = decoded
        } else {
            statistics = GameStatistics()
        }
        
        let totalCubesCaught = statistics.easy.cubesCaught + statistics.normal.cubesCaught + statistics.hard.cubesCaught
        let totalMaxScore = max(statistics.easy.maxScore, statistics.normal.maxScore, statistics.hard.maxScore)
        let maxTime = max(statistics.easy.maxTime, statistics.normal.maxTime, statistics.hard.maxTime)
        
        if !unlockedAchievements.contains(.firstCatch) && cubesCaught > 0 {
            unlockedAchievements.insert(.firstCatch)
        }
        if !unlockedAchievements.contains(.catch10) && totalCubesCaught >= 10 {
            unlockedAchievements.insert(.catch10)
        }
        if !unlockedAchievements.contains(.catch50) && totalCubesCaught >= 50 {
            unlockedAchievements.insert(.catch50)
        }
        if !unlockedAchievements.contains(.catch100) && totalCubesCaught >= 100 {
            unlockedAchievements.insert(.catch100)
        }
        if !unlockedAchievements.contains(.score10) && totalMaxScore >= 10 {
            unlockedAchievements.insert(.score10)
        }
        if !unlockedAchievements.contains(.score50) && totalMaxScore >= 50 {
            unlockedAchievements.insert(.score50)
        }
        if !unlockedAchievements.contains(.score100) && totalMaxScore >= 100 {
            unlockedAchievements.insert(.score100)
        }
        if !unlockedAchievements.contains(.time20) && maxTime >= 20.0 {
            unlockedAchievements.insert(.time20)
        }
        if !unlockedAchievements.contains(.time30) && maxTime >= 30.0 {
            unlockedAchievements.insert(.time30)
        }
        if !unlockedAchievements.contains(.perfectGame) && selectedDifficulty == .hard && finalScore >= 50 {
            unlockedAchievements.insert(.perfectGame)
        }
        
        let array = Array(unlockedAchievements)
        if let encoded = try? JSONEncoder().encode(array) {
            userDefaults.set(encoded, forKey: achievementsKey)
            userDefaults.synchronize()
        }
    }
    
    func setPressingLeft(_ pressing: Bool) {
        isPressingLeft = pressing
    }
    
    func setPressingRight(_ pressing: Bool) {
        isPressingRight = pressing
    }
    
    private func resetBall() {
        ballState.reset(to: CGPoint(x: initialBallX, y: initialBallY))
        ballState.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func spawnCube() {
        let currentWidth = currentCubeWidth()
        let height = cubeHeight
        let cubeX = CGFloat.random(in: currentWidth / 2...gameAreaWidth - currentWidth / 2)
        let cubeY = gameAreaHeight - height / 2 - 20
        let cube = Cube(position: CGPoint(x: cubeX, y: cubeY), width: currentWidth, height: height)
        cubes.append(cube)
    }
    
    private func checkCubeCollisions() {
        let ballCenter = ballState.position
        let ballRadius = self.ballRadius
        
        for (index, cube) in cubes.enumerated().reversed() {
            let cubeCenter = cube.position
            let cubeHalfWidth = cube.width / 2
            let cubeHalfHeight = cube.height / 2
            
            let closestX = max(cubeCenter.x - cubeHalfWidth, min(ballCenter.x, cubeCenter.x + cubeHalfWidth))
            let closestY = max(cubeCenter.y - cubeHalfHeight, min(ballCenter.y, cubeCenter.y + cubeHalfHeight))
            
            let distanceX = ballCenter.x - closestX
            let distanceY = ballCenter.y - closestY
            let distanceSquared = distanceX * distanceX + distanceY * distanceY
            
            if distanceSquared < ballRadius * ballRadius {
                cubes.remove(at: index)
                score += 1
                cubesCaught += 1
                
                let bounceStrength: CGFloat = 200.0
                ballState.velocity.dy = -bounceStrength
                
                let horizontalBounce = (ballCenter.x - cubeCenter.x) / cubeHalfWidth * 50.0
                ballState.velocity.dx += horizontalBounce
                
                if cubesCaught % 2 == 0 {
                    timeRemaining += 1.0
                }
                
                break
            }
        }
    }
    
    private func runGameLoop() async {
        while !Task.isCancelled && isRunning {
            if isPaused {
                try? await Task.sleep(nanoseconds: 100_000_000)
                continue
            }
            
            guard let lastTime = lastUpdateTime else {
                lastUpdateTime = Date()
                try? await Task.sleep(nanoseconds: 16_000_000)
                continue
            }
            
            let currentTime = Date()
            var deltaTime = currentTime.timeIntervalSince(lastTime)
            deltaTime = min(deltaTime, 0.1)
            lastUpdateTime = currentTime
            
            timeRemaining -= deltaTime
            if timeRemaining <= 0 {
                timeRemaining = 0
                endGame()
                return
            }
            
            if currentTime.timeIntervalSince(lastCubeSpawnTime) >= cubeSpawnInterval {
                spawnCube()
                lastCubeSpawnTime = currentTime
            }
            
            if isPressingLeft {
                ballState.velocity.dx = -horizontalMoveSpeed
            } else if isPressingRight {
                ballState.velocity.dx = horizontalMoveSpeed
            } else {
                ballState.velocity.dx *= 0.95
                if abs(ballState.velocity.dx) < 10 {
                    ballState.velocity.dx = 0
                }
            }
            
            let result = physicsEngine.updateBall(
                position: ballState.position,
                velocity: ballState.velocity,
                floorY: gameAreaHeight,
                deltaTime: deltaTime,
                leftBound: 0,
                rightBound: gameAreaWidth,
                ballRadius: ballRadius
            )
            
            ballState.position = result.position
            ballState.velocity = result.velocity
            
            // Проверяем, достиг ли мяч низа игрового поля
            if ballState.position.y + ballRadius >= gameAreaHeight {
                endGame()
                return
            }
            
            for index in cubes.indices {
                cubes[index].position.y -= cubeMoveSpeed * CGFloat(deltaTime)
            }
            
            cubes.removeAll { cube in
                cube.position.y + cube.height / 2 < 0
            }
            
            checkCubeCollisions()
            
            try? await Task.sleep(nanoseconds: 16_000_000)
        }
    }
    
    deinit {
        updateTask?.cancel()
        cancellables.removeAll()
    }
}
