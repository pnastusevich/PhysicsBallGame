import Foundation

enum ExperimentServiceError: LocalizedError {
    case networkError
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred"
        case .timeout:
            return "Request timed out"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

final class ExperimentService {
    static let shared = ExperimentService()
    
    private let logerService = LoggerService.shared
    
    private init() {}
    
    func loadExperiment(_ experiment: Experiment) async throws -> Experiment {
        logerService.logAsyncOperationStart(operation: "Load experiment: \(experiment.name)")
        
        try await Task.sleep(nanoseconds: 500_000_000)
        logerService.logAsyncOperationComplete(operation: "Load experiment: \(experiment.name)")
        return experiment
    }
}

