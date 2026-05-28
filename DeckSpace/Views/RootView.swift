//
//  RootView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case home, library, create, discover, profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .library: return "Library"
        case .create: return "Create"
        case .discover: return "Discover"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "books.vertical.fill"
        case .create: return "plus.circle.fill"
        case .discover: return "safari.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct RootView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: AppTab? = .home // Tipe data jadikan Optional (?)
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // MARK: - LAYOUT IPHONE (Tab Bar)
            // TabView butuh non-optional, jadi kita berikan nilai default (?? .home)
            TabView(selection: Binding(
                get: { selectedTab ?? .home },
                set: { selectedTab = $0 }
            )) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    destinationView(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
        } else {
            // MARK: - LAYOUT IPAD & MAC (Sidebar + Detail)
            NavigationSplitView {
                // Gunakan List standar untuk Sidebar
                List(AppTab.allCases, id: \.self, selection: $selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
                .navigationTitle("DeckSpace")
            } detail: {
                // Tangani nilai optional
                if let tab = selectedTab {
                    destinationView(for: tab)
                } else {
                    Text("Pilih menu di samping")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .library: LibraryView()
        case .create: CreateDeckView()
        case .discover: DiscoverView()
        case .profile: ProfileView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
