import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sizing = ProportionalSizing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                let statistics = viewModel.gameStatistics
                let achievements = viewModel.achievements
                
                ScrollView {
                    VStack(spacing: sizing.scaled(20)) {
                        VStack(alignment: .leading, spacing: sizing.scaled(16)) {
                            Text("Statistics by Level")
                                .font(.system(size: sizing.scaled(24), weight: .bold))
                                .padding(.horizontal, sizing.scaledWidth(16))
                            
                            DifficultyStatsSection(
                                title: "Easy",
                                statistics: statistics.easy,
                                color: .green,
                                sizing: sizing
                            )
                            
                            DifficultyStatsSection(
                                title: "Normal",
                                statistics: statistics.normal,
                                color: .blue,
                                sizing: sizing
                            )
                            
                            DifficultyStatsSection(
                                title: "Hard",
                                statistics: statistics.hard,
                                color: .red,
                                sizing: sizing
                            )
                        }
                        .padding(.vertical, sizing.scaledHeight(8))
                        
                        VStack(alignment: .leading, spacing: sizing.scaled(16)) {
                            Text("Achievements")
                                .font(.system(size: sizing.scaled(24), weight: .bold))
                                .padding(.horizontal, sizing.scaledWidth(16))
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: sizing.scaled(12)) {
                                ForEach(Achievement.allCases, id: \.self) { achievement in
                                    AchievementCard(
                                        achievement: achievement,
                                        isUnlocked: achievements.contains(achievement),
                                        sizing: sizing
                                    )
                                }
                            }
                            .padding(.horizontal, sizing.scaledWidth(16))
                        }
                        .padding(.vertical, sizing.scaledHeight(8))
                    }
                    .padding(.vertical, sizing.scaledHeight(16))
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.refresh()
            }
        }
    }
}

struct DifficultyStatsSection: View {
    let title: String
    let statistics: DifficultyStatistics
    let color: Color
    let sizing: ProportionalSizing
    
    var body: some View {
        VStack(alignment: .leading, spacing: sizing.scaled(12)) {
            Text(title)
                .font(.system(size: sizing.scaled(18), weight: .semibold))
                .foregroundColor(color)
                .padding(.horizontal, sizing.scaledWidth(16))
            
            VStack(spacing: sizing.scaled(8)) {
                StatisticRow(
                    icon: "cube.fill",
                    label: "Cubes caught",
                    value: "\(statistics.cubesCaught)",
                    sizing: sizing
                )
                
                StatisticRow(
                    icon: "clock.fill",
                    label: "Max time",
                    value: String(format: "%.1f sec", statistics.maxTime),
                    sizing: sizing
                )
                
                StatisticRow(
                    icon: "trophy.fill",
                    label: "Max score",
                    value: "\(statistics.maxScore)",
                    sizing: sizing
                )
            }
            .padding(.horizontal, sizing.scaledWidth(16))
        }
        .padding(.vertical, sizing.scaledHeight(8))
        .background(Color(.systemGray6))
    }
}

struct StatisticRow: View {
    let icon: String
    let label: String
    let value: String
    let sizing: ProportionalSizing
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: sizing.scaled(24))
            
            Text(label)
                .font(.system(size: sizing.scaled(15)))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: sizing.scaled(17), weight: .semibold))
        }
        .padding(sizing.scaled(12))
        .background(Color(.systemBackground))
        .cornerRadius(sizing.scaled(8))
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let sizing: ProportionalSizing
    
    var body: some View {
        VStack(spacing: sizing.scaled(8)) {
            Image(systemName: achievement.icon)
                .font(.system(size: sizing.scaled(40)))
                .foregroundColor(isUnlocked ? .yellow : .gray.opacity(0.3))
            
            Text(achievement.title)
                .font(.system(size: sizing.scaled(12), weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            Text(achievement.description)
                .font(.system(size: sizing.scaled(10)))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(sizing.scaled(12))
        .background(isUnlocked ? Color.yellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(sizing.scaled(12))
        .overlay(
            RoundedRectangle(cornerRadius: sizing.scaled(12))
                .stroke(isUnlocked ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}
