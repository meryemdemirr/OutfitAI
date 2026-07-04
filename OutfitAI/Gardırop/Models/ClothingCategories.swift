//
//  ClothingCategories.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import Foundation

/// Ana kategoriler ve her birine ait alt kategori listesi.
/// Tek yerden yönetildiği için yeni bir alt kategori eklemek istediğinizde
/// sadece burayı güncellemeniz yeterli.
enum ClothingCategories {

    static let main = ["Üst", "Alt", "Dış Giyim", "Ayakkabı", "Çanta", "Aksesuar"]

    static let subcategories: [String: [String]] = [
        "Üst": ["Tişört", "Sweatshirt", "Kazak", "Bluz", "Gömlek", "Askılı", "Kapşonlu"],
        "Alt": ["Kot Pantolon", "Şort", "Etek", "Mini Etek", "Pantolon", "Eşofman", "Tayt"],
        "Dış Giyim": ["Kaban", "Mont", "Trençkot", "Yağmurluk", "Yelek", "Deri Ceket"],
        "Ayakkabı": ["Spor Ayakkabı", "Bot", "Sandalet", "Topuklu Ayakkabı", "Uzun Çizme", "Klasik Ayakkabı"],
        "Çanta": ["Sırt Çantası", "El Çantası", "Askılı Çanta", "Cüzdan", "Spor Çantası"],
        "Aksesuar": ["Şapka", "Kemer", "Eşarp", "Güneş Gözlüğü", "Kolye", "Küpe", "Bilezik", "Kravat"]
    ]

    /// Verilen ana kategori için ilk alt kategoriyi döner (varsayılan seçim için kullanılır).
    static func firstSubcategory(for category: String) -> String {
        subcategories[category]?.first ?? ""
    }

    /// Bir ana kategori için fallback sistem ikonu.
    /// WardrobeCardView, AddItemView ve ClothingItemDetailView bu fonksiyonu paylaşır
    /// - fotoğrafı olmayan bir parça için gösterilecek ikonu tek yerden yönetir.
    static func iconName(for category: String) -> String {
        switch category {
        case "Üst": return "tshirt"
        case "Alt": return "figure.walk"
        case "Dış Giyim": return "tshirt.fill"
        case "Ayakkabı": return "shoeprints.fill"
        case "Çanta": return "bag.fill"
        case "Aksesuar": return "sunglasses"
        default: return "tshirt"
        }
    }
}
