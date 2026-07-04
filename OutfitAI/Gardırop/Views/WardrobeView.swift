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

    @State private var clothingItems: [ClothingItem] = [
        ClothingItem(
            image: "hoodie",
            photo: nil,
            name: "Black Hoodie",
            category: "Top",
            color: "Black",
            isFavorite: true
        ),
        ClothingItem(
            image: "shirt",
            photo: nil,
            name: "White Shirt",
            category: "Top",
            color: "White",
            isFavorite: false
        ),
        ClothingItem(
            image: "jeans",
            photo: nil,
            name: "Blue Jeans",
            category: "Bottom",
            color: "Blue",
            isFavorite: false
        ),
        ClothingItem(
            image: "shoe",
            photo: nil,
            name: "Nike Sneakers",
            category: "Shoes",
            color: "White",
            isFavorite: true
        )
    ]

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

                        Text("My Wardrobe")
                            .font(.largeTitle.bold())

                        CategoryBarView(
                            selectedCategory: $selectedCategory
                        )

                        LazyVGrid(columns: columns, spacing: 18) {

                            ForEach(filteredItems) { item in

                                WardrobeCardView(item: item) {
                                    toggleFavorite(for: item)
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
                        .background(.purple)
                        .clipShape(Circle())
                        .shadow(radius: 10)

                }
                .padding()

            }
            .navigationBarHidden(true)

        }
        .sheet(isPresented: $showAddItem) {

            AddItemView { newItem in
                clothingItems.append(newItem)
            }

        }

    }

    private func toggleFavorite(for item: ClothingItem) {
        guard let index = clothingItems.firstIndex(where: { $0.id == item.id }) else { return }
        clothingItems[index].isFavorite.toggle()
    }

}

#Preview {
    WardrobeView()
}
