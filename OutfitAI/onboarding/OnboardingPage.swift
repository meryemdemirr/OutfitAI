//
//  OnboardingPage.swift
//  OutfitAI
//
//  Created by Meryem Demir on 3.07.2026.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
    let accentColor: Color
}

extension OnboardingPage {
    static let all: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "camera.fill",
            title: "Gardırobunu Dijitalleştir",
            subtitle: "Kıyafetlerinin fotoğrafını çek, saniyeler içinde dijital gardırobuna eklensin.",
            accentColor: Color(red: 0.98, green: 0.42, blue: 0.42)
        ),
        OnboardingPage(
            systemImage: "sparkles",
            title: "Akıllı Kombin Önerileri",
            subtitle: "Hava durumuna ve tarzına göre sana özel kombinler önerelim.",
            accentColor: Color(red: 0.55, green: 0.36, blue: 0.96)
        ),
        OnboardingPage(
            systemImage: "square.grid.2x2.fill",
            title: "Tüm Kıyafetlerin Bir Arada",
            subtitle: "Kategorilere göre düzenle, favorilerini işaretle, hiçbir parçayı unutma.",
            accentColor: Color(red: 0.20, green: 0.60, blue: 0.86)
        ),
        OnboardingPage(
            systemImage: "heart.text.square.fill",
            title: "Geçmiş Kombinlerini Kaydet",
            subtitle: "Beğendiğin kombinleri sakla, günlük stilini takip et.",
            accentColor: Color(red: 0.20, green: 0.70, blue: 0.55)
        )
    ]
}
