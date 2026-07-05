//
//  OutfitPersistence.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import Foundation
import UIKit

/// Kaydedilmiş kombinleri (kolaj görselleriyle birlikte) cihazda kalıcı olarak saklar.
/// WardrobePersistence ile aynı prensip: veriler iCloud/iTunes yedeklerinden hariç tutulur,
/// böylece uygulama silinip yeniden yüklenirse eski kombinler geri gelmez.
enum OutfitPersistence {

    private static let outfitsFileName = "saved_outfits.json"
    private static let collagesFolderName = "OutfitCollages"

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private static var collagesDirectory: URL {
        let url = documentsDirectory.appendingPathComponent(collagesFolderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private static var outfitsFileURL: URL {
        documentsDirectory.appendingPathComponent(outfitsFileName)
    }

    private static func excludeFromBackup(_ fileURL: URL) {
        var url = fileURL
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? url.setResourceValues(values)
    }

    private struct SavedOutfitRecord: Codable {
        let id: UUID
        let name: String
        let itemIDs: [UUID]
        let collageFileName: String?
        let createdAt: Date
    }

    static func saveOutfits(_ outfits: [SavedOutfit]) {
        excludeFromBackup(documentsDirectory)
        excludeFromBackup(collagesDirectory)

        var records: [SavedOutfitRecord] = []

        for outfit in outfits {
            var collageFileName: String?

            // PNG - kolajın şeffaf köşelerinin korunması için.
            if let collage = outfit.collageImage, let data = collage.pngData() {
                let fileName = "\(outfit.id.uuidString).png"
                let fileURL = collagesDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: fileURL)
                    collageFileName = fileName
                } catch {
                    print("❌ Kombin görseli kaydedilemedi: \(error.localizedDescription)")
                }
            }

            records.append(
                SavedOutfitRecord(
                    id: outfit.id,
                    name: outfit.name,
                    itemIDs: outfit.itemIDs,
                    collageFileName: collageFileName,
                    createdAt: outfit.createdAt
                )
            )
        }

        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: outfitsFileURL)
        } catch {
            print("❌ Kombin verisi kaydedilemedi: \(error.localizedDescription)")
        }
    }

    static func loadOutfits() -> [SavedOutfit] {
        guard let data = try? Data(contentsOf: outfitsFileURL),
              let records = try? JSONDecoder().decode([SavedOutfitRecord].self, from: data) else {
            return []
        }

        return records.map { record in
            var collage: UIImage?
            if let fileName = record.collageFileName {
                let fileURL = collagesDirectory.appendingPathComponent(fileName)
                collage = UIImage(contentsOfFile: fileURL.path)
            }

            return SavedOutfit(
                id: record.id,
                name: record.name,
                itemIDs: record.itemIDs,
                collageImage: collage,
                createdAt: record.createdAt
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    /// Bir kombin silindiğinde, diskte kalan kolaj dosyasını da temizler.
    static func deleteCollage(for outfit: SavedOutfit) {
        let fileURL = collagesDirectory.appendingPathComponent("\(outfit.id.uuidString).png")
        try? FileManager.default.removeItem(at: fileURL)
    }
}
