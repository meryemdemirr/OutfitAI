//
//  OutfitAIApp.swift
//  OutfitAI
//
//  Created by Meryem Demir on 3.07.2026.
//

import SwiftUI

@main
struct OutfitAIApp: App {
    // Kullanıcı onboarding'i tamamladı mı? UserDefaults'ta otomatik saklanır.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
    }
}

// Geçici placeholder - kendi ana tab view'ınızla değiştirin.
struct MainTabView: View {
    var body: some View {
        TabView {
            WardrobeView()
                .tabItem { Label("Gardırop", systemImage: "square.grid.2x2") }

            OutfitsView()
                .tabItem { Label("Kombinler", systemImage: "sparkles") }

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
    }
}
