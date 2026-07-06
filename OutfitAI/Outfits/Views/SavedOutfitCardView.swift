//
//  SavedOutfitCardView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

/// Kombinler ekranındaki grid'de kullanılan kart.
/// Kaydedilen kombin görselini kırpmadan ve yakınlaştırmadan gösterir.
struct SavedOutfitCardView: View {

    let outfit: SavedOutfit
    var onSelect: () -> Void = {}

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            // MARK: - Kombin Görseli

            ZStack {

                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
                .fill(Color(.systemGray6))

                if let collage = outfit.collageImage {

                    Image(uiImage: collage)
                        .resizable()

                        // Görselin tamamını gösterir.
                        // Yakınlaştırma veya kırpma yapmaz.
                        .scaledToFit()

                        // Kartın mevcut alanını kullanır.
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                } else {

                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                }

            }

            // Kaydedilen kombin canvas'ıyla aynı oran.
            // Canvas: 1080 x 1440 = 3:4
            .aspectRatio(
                3.0 / 4.0,
                contentMode: .fit
            )

            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )

            // MARK: - Kombin Bilgileri

            VStack(alignment: .leading, spacing: 2) {

                Text(outfit.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(outfit.itemIDs.count) parça")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }

        .padding(10)

        .background(.background)

        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )

        .shadow(
            color: .black.opacity(0.08),
            radius: 10,
            x: 0,
            y: 5
        )

        .contentShape(Rectangle())

        .onTapGesture {
            onSelect()
        }
    }
}


#Preview {

    SavedOutfitCardView(

        outfit: SavedOutfit(
            id: UUID(),
            name: "Hafta Sonu Kombini",
            itemIDs: [
                UUID(),
                UUID(),
                UUID()
            ],
            collageImage: nil,
            createdAt: Date()
        )
    )

    .frame(width: 170)
}
