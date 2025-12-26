import SwiftUI

struct ForcesView: View {
    @StateObject private var viewModel = ForcesViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Physics Parameters")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gravity: \(viewModel.gravity, specifier: "%.2f") m/s²")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.gravity },
                                set: { viewModel.updateGravity($0) }
                            ),
                            in: 0...20,
                            step: 0.1
                        )
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elasticity: \(viewModel.elasticity, specifier: "%.2f")")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.elasticity },
                                set: { viewModel.updateElasticity($0) }
                            ),
                            in: 0...1,
                            step: 0.01
                        )
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mass: \(viewModel.mass, specifier: "%.2f") kg")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.mass },
                                set: { viewModel.updateMass($0) }
                            ),
                            in: 0.1...10,
                            step: 0.1
                        )
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Ball Type")) {
                    Text("Select a ball type for the game. Each type has different physics properties")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                    
                    ForEach(viewModel.experiments) { experiment in
                        ExperimentRow(
                            experiment: experiment,
                            isLoading: viewModel.isLoading,
                            onSelect: {
                                viewModel.selectExperiment(experiment)
                            }
                        )
                    }
                }
                
                Section(header: Text("Information")) {
                    Text("Adjust these parameters to see how they affect the ball physics. Changes are applied immediately to the game")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Forces")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error occurred")
            }
        }
    }
}

