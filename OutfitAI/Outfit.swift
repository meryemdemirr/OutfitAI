//
//  Outfit.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import Foundation

struct Outfit: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let username: String       // görünen isim, örn. "Ayşe Yılmaz"
    let handle: String         // @ olmadan kullanıcı adı, örn. "ayseyilmaz"
    let imageName: String      // şimdilik asset/sistem ikonu adı, backend gelince URL olacak
    let accentColor: String    // hex ya da asset renk adı, kart arka planı için
    var likeCount: Int
    var isLikedByCurrentUser: Bool = false
    let category: OutfitCategory
    let createdAt: Date
}

enum OutfitCategory: String, CaseIterable {
    case daily = "Günlük"
    case formal = "Şık"
    case sport = "Spor"
    case street = "Sokak Stili"
}

extension Outfit {
    /// Backend bağlanana kadar önizleme ve geliştirme için sahte veri.
    static let mock: [Outfit] = [
        Outfit(title: "Sonbahar Uyumu", username: "Ayşe Yılmaz", handle: "ayseyilmaz",
               imageName: "tshirt.fill", accentColor: "F2A65A", likeCount: 128,
               category: .street, createdAt: Date().addingTimeInterval(-3600)),
        Outfit(title: "Ofis Şıklığı", username: "Mert Kaya", handle: "mertkaya",
               imageName: "person.crop.rectangle.fill", accentColor: "5B8A72", likeCount: 76,
               category: .formal, createdAt: Date().addingTimeInterval(-7200)),
        Outfit(title: "Koşu Günü", username: "Zeynep Ak", handle: "zeynepak",
               imageName: "figure.run", accentColor: "3E7CB1", likeCount: 44,
               category: .sport, createdAt: Date().addingTimeInterval(-10800)),
        Outfit(title: "Hafta Sonu Rahatlığı", username: "Deniz Er", handle: "denizer",
               imageName: "cloud.sun.fill", accentColor: "C96567", likeCount: 210,
               category: .daily, createdAt: Date().addingTimeInterval(-14400)),
        Outfit(title: "Akşam Yemeği", username: "Elif Su", handle: "elifsu",
               imageName: "moon.stars.fill", accentColor: "7C6A9C", likeCount: 95,
               category: .formal, createdAt: Date().addingTimeInterval(-18000))
    ]

    /// Bugünün öne çıkan kombini (şimdilik ilk eleman, backend'de ayrı bir alan olacak).
    static let todaysFeatured: Outfit = mock[3]
}
