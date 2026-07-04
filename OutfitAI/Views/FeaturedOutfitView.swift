//
//  FeaturedOutfitView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct FeaturedOutfitView: View {
    let outfit: Outfit

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: outfit.accentColor), Color(hex: outfit.accentColor).opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)

            Image(systemName: outfit.imageName)
                .font(.system(size: 90, weight: .light))
                .foregroundStyle(.white.opacity(0.18))
                .offset(x: 90, y: -10)

            VStack(alignment: .leading, spacing: 6) {
                Text("GÜNÜN KOMBİNİ")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.85))

                Text(outfit.title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("@\(outfit.handle) tarafından")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
