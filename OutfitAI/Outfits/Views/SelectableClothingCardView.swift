//
//  SelectableClothingCardView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

/// WardrobeCardView'a benzer görsel dilde ama favori kalbi yerine
/// seçim durumunu (checkmark + kenarlık) gösteren, kombin oluşturma
/// ekranına özel hafif kart. Mevcut WardrobeCardView'ı değiştirmemek
/// için ayrı bir view olarak tutuldu.
struct SelectableClothingCardView: View {

    let item: ClothingItem
    let isSelected: Bool
    var onToggle: () -> Void = {}

    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            ZStack(alignment: .topTrailing) {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))

                if let photo = item.photo {

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .padding(12)

                } else {

                    Image(systemName: ClothingCategories.iconName(for: item.category))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(softPink)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                }

                // Seçim işareti
                ZStack {
                    Circle()
                        .fill(isSelected ? softPink : Color.white.opacity(0.9))
                        .frame(width: 26, height: 26)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .overlay(
                    Circle().stroke(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
                )
                .padding(8)

            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? softPink : .clear, lineWidth: 2.5)
            )

            Text(item.name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            Text(item.subcategory)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }

    }
}

#Preview {
    SelectableClothingCardView(
        item: ClothingItem(
            id: UUID(),
            image: "tshirt",
            photo: nil,
            name: "Oversize Hoodie",
            category: "Üst",
            subcategory: "Kapşonlu",
            color: "Siyah",
            isFavorite: false
        ),
        isSelected: true
    )
    .padding()
    .frame(width: 180)
}
