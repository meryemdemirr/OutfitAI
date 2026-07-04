//
//  ClothingItem.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct ClothingItem: Identifiable {
    let id = UUID()
    var image: String          // kategoriye göre fallback sistem ikonu
    var photo: UIImage?        // kullanıcının çektiği/seçtiği gerçek fotoğraf (arka planı silinmiş)
    var name: String
    var category: String
    var color: String
    var isFavorite: Bool
}

// UIImage kendiliğinden Hashable/Equatable olmadığı için eşitliği id üzerinden tanımlıyoruz.
extension ClothingItem: Hashable {
    static func == (lhs: ClothingItem, rhs: ClothingItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
