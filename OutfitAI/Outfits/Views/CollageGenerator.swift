//
//  CollageGenerator.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import UIKit
import SwiftUI

enum CollageGenerator {

    // Kaydedilen kombin görselinin boyutu HER ZAMAN sabit.
    static let canvasSize = CGSize(
        width: 1080,
        height: 1440
    )

    // Editörde gösterilen ürünlerin temel boyutu.
    static let editorItemSize = CGSize(
        width: 180,
        height: 220
    )

    static func generate(
        from items: [EditableOutfitItem],
        backgroundColor: UIColor,
        editorSize: CGSize
    ) -> UIImage? {

        guard !items.isEmpty else {
            print("❌ CollageGenerator: Ürün bulunamadı")
            return nil
        }

        guard editorSize.width > 0,
              editorSize.height > 0 else {
            print("❌ CollageGenerator: Editör boyutu geçersiz")
            return nil
        }

        let format = UIGraphicsImageRendererFormat()

        format.opaque = true
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: canvasSize,
            format: format
        )

        let image = renderer.image { rendererContext in

            let context = rendererContext.cgContext

            // MARK: - Sabit Arka Plan

            backgroundColor.setFill()

            context.fill(
                CGRect(
                    origin: .zero,
                    size: canvasSize
                )
            )

            // MARK: - Sabit Canvas Oranı

            let scaleX =
                canvasSize.width / editorSize.width

            let scaleY =
                canvasSize.height / editorSize.height

            // Ürünlerin konumuna göre herhangi bir
            // zoom / crop / yeniden kadrajlama YAPILMIYOR.

            for item in items {

                guard let photo =
                        item.clothingItem.photo else {
                    continue
                }

                drawItem(
                    photo,
                    item: item,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: context
                )
            }
        }

        print(
            "✅ Sabit canvas oluşturuldu: \(image.size)"
        )

        return image
    }

    // MARK: - Draw Item

    private static func drawItem(
        _ image: UIImage,
        item: EditableOutfitItem,
        scaleX: CGFloat,
        scaleY: CGFloat,
        in context: CGContext
    ) {

        let imageSize = image.size

        guard imageSize.width > 0,
              imageSize.height > 0 else {
            return
        }

        // Editördeki 180x220 ürün alanını
        // çıktı canvasına birebir oranlıyoruz.

        let baseWidth =
            editorItemSize.width * scaleX

        let baseHeight =
            editorItemSize.height * scaleY

        let imageAspect =
            imageSize.width / imageSize.height

        let boxAspect =
            baseWidth / baseHeight

        var drawSize = CGSize(
            width: baseWidth,
            height: baseHeight
        )

        // Aspect Fit
        // Görselin oranı kesinlikle bozulmaz.

        if imageAspect > boxAspect {

            drawSize.width = baseWidth

            drawSize.height =
                baseWidth / imageAspect

        } else {

            drawSize.height = baseHeight

            drawSize.width =
                baseHeight * imageAspect
        }

        // Kullanıcının verdiği büyüklük.

        drawSize.width *= item.scale
        drawSize.height *= item.scale

        // Editördeki konumu,
        // sabit canvas koordinatına dönüştürüyoruz.

        let centerX =
            canvasSize.width / 2
            + item.position.width * scaleX

        let centerY =
            canvasSize.height / 2
            + item.position.height * scaleY

        context.saveGState()

        // Konum

        context.translateBy(
            x: centerX,
            y: centerY
        )

        // Döndürme

        context.rotate(
            by: CGFloat(
                item.rotation.radians
            )
        )

        let drawRect = CGRect(

            x: -drawSize.width / 2,

            y: -drawSize.height / 2,

            width: drawSize.width,

            height: drawSize.height
        )

        image.draw(in: drawRect)

        context.restoreGState()
    }
}
