//
//  OutfitCardView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct OutfitCardView: View {
    let outfit: Outfit
    var onLikeTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: outfit.accentColor).opacity(0.18))

                Image(systemName: outfit.imageName)
                    .font(.system(size: 46, weight: .medium))
                    .foregroundStyle(Color(hex: outfit.accentColor))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: outfit.accentColor).opacity(0.3))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Text(outfit.username.prefix(1))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: outfit.accentColor))
                        )

                    Text("@\(outfit.handle)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(outfit.category.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: outfit.accentColor).opacity(0.15))
                        .foregroundStyle(Color(hex: outfit.accentColor))
                        .clipShape(Capsule())
                }

                Text(outfit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Button(action: onLikeTapped) {
                        Image(systemName: outfit.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .foregroundStyle(outfit.isLikedByCurrentUser ? .red : .secondary)
                            .font(.system(size: 15))
                    }
                    .buttonStyle(.plain)

                    Text("\(outfit.likeCount)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
