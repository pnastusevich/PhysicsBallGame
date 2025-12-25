import SwiftUI
import Combine

@MainActor
final class ForcesViewModel: ObservableObject {
    @Published var gravity: Double = 9.8
    @Published var elasticity: Double = 0.8
    @Published var mass: Double = 1.0
    @Published var experiments: [Experiment] = Experiment.allExperiments
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let config = PhysicsConfig.shared
    private let experimentService = ExperimentService.shared
    private let logerService = LoggerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        gravity = config.gravity
        elasticity = config.elasticity
        mass = config.mass
        
        config.$gravity
            .assign(to: &$gravity)
        config.$elasticity
            .assign(to: &$elasticity)
        config.$mass
            .assign(to: &$mass)
    }
    
    func updateGravity(_ value: Double) {
        config.gravity = value
    }
    
    func updateElasticity(_ value: Double) {
        config.elasticity = value
    }
    
    func updateMass(_ value: Double) {
        config.mass = value
    }
    
    func selectExperiment(_ experiment: Experiment) {
        guard !isLoading else { return }
        
        logerService.logExperimentSelected(experiment: experiment.name)
        isLoading = true
        errorMessage = nil
        showError = false
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let loadedExperiment = try await experimentService.loadExperiment(experiment)
                await MainActor.run {
                    self.config.applyExperiment(loadedExperiment)
                    
                    self.isLoading = false
                    self.logerService.logExperimentLoadSuccess(experiment: loadedExperiment.name)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.logerService.logExperimentLoadFailure(
                        experiment: experiment.name,
                        error: error.localizedDescription
                    )
                }
            }
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}

