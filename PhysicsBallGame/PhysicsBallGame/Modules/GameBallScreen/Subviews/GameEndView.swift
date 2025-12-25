import SwiftUI

struct GameEndView: View {
    @ObservedObject var viewModel: GameBallViewModel
    let sizing: ProportionalSizing
    
    var body: some View {
        VStack(spacing: sizing.scaled(30)) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: sizing.scaled(80)))
                .foregroundColor(.yellow)
            
            VStack(spacing: sizing.scaled(20)) {
                Text("Game Over!")
                    .font(.system(size: sizing.scaled(32), weight: .bold))
                
                VStack(spacing: sizing.scaled(12)) {
                    Text("Your score:")
                        .font(.system(size: sizing.scaled(18), weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.finalScore)")
                        .font(.system(size: sizing.scaled(60), weight: .bold))
                        .foregroundColor(.accentColor)
                    
                    Text("points")
                        .font(.system(size: sizing.scaled(20)))
                        .foregroundColor(.secondary)
                }
                .padding(sizing.scaled(24))
                .background(Color(.systemGray6))
                .cornerRadius(sizing.scaled(16))
                
                if viewModel.finalScore >= viewModel.bestScore && viewModel.finalScore > 0 {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: sizing.scaled(20)))
                            .foregroundColor(.yellow)
                        Text("New Record!")
                            .font(.system(size: sizing.scaled(18), weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    .padding(sizing.scaled(12))
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(sizing.scaled(8))
                }
            }
            
            VStack(spacing: sizing.scaled(16)) {
                Button(action: {
                    viewModel.resetGame()
                }) {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: sizing.scaled(18), weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(sizing.scaled(16))
                        .background(Color.green)
                        .cornerRadius(sizing.scaled(12))
                }
                
                Button(action: {
                    viewModel.gameStage = .notStarted
                }) {
                    Label("Main Menu", systemImage: "house.fill")
                        .font(.system(size: sizing.scaled(18), weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(sizing.scaled(16))
                        .background(Color.blue)
                        .cornerRadius(sizing.scaled(12))
                }
            }
            .padding(.horizontal, sizing.scaledWidth(32))
            .padding(.bottom, sizing.scaledHeight(20))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

