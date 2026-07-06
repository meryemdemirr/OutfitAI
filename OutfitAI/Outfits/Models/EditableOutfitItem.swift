//
//  EditableOutfitItem.swift
//  OutfitAI
//
//  Created by Meryem Demir on 6.07.2026.
//

import SwiftUI

struct EditableOutfitItem: Identifiable {

    let id: UUID
    let clothingItem: ClothingItem

    var position: CGSize
    var lastPosition: CGSize

    var scale: CGFloat
    var lastScale: CGFloat

    var rotation: Angle
    var lastRotation: Angle

    init(
        clothingItem: ClothingItem,
        position: CGSize = .zero,
        scale: CGFloat = 1.0,
        rotation: Angle = .zero
    ) {

        self.id = clothingItem.id
        self.clothingItem = clothingItem

        self.position = position
        self.lastPosition = position

        self.scale = scale
        self.lastScale = scale

        self.rotation = rotation
        self.lastRotation = rotation
    }
}
