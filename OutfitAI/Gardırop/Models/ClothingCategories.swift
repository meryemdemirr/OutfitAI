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

    static let main = ["Üst", "Alt", "Ayakkabı", "Aksesuar"]

    static let subcategories: [String: [String]] = [
        "Üst": ["Tişört", "Sweatshirt", "Kazak", "Bluz", "Gömlek", "Askılı", "Kapşonlu"],
        "Alt": ["Kot Pantolon", "Şort", "Etek", "Mini Etek", "Pantolon", "Eşofman", "Tayt"],
        "Ayakkabı": ["Spor Ayakkabı", "Bot", "Sandalet", "Topuklu Ayakkabı", "Uzun Çizme", "Klasik Ayakkabı"],
        "Aksesuar": ["Şapka", "Kemer", "Eşarp", "Güneş Gözlüğü", "Kolye", "Küpe", "Bilezik", "Kravat"]
    ]

    /// Verilen ana kategori için ilk alt kategoriyi döner (varsayılan seçim için kullanılır).
    static func firstSubcategory(for category: String) -> String {
        subcategories[category]?.first ?? ""
    }
}
