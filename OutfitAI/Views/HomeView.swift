//
//  HomeView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SearchBarView(text: $viewModel.searchText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    if viewModel.isSearching {
                        searchResultsSection
                    } else {
                        defaultFeedSection
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Ana Sayfa")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Arama sonucu yokken gösterilen varsayılan akış

    private var defaultFeedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Bugün")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)

                FeaturedOutfitView(outfit: viewModel.featuredOutfit)
                    .padding(.horizontal, 20)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Keşfet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredOutfits) { outfit in
                        OutfitCardView(outfit: outfit) {
                            viewModel.toggleLike(for: outfit)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Arama yapılırken gösterilen sonuç listesi

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(searchResultsHeader)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            if viewModel.filteredOutfits.isEmpty {
                emptyResultsView
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredOutfits) { outfit in
                        OutfitCardView(outfit: outfit) {
                            viewModel.toggleLike(for: outfit)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var searchResultsHeader: String {
        let count = viewModel.filteredOutfits.count
        return viewModel.searchText.hasPrefix("@")
            ? "\(count) kullanıcı sonucu"
            : "\(count) sonuç bulundu"
    }

    private var emptyResultsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text("Sonuç bulunamadı")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    HomeView()
}
