//
//  WardrobeView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct WardrobeView: View {

    @State private var selectedCategory: String = "All"
    @State private var showAddItem = false
    @State private var clothingItems: [ClothingItem] = []

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var filteredItems: [ClothingItem] {
        if selectedCategory == "All" {
            return clothingItems
        }

        return clothingItems.filter {
            $0.category == selectedCategory
        }
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottomTrailing) {

                ScrollView {

                    VStack(alignment: .leading, spacing: 20) {

                        CategoryBarView(
                            selectedCategory: $selectedCategory
                        )
                        .padding(.top, 8)

                        if clothingItems.isEmpty {

                            emptyState

                        } else {

                            LazyVGrid(columns: columns, spacing: 18) {

                                ForEach(filteredItems) { item in

                                    WardrobeCardView(item: item) {
                                        toggleFavorite(for: item)
                                    }

                                }

                            }

                        }

                    }
                    .padding()

                }

                Button {

                    showAddItem.toggle()

                } label: {

                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.wardrobeAccent)
                        .clipShape(Circle())
                        .shadow(radius: 10)

                }
                .padding()

            }
            .navigationBarHidden(true)

        }
        .onAppear {
            clothingItems = WardrobePersistence.loadItems()
        }
        .sheet(isPresented: $showAddItem) {

            AddItemView { newItem in
                clothingItems.append(newItem)
                WardrobePersistence.saveItems(clothingItems)
            }

        }

    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 40))
                .foregroundStyle(Color.wardrobeAccent.opacity(0.6))

            Text("Henüz kıyafet eklemediniz")
                .font(.system(size: 16, weight: .semibold))

            Text("Başlamak için sağ alttaki + butonuna dokunun")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func toggleFavorite(for item: ClothingItem) {
        guard let index = clothingItems.firstIndex(where: { $0.id == item.id }) else { return }
        clothingItems[index].isFavorite.toggle()
        WardrobePersistence.saveItems(clothingItems)
    }

}

#Preview {
    WardrobeView()
}
