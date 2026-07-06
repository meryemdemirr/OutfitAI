//
//  ProfileView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 6.07.2026.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Keyboard

    private func hideKeyboard() {

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    // MARK: - Data

    @State private var wardrobeItems: [ClothingItem] = []
    @State private var savedOutfits: [SavedOutfit] = []

    @State private var selectedOutfit: SavedOutfit?


    // MARK: - Tab

    @State private var selectedTab: ProfileTab = .items


    // MARK: - Search

    @State private var searchText = ""


    // MARK: - Filter

    @State private var selectedCategory = "Tümü"

    @State private var itemSortOption: ItemSortOption = .newest

    @State private var outfitSortOption: OutfitSortOption = .newest

    @State private var showFilterSheet = false


    // MARK: - Colors

    private let softPink = Color(
        red: 0.957,
        green: 0.561,
        blue: 0.694
    )


    // MARK: - Grid

    private let columns = [

        GridItem(
            .flexible(),
            spacing: 14
        ),

        GridItem(
            .flexible(),
            spacing: 14
        )
    ]


    // MARK: - Filtered Items

    private var filteredItems: [ClothingItem] {

        var items = wardrobeItems


        // Kategori filtresi

        if selectedCategory != "Tümü" {

            items = items.filter {
                $0.category == selectedCategory
            }
        }


        // Arama

        if !searchText.isEmpty {

            let search =
                searchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

            items = items.filter { item in

                item.name
                    .lowercased()
                    .contains(search)

                ||

                item.category
                    .lowercased()
                    .contains(search)

                ||

                item.subcategory
                    .lowercased()
                    .contains(search)

                ||

                item.color
                    .lowercased()
                    .contains(search)
            }
        }


        // Sıralama

        switch itemSortOption {

        case .newest:

            break


        case .oldest:

            items.reverse()


        case .alphabetical:

            items.sort {

                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedAscending
            }


        case .reverseAlphabetical:

            items.sort {

                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedDescending
            }
        }


        return items
    }


    // MARK: - Filtered Outfits

    private var filteredOutfits: [SavedOutfit] {

        var outfits = savedOutfits


        // Arama

        if !searchText.isEmpty {

            let search =
                searchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

            outfits = outfits.filter {

                $0.name
                    .lowercased()
                    .contains(search)
            }
        }


        // Sıralama

        switch outfitSortOption {

        case .newest:

            outfits.sort {
                $0.createdAt > $1.createdAt
            }


        case .oldest:

            outfits.sort {
                $0.createdAt < $1.createdAt
            }


        case .alphabetical:

            outfits.sort {

                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedAscending
            }


        case .reverseAlphabetical:

            outfits.sort {

                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedDescending
            }
        }


        return outfits
    }


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    profileHeader

                    statisticsSection

                    tabSection

                    searchAndFilterSection

                    contentSection
                }
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        hideKeyboard()
                    }
            )
            .background(
                Color(.systemGroupedBackground)
            )
            .onAppear {

                loadData()
            }
            .sheet(
                item: $selectedOutfit
            ) { outfit in

                SavedOutfitDetailView(
                    outfit: outfit
                ) {

                    deleteOutfit(outfit)
                }
            }
            .sheet(
                isPresented: $showFilterSheet
            ) {

                filterSheet
                    .presentationDetents([
                        .medium
                    ])
                    .presentationDragIndicator(
                        .visible
                    )
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
                .font(
                    .system(size: 14)
                )
                .foregroundStyle(
                    .secondary
                )
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
                    .foregroundColor(
                        softPink
                    )
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
                    .font(
                        .system(size: 12)
                    )
                    .foregroundStyle(
                        .secondary
                    )
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


    // MARK: - Tabs

    private var tabSection: some View {

        HStack(spacing: 0) {

            tabButton(
                title: "Parçalar",
                count: wardrobeItems.count,
                tab: .items
            )


            tabButton(
                title: "Kombinler",
                count: savedOutfits.count,
                tab: .outfits
            )
        }
        .padding(.horizontal, 20)
    }


    private func tabButton(
        title: String,
        count: Int,
        tab: ProfileTab
    ) -> some View {

        Button {

            withAnimation(
                .easeInOut(duration: 0.2)
            ) {

                selectedTab = tab

                searchText = ""
            }

        } label: {

            VStack(spacing: 10) {

                HStack(spacing: 5) {

                    Text(title)

                    Text("\(count)")
                        .font(
                            .system(
                                size: 12,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            .secondary
                        )
                }
                .font(
                    .system(
                        size: 15,
                        weight:
                            selectedTab == tab
                            ? .semibold
                            : .regular
                    )
                )
                .foregroundColor(
                    selectedTab == tab
                    ? .primary
                    : .secondary
                )


                Rectangle()
                    .fill(
                        selectedTab == tab
                        ? softPink
                        : Color.clear
                    )
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }


    // MARK: - Search And Filter

    private var searchAndFilterSection: some View {

        HStack(spacing: 10) {

            HStack(spacing: 10) {

                Image(
                    systemName: "magnifyingglass"
                )
                .foregroundStyle(
                    .secondary
                )


                TextField(
                    selectedTab == .items
                    ? "Parçalarda ara"
                    : "Kombinlerde ara",
                    text: $searchText
                )
                .textInputAutocapitalization(
                    .never
                )
                .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                Color(.systemBackground)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )


            Button {

                hideKeyboard()
                
                showFilterSheet = true

            } label: {

                Image(
                    systemName: "slider.horizontal.3"
                )
                .font(
                    .system(
                        size: 18,
                        weight: .medium
                    )
                )
                .foregroundColor(
                    hasActiveFilter
                    ? softPink
                    : .primary
                )
                .frame(
                    width: 48,
                    height: 48
                )
                .background(
                    Color(.systemBackground)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }


    // MARK: - Active Filter

    private var hasActiveFilter: Bool {

        switch selectedTab {

        case .items:

            return
                selectedCategory != "Tümü"
                ||
                itemSortOption != .newest


        case .outfits:

            return
                outfitSortOption != .newest
        }
    }


    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {

        switch selectedTab {

        case .items:

            wardrobeSection


        case .outfits:

            outfitsSection
        }
    }


    // MARK: - Wardrobe

    private var wardrobeSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            itemCountText(
                filteredItems.count
            )


            if filteredItems.isEmpty {

                emptyState(
                    icon: "tshirt",
                    title: "Parça bulunamadı",
                    message:
                        searchText.isEmpty
                        ? "Bu filtreye uygun parça bulunmuyor."
                        : "Aramanızla eşleşen parça bulunamadı."
                )

            } else {

                LazyVGrid(
                    columns: columns,
                    spacing: 16
                ) {

                    ForEach(
                        filteredItems
                    ) { item in

                        ProfileClothingCardView(
                            item: item
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }


    // MARK: - Outfits

    private var outfitsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            itemCountText(
                filteredOutfits.count
            )


            if filteredOutfits.isEmpty {

                emptyState(
                    icon: "sparkles",
                    title: "Kombin bulunamadı",
                    message:
                        searchText.isEmpty
                        ? "Henüz kaydedilmiş bir kombin bulunmuyor."
                        : "Aramanızla eşleşen kombin bulunamadı."
                )

            } else {

                LazyVGrid(
                    columns: columns,
                    spacing: 16
                ) {

                    ForEach(
                        filteredOutfits
                    ) { outfit in

                        SavedOutfitCardView(
                            outfit: outfit
                        ) {

                            selectedOutfit =
                                outfit
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }


    // MARK: - Item Count

    private func itemCountText(
        _ count: Int
    ) -> some View {

        HStack {

            Spacer()

            Text("\(count) öğe")
                .font(
                    .system(size: 13)
                )
                .foregroundStyle(
                    .secondary
                )
        }
        .padding(.horizontal, 20)
    }


    // MARK: - Filter Sheet

    private var filterSheet: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {

                    if selectedTab == .items {

                        itemFilterContent

                    } else {

                        outfitFilterContent
                    }
                }
                .padding(20)
            }
            .navigationTitle("Filtrele")
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Sıfırla") {

                        resetFilters()
                    }
                    .foregroundColor(
                        softPink
                    )
                }


                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Bitti") {
                        hideKeyboard()

                        showFilterSheet = false
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(
                        softPink
                    )
                }
            }
        }
    }


    // MARK: - Item Filter

    private var itemFilterContent: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            filterTitle(
                "Kategori"
            )


            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 100))
                ],
                spacing: 10
            ) {

                ForEach(
                    ["Tümü"] + ClothingCategories.main,
                    id: \.self
                ) { category in

                    filterButton(
                        title: category,
                        isSelected:
                            selectedCategory
                            == category
                    ) {

                        selectedCategory =
                            category
                    }
                }
            }


            filterTitle(
                "Sıralama"
            )


            VStack(spacing: 10) {

                ForEach(
                    ItemSortOption.allCases
                ) { option in

                    sortButton(
                        title: option.title,
                        isSelected:
                            itemSortOption
                            == option
                    ) {

                        itemSortOption =
                            option
                    }
                }
            }
        }
    }


    // MARK: - Outfit Filter

    private var outfitFilterContent: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            filterTitle(
                "Sıralama"
            )


            VStack(spacing: 10) {

                ForEach(
                    OutfitSortOption.allCases
                ) { option in

                    sortButton(
                        title: option.title,
                        isSelected:
                            outfitSortOption
                            == option
                    ) {

                        outfitSortOption =
                            option
                    }
                }
            }
        }
    }


    // MARK: - Filter Title

    private func filterTitle(
        _ title: String
    ) -> some View {

        Text(title)
            .font(
                .system(
                    size: 17,
                    weight: .semibold
                )
            )
    }


    // MARK: - Filter Button

    private func filterButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(
            action: action
        ) {

            Text(title)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundColor(
                    isSelected
                    ? .white
                    : .primary
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(
                    .vertical,
                    11
                )
                .background(
                    isSelected
                    ? softPink
                    : Color(.systemGray6)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
    }


    // MARK: - Sort Button

    private func sortButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(
            action: action
        ) {

            HStack {

                Text(title)
                    .foregroundColor(
                        .primary
                    )


                Spacer()


                Image(
                    systemName:
                        isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundColor(
                    isSelected
                    ? softPink
                    : .secondary
                )
            }
            .padding(14)
            .background(
                Color(.systemGray6)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }


    // MARK: - Reset Filters

    private func resetFilters() {

        switch selectedTab {

        case .items:

            selectedCategory = "Tümü"

            itemSortOption = .newest


        case .outfits:

            outfitSortOption = .newest
        }
    }


    // MARK: - Empty State

    private func emptyState(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 10) {

            Image(systemName: icon)
                .font(
                    .system(size: 34)
                )
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
                .font(
                    .system(size: 13)
                )
                .foregroundStyle(
                    .secondary
                )
                .multilineTextAlignment(
                    .center
                )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .vertical,
            50
        )
        .padding(
            .horizontal,
            30
        )
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


// MARK: - Profile Tab

private enum ProfileTab {

    case items

    case outfits
}


// MARK: - Item Sort Option

private enum ItemSortOption:
    String,
    CaseIterable,
    Identifiable {

    case newest

    case oldest

    case alphabetical

    case reverseAlphabetical


    var id: String {
        rawValue
    }


    var title: String {

        switch self {

        case .newest:

            return "En Yeni"


        case .oldest:

            return "En Eski"


        case .alphabetical:

            return "A - Z"


        case .reverseAlphabetical:

            return "Z - A"
        }
    }
}


// MARK: - Outfit Sort Option

private enum OutfitSortOption:
    String,
    CaseIterable,
    Identifiable {

    case newest

    case oldest

    case alphabetical

    case reverseAlphabetical


    var id: String {
        rawValue
    }


    var title: String {

        switch self {

        case .newest:

            return "En Yeni"


        case .oldest:

            return "En Eski"


        case .alphabetical:

            return "A - Z"


        case .reverseAlphabetical:

            return "Z - A"
        }
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
                    .font(
                        .system(size: 38)
                    )
                    .foregroundStyle(
                        .secondary
                    )
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
                .font(
                    .system(size: 12)
                )
                .foregroundStyle(
                    .secondary
                )
                .lineLimit(1)
        }
    }
}


#Preview {

    ProfileView()
}
