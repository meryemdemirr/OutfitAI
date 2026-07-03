//
//  OnboardingView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 3.07.2026.
//

import SwiftUI

struct OnboardingView: View {
    /// Onboarding tamamlandığında (bitir ya da atla) tetiklenir.
    var onComplete: () -> Void

    @State private var currentPage = 0
    private let pages = OnboardingPage.all

    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Üst bar: atla butonu
                HStack {
                    Spacer()
                    if !isLastPage {
                        Button(action: onComplete) {
                            Text("Atla")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                    }
                }
                .frame(height: 44)

                // Sayfalar
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Sayfa göstergesi
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? pages[currentPage].accentColor : Color(.systemGray4))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 28)

                // Devam / Başla butonu
                Button(action: handlePrimaryAction) {
                    Text(isLastPage ? "Başlayalım" : "Devam Et")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }

    private func handlePrimaryAction() {
        if isLastPage {
            onComplete()
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
