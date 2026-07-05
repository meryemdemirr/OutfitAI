//
//  WardrobeCardView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct WardrobeCardView: View {

    let item: ClothingItem
    var onToggleFavorite: () -> Void = {}
    var onSelect: () -> Void = {}

    // Soft pembe - başka dosyaya bağımlı olmasın diye burada doğrudan tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            ZStack {

                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.systemGray6))

                if let photo = item.photo {

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .padding(14)

                } else {

                    Image(systemName: imageName(for: item.category))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .foregroundColor(softPink)

                }

            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(alignment: .leading, spacing: 6) {

                HStack {

                    Text(item.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    // Favori kalbi - her zaman görünür ve tıklanabilir.
                    Button(action: onToggleFavorite) {
                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 17))
                            .foregroundColor(item.isFavorite ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                }

                Text(item.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {

                    Circle()
                        .fill(color(for: item.color))
                        .frame(width: 12, height: 12)

                    Text(item.color)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                }

            }

        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }

    }

    private func imageName(for category: String) -> String {
        ClothingCategories.iconName(for: category)

    }

    private func color(for color: String) -> Color {

        switch color {

        case "Siyah":
            return .black

        case "Beyaz":
            return .gray

        case "Mavi":
            return .blue

        case "Gri":
            return .gray

        case "Kırmızı":
            return .red

        case "Yeşil":
            return .green

        case "Kahverengi":
            return .brown

        default:
            return .gray

        }

    }

}

#Preview {

    WardrobeCardView(
        item: ClothingItem(
            id: UUID(),
            image: "tshirt",
            photo: nil,
            name: "Oversize Hoodie",
            category: "Üst",
            subcategory: "Kapşonlu",
            color: "Siyah",
            isFavorite: true
        )
    )

}
