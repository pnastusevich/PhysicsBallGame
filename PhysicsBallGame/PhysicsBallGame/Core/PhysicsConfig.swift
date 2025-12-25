import Foundation
import SwiftUI
import Combine

@MainActor
final class PhysicsConfig: ObservableObject {
    static let shared = PhysicsConfig()
    
    private let logerService = LoggerService.shared
    
    @Published var gravity: Double = 9.8 {
        didSet {
            logerService.logParameterChange(parameter: "gravity", value: String(format: "%.2f", gravity))
            if activeExperimentName != nil {
                activeExperimentName = nil
            }
        }
    }
    
    @Published var elasticity: Double = 0.8 {
        didSet {
            logerService.logParameterChange(parameter: "elasticity", value: String(format: "%.2f", elasticity))
            if activeExperimentName != nil {
                activeExperimentName = nil
            }
        }
    }
    
    @Published var mass: Double = 1.0 {
        didSet {
            logerService.logParameterChange(parameter: "mass", value: String(format: "%.2f", mass))
            if activeExperimentName != nil {
                activeExperimentName = nil
            }
        }
    }
    
    @Published var shouldResetSimulation = false
    @Published var activeExperimentName: String? = nil
    
    private init() {}
    
    func applyExperiment(_ experiment: Experiment) {
        gravity = experiment.gravity
        elasticity = experiment.elasticity
        mass = experiment.mass
        activeExperimentName = experiment.name
        shouldResetSimulation = true
    }
    
    func clearActiveExperiment() {
        activeExperimentName = nil
    }
}

