//
//  SavedOutfitCardView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

/// Kombinler ekranındaki grid'de kullanılan kart.
/// WardrobeCardView ile aynı köşe/gölge/tipografi dilini kullanır.
struct SavedOutfitCardView: View {

    let outfit: SavedOutfit
    var onSelect: () -> Void = {}

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            ZStack {

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemGray6))

                if let collage = outfit.collageImage {

                    Image(uiImage: collage)
                        .resizable()
                        .aspectRatio(CollageGenerator.canvasSize, contentMode: .fill)

                } else {

                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)

                }

            }
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 22))

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
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
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
            itemIDs: [UUID(), UUID(), UUID()],
            collageImage: nil,
            createdAt: Date()
        )
    )
    .frame(width: 170)
}
