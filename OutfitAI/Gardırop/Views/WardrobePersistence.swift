//
//  WardrobePersistence.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import Foundation
import UIKit

/// Kıyafetleri cihazda kalıcı olarak saklar.
/// Önemli: veriler iCloud/iTunes yedeklerinden HARİÇ tutulur.
/// Bu sayede uygulama açıkken veriler korunur, ama kullanıcı uygulamayı
/// silip tekrar yüklerse (yedekten geri yükleme dahil) eski veriler geri gelmez.
enum WardrobePersistence {

    private static let itemsFileName = "wardrobe_items.json"
    private static let photosFolderName = "WardrobePhotos"

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private static var photosDirectory: URL {
        let url = documentsDirectory.appendingPathComponent(photosFolderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private static var itemsFileURL: URL {
        documentsDirectory.appendingPathComponent(itemsFileName)
    }

    /// Verilen klasörü/dosyayı iCloud ve iTunes yedeklerinden hariç tutar.
    private static func excludeFromBackup(_ fileURL: URL) {
        var url = fileURL
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? url.setResourceValues(values)
    }

    /// JSON'a yazılabilecek, UIImage içermeyen sade veri modeli.
    private struct ClothingItemRecord: Codable {
        let id: UUID
        let image: String
        let photoFileName: String?
        let name: String
        let category: String
        let subcategory: String
        let color: String
        let isFavorite: Bool
    }

    static func saveItems(_ items: [ClothingItem]) {
        excludeFromBackup(documentsDirectory)
        excludeFromBackup(photosDirectory)

        var records: [ClothingItemRecord] = []

        for item in items {
            var photoFileName: String?

            if let photo = item.photo, let data = photo.jpegData(compressionQuality: 0.85) {
                let fileName = "\(item.id.uuidString).jpg"
                let fileURL = photosDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: fileURL)
                    photoFileName = fileName
                } catch {
                    print("❌ Fotoğraf kaydedilemedi: \(error.localizedDescription)")
                }
            }

            records.append(
                ClothingItemRecord(
                    id: item.id,
                    image: item.image,
                    photoFileName: photoFileName,
                    name: item.name,
                    category: item.category,
                    subcategory: item.subcategory,
                    color: item.color,
                    isFavorite: item.isFavorite
                )
            )
        }

        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: itemsFileURL)
        } catch {
            print("❌ Gardırop verisi kaydedilemedi: \(error.localizedDescription)")
        }
    }

    static func loadItems() -> [ClothingItem] {
        guard let data = try? Data(contentsOf: itemsFileURL),
              let records = try? JSONDecoder().decode([ClothingItemRecord].self, from: data) else {
            return []
        }

        return records.map { record in
            var photo: UIImage?
            if let fileName = record.photoFileName {
                let fileURL = photosDirectory.appendingPathComponent(fileName)
                photo = UIImage(contentsOfFile: fileURL.path)
            }

            return ClothingItem(
                id: record.id,
                image: record.image,
                photo: photo,
                name: record.name,
                category: record.category,
                subcategory: record.subcategory,
                color: record.color,
                isFavorite: record.isFavorite
            )
        }
    }

    /// Bir kıyafet silindiğinde, diskte kalan fotoğraf dosyasını da temizler.
    static func deletePhoto(for item: ClothingItem) {
        let fileURL = photosDirectory.appendingPathComponent("\(item.id.uuidString).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }
}
