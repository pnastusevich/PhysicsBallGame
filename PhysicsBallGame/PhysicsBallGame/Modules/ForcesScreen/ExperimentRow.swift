import SwiftUI

struct ExperimentRow: View {
    let experiment: Experiment
    let isLoading: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            guard !isLoading else { return }
            onSelect()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(experiment.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(experiment.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        Label("G: \(experiment.gravity, specifier: "%.1f")", systemImage: "arrow.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Label("E: \(experiment.elasticity, specifier: "%.2f")", systemImage: "arrow.up.arrow.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Label("M: \(experiment.mass, specifier: "%.1f")", systemImage: "scalemass")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isLoading)
    }
}

