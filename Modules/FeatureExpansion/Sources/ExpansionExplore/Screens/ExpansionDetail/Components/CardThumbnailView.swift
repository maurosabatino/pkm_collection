import SwiftUI
import CoreKit
import UIComponents

/// Mostra la miniatura della carta per la griglia in modo leggero (senza layer foil complessi).
struct CardThumbnailView: View {
    let card: CardViewModel
    let width: CGFloat

    var body: some View {
        let height = width * UIConstants.cardImageAspectRatio

        CachedImageView(
            url: card.imageUrl,
            size: CGSize(width: width, height: height),
            cornerRadius: UIConstants.cornerRadiusSmall,
            shadowRadius: UIConstants.shadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )
        .frame(width: width, height: height)
        .contentShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusLarge, style: .continuous))
    }
}


#Preview {
    
    let sampleCard = CardViewModel(
        cardData: CardData(
            name: "Preview Pikachu",
            cardType: .pokemon,
            lang: "en",
            foil: Foil(type: .rainbow, mask: .holo),
            size: .standard,
            back: .pokemon1999,
            regulationMark: "F",
            setIcon: "",
            collectorNumber: CollectorNumber(full: "12/100", numerator: "12", denominator: "100", numeric: 12),
            rarity: nil,
            stage: .basic,
            hp: 70,
            types: [.lightning],
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: "Un Pikachu radioso apparso solo per il preview.",
            ext: Extension(
                tcgl: TcglExtension(
                    cardID: UUID().uuidString,
                    longFormID: "preview",
                    archetypeID: "preview",
                    reldate: "2024-01-01",
                    key: "preview"
                )
            ),
            images: Images(
                tcgl: TcglImages(
                    tex: ImagePaths(
                        front: "https://cdn.malie.io/file/malie-io/tcgl/cards/tex/en/me2/me2_en_125_std.png",
                        back: nil,
                        foil: "https://cdn.malie.io/file/malie-io/tcgl/cards/tex/en/me2/me2_en_125_std.foil.png",
                        etch: "https://cdn.malie.io/file/malie-io/tcgl/cards/tex/en/me2/me2_en_125_std.etch.png"
                    ),
                    png: ImagePaths(
                        front: "https://cdn.malie.io/file/malie-io/tcgl/cards/png/en/me2/me2_en_125_std.png",
                        back: nil,
                        foil: "https://cdn.malie.io/file/malie-io/tcgl/cards/png/en/me2/me2_en_125_std.foil.png",
                        etch: "https://cdn.malie.io/file/malie-io/tcgl/cards/png/en/me2/me2_en_125_std.etch.png"
                    ),
                    jpg: nil
                )
            )
        )
    )
    
    
    CardThumbnailView(
        card: sampleCard,
        width: 200
    )
}
