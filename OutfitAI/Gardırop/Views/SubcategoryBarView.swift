//
//  SubcategoryBarView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct SubcategoryBarView: View {
    @Binding var selectedSubcategory: String
    let subcategories: [String]

    // Soft pembe - başka dosyaya bağımlı olmasın diye burada doğrudan tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Tümü"] + subcategories, id: \.self) { subcategory in
                    let isSelected = selectedSubcategory == subcategory

                    Button {
                        selectedSubcategory = subcategory
                    } label: {
                        Text(subcategory)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(isSelected ? softPink : Color(.systemGray5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    SubcategoryBarView(
        selectedSubcategory: .constant("Tümü"),
        subcategories: ClothingCategories.subcategories["Üst"] ?? []
    )
    .padding()
}
