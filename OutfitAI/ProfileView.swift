//
//  ProfileView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 6.07.2026.
//

import SwiftUI

struct ProfileView: View {

    @State private var wardrobeItems: [ClothingItem] = []
    @State private var savedOutfits: [SavedOutfit] = []

    @State private var selectedCategory: String = "Tümü"
    @State private var selectedOutfit: SavedOutfit?

    private let softPink = Color(
        red: 0.957,
        green: 0.561,
        blue: 0.694
    )

    private let categories = [
        "Tümü",
        "Üst",
        "Alt",
        "Dış Giyim",
        "Ayakkabı",
        "Çanta",
        "Aksesuar",
        "Kombinler"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filteredItems: [ClothingItem] {

        if selectedCategory == "Tümü" {
            return wardrobeItems
        }

        return wardrobeItems.filter {
            $0.category == selectedCategory
        }
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    profileHeader

                    statisticsSection

                    categoryBar

                    contentSection
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                loadData()
            }
            .sheet(item: $selectedOutfit) { outfit in

                SavedOutfitDetailView(
                    outfit: outfit
                ) {
                    deleteOutfit(outfit)
                }
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {

        VStack(spacing: 12) {

            ZStack {

                Circle()
                    .fill(
                        softPink.opacity(0.15)
                    )
                    .frame(
                        width: 90,
                        height: 90
                    )

                Image(
                    systemName: "person.fill"
                )
                .font(
                    .system(size: 38)
                )
                .foregroundColor(softPink)
            }

            Text("Gardırobum")
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )

            Text("Kişisel stil koleksiyonum")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    // MARK: - Statistics

    private var statisticsSection: some View {

        HStack(spacing: 16) {

            statisticCard(
                value: wardrobeItems.count,
                title: "Parça",
                icon: "tshirt"
            )

            statisticCard(
                value: savedOutfits.count,
                title: "Kombin",
                icon: "sparkles"
            )
        }
        .padding(.horizontal, 20)
    }

    private func statisticCard(
        value: Int,
        title: String,
        icon: String
    ) -> some View {

        HStack(spacing: 12) {

            ZStack {

                Circle()
                    .fill(
                        softPink.opacity(0.13)
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(softPink)
            }

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text("\(value)")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )

                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            Color(.systemBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Category Bar

    private var categoryBar: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: 10) {

                ForEach(
                    categories,
                    id: \.self
                ) { category in

                    Button {

                        withAnimation(
                            .easeInOut(duration: 0.2)
                        ) {
                            selectedCategory = category
                        }

                    } label: {

                        Text(category)
                            .font(
                                .system(
                                    size: 14,
                                    weight:
                                        selectedCategory == category
                                        ? .semibold
                                        : .medium
                                )
                            )
                            .foregroundColor(
                                selectedCategory == category
                                ? .white
                                : .primary
                            )
                            .padding(
                                .horizontal,
                                16
                            )
                            .padding(
                                .vertical,
                                9
                            )
                            .background(
                                selectedCategory == category
                                ? softPink
                                : Color(.systemBackground)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {

        if selectedCategory == "Kombinler" {

            outfitsSection

        } else {

            wardrobeSection
        }
    }

    // MARK: - Wardrobe Section

    private var wardrobeSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionHeader(
                title: selectedCategory == "Tümü"
                    ? "Tüm Parçalar"
                    : selectedCategory,
                count: filteredItems.count
            )

            if filteredItems.isEmpty {

                emptyState(
                    icon: "tshirt",
                    title: "Bu kategoride parça yok",
                    message: "Gardırobunuza yeni parçalar ekleyebilirsiniz."
                )

            } else {

                LazyVGrid(
                    columns: columns,
                    spacing: 16
                ) {

                    ForEach(filteredItems) { item in

                        ProfileClothingCardView(
                            item: item
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Outfits Section

    private var outfitsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionHeader(
                title: "Kombinlerim",
                count: savedOutfits.count
            )

            if savedOutfits.isEmpty {

                emptyState(
                    icon: "sparkles",
                    title: "Henüz kombin yok",
                    message: "Gardırobunuzdaki parçaları kullanarak kombin oluşturabilirsiniz."
                )

            } else {

                LazyVGrid(
                    columns: columns,
                    spacing: 16
                ) {

                    ForEach(savedOutfits) { outfit in

                        SavedOutfitCardView(
                            outfit: outfit
                        ) {
                            selectedOutfit = outfit
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(
        title: String,
        count: Int
    ) -> some View {

        HStack {

            Text(title)
                .font(
                    .system(
                        size: 19,
                        weight: .bold
                    )
                )

            Spacer()

            Text("\(count) öğe")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Empty State

    private func emptyState(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 10) {

            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundColor(
                    softPink.opacity(0.6)
                )

            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .padding(.horizontal, 30)
    }

    // MARK: - Data

    private func loadData() {

        wardrobeItems =
            WardrobePersistence.loadItems()

        savedOutfits =
            OutfitPersistence.loadOutfits()
    }

    // MARK: - Delete Outfit

    private func deleteOutfit(
        _ outfit: SavedOutfit
    ) {

        savedOutfits.removeAll {
            $0.id == outfit.id
        }

        OutfitPersistence.deleteCollage(
            for: outfit
        )

        OutfitPersistence.saveOutfits(
            savedOutfits
        )
    }
}


// MARK: - Profile Clothing Card

private struct ProfileClothingCardView: View {

    let item: ClothingItem

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(
                    Color(.systemGray6)
                )

                if let photo = item.photo {

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .padding(12)

                } else {

                    Image(
                        systemName:
                            ClothingCategories
                            .iconName(
                                for: item.category
                            )
                    )
                    .font(.system(size: 38))
                    .foregroundStyle(.secondary)
                }
            }
            .frame(height: 160)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )

            Text(item.name)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .lineLimit(1)

            Text(item.subcategory)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}


#Preview {

    ProfileView()
}
