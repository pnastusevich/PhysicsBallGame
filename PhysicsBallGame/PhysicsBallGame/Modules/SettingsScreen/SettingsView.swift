import SwiftUI
import PhotosUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sizing = ProportionalSizing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                
                Form {
                    Section(header: Text("Profile")) {
                        HStack(spacing: sizing.scaled(16)) {
                            if let profileImage = viewModel.profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: sizing.scaled(80), height: sizing.scaled(80))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: sizing.scaled(2)))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: sizing.scaled(80), height: sizing.scaled(80))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            
                            VStack(alignment: .leading, spacing: sizing.scaled(8)) {
                                if viewModel.hasPhotoPermission {
                                    PhotosPicker(
                                        selection: Binding(
                                            get: { viewModel.selectedPhoto },
                                            set: { viewModel.handlePhotoSelection($0) }
                                        ),
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        Text("Select Photo")
                                            .font(.system(size: sizing.scaled(16)))
                                            .foregroundColor(.blue)
                                    }
                                } else {
                                    Button {
                                        Task {
                                            await viewModel.requestPhotoLibraryPermission()
                                        }
                                    } label: {
                                        Text("Select Photo")
                                            .font(.system(size: sizing.scaled(16)))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                if viewModel.profileImage != nil {
                                    Button(role: .destructive) {
                                        viewModel.handlePhotoSelection(nil)
                                    } label: {
                                        Text("Remove Photo")
                                            .font(.system(size: sizing.scaled(12)))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, sizing.scaledHeight(8))
                    }
                    
                    Section(header: Text("User Information")) {
                            VStack(alignment: .leading, spacing: sizing.scaled(8)) {
                                Text("Name")
                                    .font(.system(size: sizing.scaled(12)))
                                    .foregroundColor(.secondary)
                            
                            TextField("Enter your name", text: Binding(
                                get: { viewModel.userName },
                                set: { viewModel.userNameChanged($0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                        .padding(.vertical, sizing.scaledHeight(4))
                    }
                    
                    Section(header: Text("Game Statistics")) {
                        HStack {
                            VStack(alignment: .leading, spacing: sizing.scaled(4)) {
                                Text("Best Score")
                                    .font(.system(size: sizing.scaled(18), weight: .semibold))
                                Text("\(viewModel.bestScore) points")
                                    .font(.system(size: sizing.scaled(24), weight: .bold))
                                    .foregroundColor(.accentColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "trophy.fill")
                                .font(.system(size: sizing.scaled(40)))
                                .foregroundColor(.yellow)
                        }
                        .padding(.vertical, sizing.scaledHeight(8))
                    }
                    
                    Section(header: Text("About")) {
                        VStack(alignment: .leading, spacing: sizing.scaled(8)) {
                            Text("Physics Ball Game")
                                .font(.system(size: sizing.scaled(18), weight: .semibold))
                            
                            Text("An educational app demonstrating ball physics including gravity, bouncing, and forces.")
                                .font(.system(size: sizing.scaled(12)))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, sizing.scaledHeight(4))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadBestScore()
            }
            .alert("Photo Library Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Settings") {
                    viewModel.openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable photo library access in Settings to select a profile photo.")
            }
        }
    }
}

