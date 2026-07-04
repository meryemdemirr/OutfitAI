//
//  CategoryBarView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct CategoryBarView: View {

    @Binding var selectedCategory: String

    let categories = [
        "All",
        "Top",
        "Bottom",
        "Shoes",
        "Accessories"
    ]

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 12) {

                ForEach(categories, id: \.self) { category in

                    Button {

                        withAnimation(.easeInOut) {
                            selectedCategory = category
                        }

                    } label: {

                        Text(category)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(
                                selectedCategory == category
                                ? .white
                                : .primary
                            )
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category
                                ? Color.purple
                                : Color(.systemGray6)
                            )
                            .clipShape(Capsule())

                    }
                    .buttonStyle(.plain)

                }

            }
            .padding(.horizontal)

        }

    }

}

#Preview {

    CategoryBarView(
        selectedCategory: .constant("All")
    )

}
