import Foundation
import os.log

final class LoggerService {
    static let shared = LoggerService()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.physicsballgame"
    private let category = "PhysicsBallGame"
    private let logger: os.Logger
    
    private init() {
        logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    func log(_ message: String, level: LogLevel = .info) {
        let logMessage = "[\(level.rawValue)] \(message)"
        
        switch level {
        case .debug:
            logger.debug("\(logMessage, privacy: .public)")
        case .info:
            logger.info("\(logMessage, privacy: .public)")
        case .warning:
            logger.warning("\(logMessage, privacy: .public)")
        case .error:
            logger.error("\(logMessage, privacy: .public)")
        }
    }
    
    func logSimulationStart() {
        log("Simulation started", level: .info)
    }
    
    func logSimulationPause() {
        log("Simulation paused", level: .info)
    }
    
    func logSimulationReset() {
        log("Simulation reset", level: .info)
    }
    
    func logParameterChange(parameter: String, value: String) {
        log("Parameter changed: \(parameter) = \(value)", level: .debug)
    }
    
    func logAsyncOperationStart(operation: String) {
        log("Async operation started: \(operation)", level: .debug)
    }
    
    func logAsyncOperationComplete(operation: String) {
        log("Async operation completed: \(operation)", level: .debug)
    }
    
    func logAsyncOperationError(operation: String, error: String) {
        log("Async operation failed: \(operation) - \(error)", level: .error)
    }
    
    func logExperimentSelected(experiment: String) {
        log("Experiment selected: \(experiment)", level: .info)
    }
    
    func logExperimentLoadSuccess(experiment: String) {
        log("Experiment loaded successfully: \(experiment)", level: .info)
    }
    
    func logExperimentLoadFailure(experiment: String, error: String) {
        log("Experiment load failed: \(experiment) - \(error)", level: .error)
    }
    
    func logBallSpawned(at point: CGPoint) {
        log("Ball spawned at (\(Int(point.x)), \(Int(point.y)))", level: .debug)
    }
    
    func logVelocityApplied(velocity: CGVector) {
        log("Velocity applied: dx=\(String(format: "%.2f", velocity.dx)), dy=\(String(format: "%.2f", velocity.dy))", level: .debug)
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

