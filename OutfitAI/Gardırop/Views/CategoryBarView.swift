//
//  CategoryBarView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct CategoryBarView: View {
    @Binding var selectedCategory: String

    private let categories = ["All", "Top", "Bottom", "Shoes", "Accessories"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? Color.wardrobeAccent
                                    : Color(.systemGray6)
                            )
                            .foregroundStyle(
                                selectedCategory == category ? .white : .primary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CategoryBarView(selectedCategory: .constant("All"))
        .padding()
}
