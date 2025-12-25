import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: TabItem = .gameBall
    
    enum TabItem: Int, CaseIterable {
        case gameBall = 0
        case forces = 1
        case statistics = 2
        case settings = 3
        case playground = 4
        
        var title: String {
            switch self {
            case .gameBall:
                return "Game Ball"
            case .forces:
                return "Forces"
            case .statistics:
                return "Statistics"
            case .settings:
                return "Settings"
            case .playground:
                return "Playground"
            }
        }
        
        var systemImage: String {
            switch self {
            case .gameBall:
                return "gamecontroller.circle"
            case .forces:
                return "slider.horizontal.3"
            case .statistics:
                return "chart.bar.fill"
            case .settings:
                return "gearshape.fill"
            case .playground:
                return "hand.draw.fill"
            }
        }
    }
    
    func makeTabView() -> some View {
        TabView(selection: Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )) {
            GameBallView()
                .tabItem {
                    Label(TabItem.gameBall.title, systemImage: TabItem.gameBall.systemImage)
                }
                .tag(TabItem.gameBall)
     
            
            StatisticsView()
                .tabItem {
                    Label(TabItem.statistics.title, systemImage: TabItem.statistics.systemImage)
                }
                .tag(TabItem.statistics)
            
            PlaygroundView()
                .tabItem {
                    Label(TabItem.playground.title, systemImage: TabItem.playground.systemImage)
                }
                .tag(TabItem.playground)
            
            ForcesView()
                .tabItem {
                    Label(TabItem.forces.title, systemImage: TabItem.forces.systemImage)
                }
                .tag(TabItem.forces)
            
            
            SettingsView()
                .tabItem {
                    Label(TabItem.settings.title, systemImage: TabItem.settings.systemImage)
                }
                .tag(TabItem.settings)
            
        
        }
    }
}

