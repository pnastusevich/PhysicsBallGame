import SwiftUI

struct GameStartView: View {
    @ObservedObject var viewModel: GameBallViewModel
    let sizing: ProportionalSizing
    
    var body: some View {
        VStack(spacing: sizing.scaled(30)) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: sizing.scaled(80)))
                .foregroundColor(.accentColor)
            
            Spacer()
            
            VStack(spacing: sizing.scaled(16)) {
                Text("Physics Ball Game")
                    .font(.system(size: sizing.scaled(28), weight: .bold))
                
                Text("Catch cubes with the ball and score points!\nControl the ball by pressing the left or right side of the screen.\nFor every 2 cubes you get +1 second of time.")
                    .font(.system(size: sizing.scaled(16)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, sizing.scaledWidth(32))
            }
            
            Spacer()
            
            VStack(spacing: sizing.scaled(16)) {
                Text("Select difficulty:")
                    .font(.system(size: sizing.scaled(18), weight: .semibold))
                
                Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                    ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.displayName).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, sizing.scaledWidth(32))
                
                Text(getDifficultyDescription())
                    .font(.system(size: sizing.scaled(12)))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, sizing.scaledWidth(32))
            }
            
            Spacer()
            
            Button(action: {
                viewModel.startGame()
            }) {
                Label("Start Game", systemImage: "play.fill")
                    .font(.system(size: sizing.scaled(18), weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(sizing.scaled(16))
                    .background(Color.green)
                    .cornerRadius(sizing.scaled(12))
            }
            .padding(.horizontal, sizing.scaledWidth(32))
            .padding(.bottom, sizing.scaledHeight(20))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getDifficultyDescription() -> String {
        switch viewModel.selectedDifficulty {
        case .easy:
            return "Easy mode: ball falls slowly"
        case .normal:
            return "Normal mode: standard speed"
        case .hard:
            return "Hard mode: ball falls quickly"
        }
    }
}

