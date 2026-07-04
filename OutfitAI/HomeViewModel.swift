//
//  HomeViewModel.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var allOutfits: [Outfit] = Outfit.mock
    @Published var featuredOutfit: Outfit = Outfit.todaysFeatured

    /// Arama metnine göre filtrelenmiş kombinler.
    /// "@kullaniciadi" yazılırsa sadece o kullanıcının kombinleri gelir.
    /// Düz metin yazılırsa hem kombin başlığında hem kullanıcı adında arama yapılır.
    var filteredOutfits: [Outfit] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return allOutfits.sorted { $0.createdAt > $1.createdAt }
        }

        if query.hasPrefix("@") {
            let handleQuery = String(query.dropFirst()).lowercased()
            guard !handleQuery.isEmpty else { return allOutfits }
            return allOutfits.filter { $0.handle.lowercased().contains(handleQuery) }
        }

        let lowered = query.lowercased()
        return allOutfits.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.username.lowercased().contains(lowered) ||
            $0.handle.lowercased().contains(lowered)
        }
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toggleLike(for outfit: Outfit) {
        guard let index = allOutfits.firstIndex(where: { $0.id == outfit.id }) else { return }
        allOutfits[index].isLikedByCurrentUser.toggle()
        allOutfits[index].likeCount += allOutfits[index].isLikedByCurrentUser ? 1 : -1
    }
}
