import SwiftUI

struct GameBallView: View {
    @StateObject private var viewModel = GameBallViewModel()
    @StateObject private var config = PhysicsConfig.shared
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sizing = ProportionalSizing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                let safeAreaInsets = geometry.safeAreaInsets
                let tabBarHeight: CGFloat = 15
                let bottomPadding: CGFloat = 10
                let topPanelHeight: CGFloat = 80
                
                let availableHeight = max(0, geometry.size.height - topPanelHeight - safeAreaInsets.bottom - tabBarHeight - bottomPadding)
                
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    switch viewModel.gameStage {
                    case .notStarted:
                        GameStartView(viewModel: viewModel, sizing: sizing)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    case .playing:
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: sizing.scaled(4)) {
                                    Text("Score: \(viewModel.score)")
                                        .font(.system(size: sizing.scaled(17), weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("Time: \(Int(viewModel.timeRemaining))s")
                                        .font(.system(size: sizing.scaled(15)))
                                        .foregroundColor(viewModel.timeRemaining < 5 ? .red : .secondary)
                                }
                                
                                Spacer()
                                
                                if viewModel.showResumeButton {
                                    Button(action: {
                                        viewModel.resumeGame()
                                    }) {
                                        Label("Resume", systemImage: "play.fill")
                                            .font(.system(size: sizing.scaled(14), weight: .medium))
                                            .padding(sizing.scaled(12))
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(sizing.scaled(10))
                                    }
                                } else if viewModel.showPauseButton {
                                    Button(action: {
                                        viewModel.pauseGame()
                                    }) {
                                        Label("Pause", systemImage: "pause.fill")
                                            .font(.system(size: sizing.scaled(14), weight: .medium))
                                            .padding(sizing.scaled(12))
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(sizing.scaled(10))
                                    }
                                }
                            }
                            .padding(sizing.scaledWidth(16))
                            .background(Color(.systemGray6))
                            .frame(height: sizing.scaledHeight(topPanelHeight))
                         
                            GeometryReader { innerGeometry in
                                let gameSizing = ProportionalSizing(screenWidth: innerGeometry.size.width, screenHeight: innerGeometry.size.height)
                                let initialY = gameSizing.scaledHeight(50.0)
                                let ballPosition = viewModel.isBallAtInitialPosition
                                    ? CGPoint(x: innerGeometry.size.width / 2, y: initialY)
                                    : viewModel.ballState.position
                                
                                ZStack {
                                    ForEach(viewModel.cubes) { cube in
                                        RoundedRectangle(cornerRadius: gameSizing.scaled(8))
                                            .fill(Color.blue)
                                            .frame(width: cube.width, height: cube.height)
                                            .position(cube.position)
                                    }
                                    
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: viewModel.ballSize, height: viewModel.ballSize)
                                        .position(ballPosition)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemBackground))
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let touchX = value.location.x
                                            let screenWidth = innerGeometry.size.width
                                            
                                            if touchX < screenWidth / 2 {
                                                viewModel.setPressingLeft(true)
                                                viewModel.setPressingRight(false)
                                            } else {
                                                viewModel.setPressingLeft(false)
                                                viewModel.setPressingRight(true)
                                            }
                                        }
                                        .onEnded { _ in
                                            viewModel.setPressingLeft(false)
                                            viewModel.setPressingRight(false)
                                        }
                                )
                                .task {
                                    viewModel.setScreenSize(width: geometry.size.width, height: geometry.size.height)
                                    viewModel.setGameAreaSize(width: innerGeometry.size.width, height: innerGeometry.size.height)
                                }
                                .onChange(of: geometry.size.width) { newWidth in
                                    viewModel.setScreenSize(width: newWidth, height: geometry.size.height)
                                }
                                .onChange(of: geometry.size.height) { newHeight in
                                    viewModel.setScreenSize(width: geometry.size.width, height: newHeight)
                                }
                                .onChange(of: innerGeometry.size.width) { newWidth in
                                    viewModel.setGameAreaSize(width: newWidth, height: innerGeometry.size.height)
                                }
                                .onChange(of: innerGeometry.size.height) { newHeight in
                                    viewModel.setGameAreaSize(width: innerGeometry.size.width, height: newHeight)
                                }
                            }
                            .frame(height: availableHeight)
                        }
                        
                    case .finished:
                        GameEndView(viewModel: viewModel, sizing: sizing)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    GameBallView()
}


