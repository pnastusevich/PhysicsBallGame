import SwiftUI

struct PlaygroundView: View {
    @StateObject private var viewModel = PlaygroundViewModel()    
    @StateObject private var config = PhysicsConfig.shared

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sizing = ProportionalSizing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                
                VStack(spacing: 0) {
                    PhysicsInfoView(config: config)
                        .padding(.horizontal, sizing.scaledWidth(16))
                        .padding(.top, sizing.scaledHeight(8))
                    
                    GeometryReader { innerGeometry in
                        ZStack {
                            Color(.systemBackground)
                                .ignoresSafeArea()
                            
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: viewModel.floorThickness)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, viewModel.floorPadding)
                            
                            if viewModel.isActive || viewModel.dragStart != nil || viewModel.isHolding {
                                Circle()
                                    .fill(viewModel.ballColor)
                                    .frame(width: viewModel.ballSize, height: viewModel.ballSize)
                                    .position(viewModel.ballPosition)
                            }
                            
                            if viewModel.showDirectionIndicator, let start = viewModel.dragStart, let end = viewModel.dragEnd {
                                Path { path in
                                    path.move(to: start)
                                    path.addLine(to: end)
                                }
                                .stroke(Color.accentColor.opacity(0.5), lineWidth: viewModel.directionLineWidth)
                                .overlay(
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: viewModel.directionIndicatorSize, height: viewModel.directionIndicatorSize)
                                        .position(end)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    viewModel.handleDragChanged(startLocation: value.startLocation, currentLocation: value.location)
                                }
                                .onEnded { value in
                                    viewModel.handleDragEnded(endLocation: value.location)
                                }
                        )
                        .onTapGesture { location in
                            viewModel.handleTap(at: location)
                        }
                        .onAppear {
                            viewModel.updateGeometry(height: innerGeometry.size.height, width: innerGeometry.size.width)
                        }
                        .onChange(of: innerGeometry.size.width) { newWidth in
                            viewModel.updateGeometry(height: innerGeometry.size.height, width: newWidth)
                        }
                        .onChange(of: innerGeometry.size.height) { newHeight in
                            viewModel.updateGeometry(height: newHeight, width: innerGeometry.size.width)
                        }
                    }
                }
            }
            .navigationTitle("Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
}


#Preview {
    AppCoordinator().makeTabView()
}
