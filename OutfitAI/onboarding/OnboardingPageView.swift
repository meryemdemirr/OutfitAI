//
//  OnboardingPageView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 3.07.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(page.accentColor.opacity(0.10))
                    .frame(width: 170, height: 170)

                Image(systemName: page.systemImage)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(page.accentColor)
            }
            .scaleEffect(isActive ? 1.0 : 0.85)
            .opacity(isActive ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isActive)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 36)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(isActive ? 1.0 : 0.0)
            .offset(y: isActive ? 0 : 12)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: isActive)

            Spacer()
            Spacer()
        }
    }
}
