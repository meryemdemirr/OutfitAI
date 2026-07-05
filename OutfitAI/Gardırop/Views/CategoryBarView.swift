//
//  CategoryBarView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct CategoryBarView: View {
    @Binding var selectedCategory: String

    static let categories = ["Tümü"] + ClothingCategories.main

    // Soft pembe - başka dosyaya bağımlı olmasın diye burada doğrudan tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Self.categories, id: \.self) { category in
                    let isSelected = selectedCategory == category

                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? softPink : Color(.systemGray6))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CategoryBarView(selectedCategory: .constant("Tümü"))
        .padding()
}
