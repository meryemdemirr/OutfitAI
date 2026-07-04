//
//  SavedOutfit.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import UIKit

/// Kullanıcının gardıroptaki parçalardan oluşturduğu, kaydedilmiş kombin.
/// Not: "Outfit" adı Ana Sayfa'daki topluluk gönderisi modeliyle (Models/Outfit.swift)
/// çakıştığı için bu model "SavedOutfit" olarak adlandırıldı.
struct SavedOutfit: Identifiable {
    let id: UUID
    var name: String
    var itemIDs: [UUID]         // Kombini oluşturan ClothingItem id'leri (veri tekrarı yok)
    var collageImage: UIImage?  // Oluşturulan kombin kolajı
    let createdAt: Date
}

extension SavedOutfit: Hashable {
    static func == (lhs: SavedOutfit, rhs: SavedOutfit) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
