import SwiftUI
import Combine

@MainActor
final class PlaygroundViewModel: ObservableObject {
    @Published var ballState = BallState()
    @Published var isActive = false
    @Published var isHolding = false
    @Published var dragStart: CGPoint?
    @Published var dragEnd: CGPoint?
    
    private let physicsEngine: PhysicsEngine
    private let config = PhysicsConfig.shared
    private let logerService = LoggerService.shared
    private var updateTask: Task<Void, Never>?
    private var lastUpdateTime: Date?
    private var floorY: CGFloat = 0
    private var screenWidth: CGFloat = 375
    private var screenHeight: CGFloat = 812
    
    var ballRadius: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(15.0)
    }
    
    var ballSize: CGFloat {
        ballRadius * 2
    }
    
    var floorThickness: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(2.0)
    }
    
    var floorPadding: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaledHeight(50.0)
    }
    
    var directionIndicatorSize: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(8.0)
    }
    
    var directionLineWidth: CGFloat {
        ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(2.0)
    }
    
    var ballPosition: CGPoint {
        if let dragStart = dragStart, !isActive && !isHolding {
            return dragStart
        }
        return ballState.position
    }
    
    var ballColor: Color {
        if isHolding {
            return Color.orange
        } else {
            return Color.accentColor
        }
    }
    
    var showDirectionIndicator: Bool {
        dragStart != nil && dragEnd != nil && !isHolding
    }
    
    
    init() {
        physicsEngine = PhysicsEngine(config: config)
    }
    
    func setFloorY(_ y: CGFloat) {
        floorY = y
    }
    
    func setScreenWidth(_ width: CGFloat) {
        screenWidth = width
    }
    
    func setScreenHeight(_ height: CGFloat) {
        screenHeight = height
    }
    
    func spawnBall(at position: CGPoint) {
        ballState.reset(to: position)
        isActive = false
        logerService.logBallSpawned(at: position)
    }
    
    func startPhysics() {
        isActive = true
        if updateTask == nil {
            startPhysicsLoop()
        }
    }
    
    func applyVelocity(_ velocity: CGVector) {
        ballState.velocity = velocity
        isActive = true
        lastUpdateTime = Date()
        logerService.logVelocityApplied(velocity: velocity)
        
        if updateTask == nil {
            startPhysicsLoop()
        }
    }
    
    func isPointOnBall(_ point: CGPoint) -> Bool {
        guard isActive || ballState.position != .zero else { return false }
        let distance = sqrt(pow(point.x - ballState.position.x, 2) + pow(point.y - ballState.position.y, 2))
        return distance <= ballRadius
    }
    
    func pickUpBall(at position: CGPoint) {
        guard isPointOnBall(position) else { return }
        isHolding = true
        ballState.velocity = .zero
        lastUpdateTime = Date()
    }
    
    func moveHeldBall(to position: CGPoint) {
        guard isHolding else { return }
        ballState.position = position
    }
    
    func releaseBall(at position: CGPoint, withVelocity velocity: CGVector) {
        guard isHolding else { return }
        isHolding = false
        ballState.position = position
        ballState.velocity = velocity
        lastUpdateTime = Date()
        
        if !isActive {
            isActive = true
            startPhysicsLoop()
        }
    }
    
    func reset() {
        updateTask?.cancel()
        updateTask = nil
        isActive = false
        isHolding = false
        dragStart = nil
        dragEnd = nil
        ballState.reset(to: .zero)
    }
    
    func handleDragChanged(startLocation: CGPoint, currentLocation: CGPoint) {
        if isHolding {
            moveHeldBall(to: currentLocation)
            dragEnd = currentLocation
        } else if dragStart == nil {
            if isActive && isPointOnBall(startLocation) {
                pickUpBall(at: startLocation)
                dragStart = startLocation
            } else {
                dragStart = startLocation
                if !isActive {
                    spawnBall(at: startLocation)
                }
            }
            dragEnd = currentLocation
        } else {
            dragEnd = currentLocation
        }
    }
    
    func handleDragEnded(endLocation: CGPoint) {
        if isHolding {
            if let start = dragStart {
                let velocity = calculateVelocity(from: start, to: endLocation, multiplier: 0.3)
                releaseBall(at: endLocation, withVelocity: velocity)
            } else {
                releaseBall(at: endLocation, withVelocity: .zero)
            }
            dragStart = nil
            dragEnd = nil
        } else if let start = dragStart {
            if isActive {
                let velocity = calculateVelocity(from: ballState.position, to: endLocation)
                applyVelocity(velocity)
            } else {
                spawnBall(at: start)
                let velocity = calculateVelocity(from: start, to: endLocation)
                applyVelocity(velocity)
            }
            dragStart = nil
            dragEnd = nil
        }
    }
    
    func handleTap(at location: CGPoint) {
        spawnBall(at: location)
        startPhysics()
    }
    
    func updateGeometry(height: CGFloat, width: CGFloat) {
        setScreenWidth(width)
        setScreenHeight(height)
        setFloorY(height - floorPadding)
    }
    
    private func calculateVelocity(from start: CGPoint, to end: CGPoint, multiplier: CGFloat? = nil) -> CGVector {
        let dragDistance = sqrt(
            pow(end.x - start.x, 2) +
            pow(end.y - start.y, 2)
        )
        let baseDistance = ProportionalSizing(screenWidth: screenWidth, screenHeight: screenHeight).scaled(50.0)
        let velocityMultiplier = multiplier ?? min(1.0, dragDistance / baseDistance) * 0.8
        return CGVector(
            dx: (end.x - start.x) * velocityMultiplier,
            dy: (start.y - end.y) * velocityMultiplier
        )
    }
    
    private func startPhysicsLoop() {
        lastUpdateTime = Date()
        
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled && self.isActive {
                if self.isHolding {
                    try? await Task.sleep(nanoseconds: 16_000_000)
                    continue
                }
                
                guard let lastTime = self.lastUpdateTime else {
                    self.lastUpdateTime = Date()
                    try? await Task.sleep(nanoseconds: 16_000_000)
                    continue
                }
                
                let currentTime = Date()
                var deltaTime = currentTime.timeIntervalSince(lastTime)
                deltaTime = min(deltaTime, 0.1)
                self.lastUpdateTime = currentTime
                
                let result = self.physicsEngine.updateBall(
                    position: self.ballState.position,
                    velocity: self.ballState.velocity,
                    floorY: self.floorY,
                    deltaTime: deltaTime,
                    leftBound: self.screenWidth > 0 ? 0 : nil,
                    rightBound: self.screenWidth > 0 ? self.screenWidth : nil,
                    ballRadius: self.ballRadius
                )
                
                self.ballState.position = result.position
                self.ballState.velocity = result.velocity
                
                if self.ballState.position.y > self.floorY + 100 {
                    self.isActive = false
                    break
                }
                
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }
    
    deinit {
        updateTask?.cancel()
    }
}

