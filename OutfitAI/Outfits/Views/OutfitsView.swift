//
//  OutfitsView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct OutfitsView: View {

    @State private var savedOutfits: [SavedOutfit] = []
    @State private var showBuilder = false
    @State private var selectedOutfit: SavedOutfit?

    // Soft pembe - Wardrobe bölümüyle aynı vurgu rengi, başka dosyaya bağımlı olmasın diye burada tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottomTrailing) {

                ScrollView {

                    VStack(alignment: .leading, spacing: 20) {

                        if savedOutfits.isEmpty {

                            emptyState

                        } else {

                            LazyVGrid(columns: columns, spacing: 18) {

                                ForEach(savedOutfits) { outfit in

                                    SavedOutfitCardView(outfit: outfit) {
                                        selectedOutfit = outfit
                                    }

                                }

                            }

                        }

                    }
                    .padding()

                }

                Button {
                    showBuilder = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(softPink)
                        )
                        .shadow(color: softPink.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .padding()

            }
            

        }
        .onAppear {
            savedOutfits = OutfitPersistence.loadOutfits()
        }
        .sheet(isPresented: $showBuilder) {
            OutfitBuilderView { newOutfit in
                savedOutfits.insert(newOutfit, at: 0)
                OutfitPersistence.saveOutfits(savedOutfits)
            }
        }
        .sheet(item: $selectedOutfit) { outfit in
            SavedOutfitDetailView(outfit: outfit) {
                deleteOutfit(outfit)
            }
        }

    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(softPink.opacity(0.6))

            Text("Henüz kombin oluşturmadınız")
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)

            Text("Gardırop parçalarınızı kullanarak ilk kombininizi oluşturmak için sağ alttaki + butonuna dokunun")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func deleteOutfit(_ outfit: SavedOutfit) {
        savedOutfits.removeAll { $0.id == outfit.id }
        OutfitPersistence.deleteCollage(for: outfit)
        OutfitPersistence.saveOutfits(savedOutfits)
    }

}

#Preview {
    OutfitsView()
}
