//
//  CollageGenerator.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import UIKit
import SwiftUI

enum CollageGenerator {

    /// Kaydedilen kombin görselinin sabit boyutu.
    static let canvasSize = CGSize(
        width: 1080,
        height: 1440
    )

    /// OutfitEditorView içinde ürünlere verilen temel frame.
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

            // MARK: - Arka Plan

            backgroundColor.setFill()

            context.fill(
                CGRect(
                    origin: .zero,
                    size: canvasSize
                )
            )

            /*
             Editör canvas'ının TAMAMI kaydedilecek.

             Ürünlerin birbirine yakın veya uzak olması
             hiçbir şekilde kadrajı değiştirmeyecek.

             Tek bir ölçek değeri kullanıyoruz.
             */

            let canvasScale = min(
                canvasSize.width / editorSize.width,
                canvasSize.height / editorSize.height
            )

            /*
             Editörün çıktı canvas'ında kapladığı gerçek alan.
             */

            let renderedEditorWidth =
                editorSize.width * canvasScale

            let renderedEditorHeight =
                editorSize.height * canvasScale

            /*
             Canvas ortalama farkları.

             Böylece editör 1080x1440 içine
             tam ortalanır.
             */

            let canvasOffsetX =
                (canvasSize.width - renderedEditorWidth) / 2

            let canvasOffsetY =
                (canvasSize.height - renderedEditorHeight) / 2

            let sortedItems = items.sorted {
                $0.zIndex < $1.zIndex
            }

            for item in sortedItems {

                guard let photo = item.clothingItem.photo else {
                    continue
                }

                drawItem(
                    photo,
                    item: item,
                    canvasScale: canvasScale,
                    canvasOffsetX: canvasOffsetX,
                    canvasOffsetY: canvasOffsetY,
                    editorSize: editorSize,
                    in: context
                )
            }

        }

        print("✅ Sabit canvas oluşturuldu: \(image.size)")

        return image
    }

    // MARK: - Draw Item

    private static func drawItem(
        _ image: UIImage,
        item: EditableOutfitItem,
        canvasScale: CGFloat,
        canvasOffsetX: CGFloat,
        canvasOffsetY: CGFloat,
        editorSize: CGSize,
        in context: CGContext
    ) {

        let imageSize = image.size

        guard imageSize.width > 0,
              imageSize.height > 0 else {
            return
        }

        // MARK: - Ürün Boyutu

        /*
         Editörde ürün:

         180 x 220

         frame içinde gösteriliyor.

         Aynı boyutu sadece çıktı canvas'ına
         oranlayarak kaydediyoruz.
         */

        let baseWidth =
            editorItemSize.width * canvasScale

        let baseHeight =
            editorItemSize.height * canvasScale

        let imageAspect =
            imageSize.width / imageSize.height

        let boxAspect =
            baseWidth / baseHeight

        var drawSize = CGSize(
            width: baseWidth,
            height: baseHeight
        )

        // MARK: - Aspect Fit

        if imageAspect > boxAspect {

            drawSize.width = baseWidth

            drawSize.height =
                baseWidth / imageAspect

        } else {

            drawSize.height = baseHeight

            drawSize.width =
                baseHeight * imageAspect
        }

        // Kullanıcının editörde verdiği büyüklük.

        drawSize.width *= item.scale
        drawSize.height *= item.scale

        // MARK: - Konum

        /*
         Editörde bütün ürünler canvas'ın
         merkezinden position offset'i alıyor.

         Aynı sistemi çıktı görseline taşıyoruz.
         */

        let editorCenterX =
            editorSize.width / 2

        let editorCenterY =
            editorSize.height / 2

        let centerX =
            canvasOffsetX
            + (editorCenterX + item.position.width)
            * canvasScale

        let centerY =
            canvasOffsetY
            + (editorCenterY + item.position.height)
            * canvasScale

        // MARK: - Çizim

        context.saveGState()

        context.translateBy(
            x: centerX,
            y: centerY
        )

        context.rotate(
            by: CGFloat(item.rotation.radians)
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
