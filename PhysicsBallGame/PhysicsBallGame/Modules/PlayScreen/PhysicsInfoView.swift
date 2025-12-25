import SwiftUI

struct PhysicsInfoView: View {
    @ObservedObject var config: PhysicsConfig
    
    private var displayName: String {
        if let experimentName = config.activeExperimentName {
            return experimentName
        }
        
        let matchingExperiment = Experiment.allExperiments.first { experiment in
            abs(experiment.gravity - config.gravity) < 0.01 &&
            abs(experiment.elasticity - config.elasticity) < 0.001 &&
            abs(experiment.mass - config.mass) < 0.01
        }
        
        return matchingExperiment?.name ?? "Custom"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let sizing = ProportionalSizing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
            
            VStack(spacing: sizing.scaled(4)) {
                Text(displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, sizing.scaledHeight(6))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(sizing.scaled(8))
        }
        .frame(height: 44)
    }
}

