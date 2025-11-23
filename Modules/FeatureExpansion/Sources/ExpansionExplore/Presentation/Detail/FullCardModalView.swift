//
//  FullCardModalView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import CoreKit

struct FullCardModalView: View {
    let card: CardViewModel
    @Binding var isShowingModal: Bool
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore
    @State private var isShowingFullScreenImage = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColors.modalBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: UIConstants.paddingLarge) {
                        cardImageSection
                        titleSection

                        sectionContainer(title: "Dettagli carta") {
                            let items = detailItems
                            VStack(spacing: UIConstants.paddingMedium) {
                                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                    CardDetailRow(title: item.title, value: item.value)
                                    if index != items.count - 1 {
                                        Divider()
                                            .background(AppColors.textSecondary.opacity(0.15))
                                    }
                                }
                            }
                        }

                        if let flavor = card.flavorText, !flavor.isEmpty {
                            sectionContainer(title: "Descrizione") {
                                Text(flavor)
                                    .font(.body)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }

                        movesSection
                    }
                    .padding(.horizontal, UIConstants.paddingLarge)
                    .padding(.bottom, UIConstants.paddingLarge)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingFullScreenImage) {
            FullScreenCardImageView(card: card, isPresented: $isShowingFullScreenImage)
        }
    }

    private var header: some View {
        HStack {
            Menu {
                Button {
                    ownedCardsStore.toggleOwnership(for: card.id)
                } label: {
                    Label(ownedCardsStore.isOwned(cardId: card.id) ? "Rimuovi carta" : "Aggiungi carta", systemImage: ownedCardsStore.isOwned(cardId: card.id) ? "minus.circle" : "plus.circle")
                }

                Button("Aggiungi copia") {
                    ownedCardsStore.increment(cardId: card.id, step: 1)
                }

                if ownedCardsStore.isOwned(cardId: card.id) {
                    Button("Rimuovi copia", role: .destructive) {
                        ownedCardsStore.increment(cardId: card.id, step: -1)
                    }
                }

                Divider()

                Button {
                    ownedCardsStore.toggleWishlist(for: card.id)
                } label: {
                    Label(ownedCardsStore.isWishlist(cardId: card.id) ? "Rimuovi da wishlist" : "Aggiungi a wishlist", systemImage: ownedCardsStore.isWishlist(cardId: card.id) ? "bookmark.slash" : "bookmark")
                }
            } label: {
                Label {
                    Text(ownedCardsStore.isOwned(cardId: card.id) ? "In collezione x\(ownedCardsStore.quantity(for: card.id))" : "Aggiungi alla collezione")
                        .font(.callout)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: ownedCardsStore.isOwned(cardId: card.id) ? "checkmark.seal.fill" : "plus.circle.fill")
                        .foregroundColor(ownedCardsStore.isOwned(cardId: card.id) ? AppColors.textBlue : AppColors.textSecondary)
                }
                .padding(.horizontal, UIConstants.paddingMedium)
                .padding(.vertical, UIConstants.paddingSmall)
                .background(AppColors.badgeBackground)
                .clipShape(Capsule())
                .contentShape(Rectangle())
            }

            Spacer()

            Button {
                isShowingModal = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.modalCloseButton)
            }
        }
        .padding(.horizontal, UIConstants.paddingLarge)
        .padding(.top, UIConstants.paddingLarge)
        .padding(.bottom, UIConstants.paddingMedium)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingSmall) {
            Text(card.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            if !subtitleText.isEmpty {
                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cardImageSection: some View {
        VStack(alignment: .center, spacing: UIConstants.paddingSmall) {
            GeometryReader { geo in
                let availableWidth = geo.size.width
                let targetWidth = min(max(availableWidth - 60, 0), 360)

                Button {
                    isShowingFullScreenImage = true
                } label: {
                    CardFoilImageView(card: card, width: targetWidth)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .bottomTrailing) {
                            Label("Apri a schermo intero", systemImage: "arrow.up.left.and.arrow.down.right")
                                .font(.caption2)
                                .padding(6)
                                .background(AppColors.badgeBackground)
                                .foregroundColor(AppColors.badgeText)
                                .clipShape(Capsule())
                                .padding(8)
                        }
                }
                .buttonStyle(.plain)
                .frame(width: availableWidth)
            }
            .frame(height: 360 * UIConstants.cardImageAspectRatio)

            Text("Tocca la carta per ingrandirla.")
                .font(.footnote)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
        }
    }

    private var subtitleText: String {
        var parts: [String] = []
        if let stage = card.stageDisplay {
            parts.append(stage)
        }
        let number = card.collectorNumberFull ?? "#\(card.collectorNumberNumeric)"
        parts.append(number)
        if let rarity = card.rarityDisplay {
            parts.append(rarity)
        }
        return parts.joined(separator: " • ")
    }

    private var detailItems: [(title: String, value: String)] {
        var items: [(title: String, value: String)] = []
        items.append(("Numero carta", card.collectorNumberFull ?? "#\(card.collectorNumberNumeric)"))
        items.append(("Tipo carta", card.cardTypeDisplay))
        if let stage = card.stageDisplay {
            items.append(("Stadio", stage))
        }
        if let hp = card.hpDisplay {
            items.append(("Punti Salute", hp))
        }
        if let types = card.typeDisplay {
            items.append(("Tipi", types))
        }
        if let rarity = card.rarityDisplay {
            items.append(("Rarità", rarity))
        }
        items.append(("Foil", card.foilDescription ?? FeatureExpansionStrings.noFoil))
        items.append(("Lingua", card.languageDisplay))
        items.append(("Formato", card.sizeDisplay))
        if let regulation = card.regulationMark {
            items.append(("Regolamento", regulation))
        }
        if let weakness = card.weaknessDisplay {
            items.append(("Debolezza", weakness))
        }
        if let resistance = card.resistanceDisplay {
            items.append(("Resistenza", resistance))
        }
        if let retreat = card.retreatDisplay {
            items.append(("Costo ritirata", retreat))
        }
        if ownedCardsStore.isOwned(cardId: card.id) {
            let quantity = ownedCardsStore.quantity(for: card.id)
            items.append(("Collezione", "x\(quantity) copie"))
        } else if ownedCardsStore.isWishlist(cardId: card.id) {
            items.append(("Collezione", "In wishlist"))
        } else {
            items.append(("Collezione", "Non posseduta"))
        }
        items.append(("ID carta", card.id))
        return items
    }

    private var movesSection: some View {
        sectionContainer(title: "Mosse competitive") {
            let moves = card.moves
            if moves.isEmpty {
                Text("Questa carta non include mosse o abilità nel dataset.")
                    .font(.footnote)
                    .foregroundColor(AppColors.textSecondary)
            } else {
                VStack(spacing: UIConstants.paddingMedium) {
                    ForEach(Array(moves.enumerated()), id: \.element.id) { pair in
                        CardMoveRow(move: pair.element)
                        if pair.offset != moves.count - 1 {
                            Divider()
                                .background(AppColors.textSecondary.opacity(0.15))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: UIConstants.paddingSmall) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(UIConstants.cornerRadiusLarge)
    }
}
private struct FullScreenCardImageView: View {
    let card: CardViewModel
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            GeometryReader { geometry in
                let width = min(geometry.size.width - 40, geometry.size.height / UIConstants.cardImageAspectRatio)
                CardFoilImageView(card: card, width: max(width, 180))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(AppColors.modalCloseButton)
                    .padding()
            }
        }
    }
}


// MARK: - Preview for FullCardModalView
struct FullCardModalView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isShowingModal = true
        let sampleCard = CardViewModel(
            cardData: CardData(
                name: FeatureExpansionSamples.cardName1,
                cardType: .pokemon,
                lang: "en",
                foil: Foil(type: .rainbow, mask: .holo),
                size: .standard,
                back: .pokemon1999,
                regulationMark: nil,
                setIcon: "",
                collectorNumber: CollectorNumber(full: "1/100", numerator: "1", denominator: "100", numeric: 1),
                rarity: nil,
                stage: .basic,
                hp: 60,
                types: [.lightning],
                weakness: nil,
                resistance: nil,
                retreat: 1,
                text: nil,
                abilities: nil,
                rules: nil,
                flavorText: nil,
                ext: Extension(tcgl: TcglExtension(cardID: "pi1", longFormID: "longpi1", archetypeID: "archpi1", reldate: "2020-01-01", key: "keypi1")),
                images: Images(tcgl: TcglImages(tex: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), png: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), jpg: nil))
        ))

        FullCardModalView(card: sampleCard, isShowingModal: $isShowingModal)
            .environmentObject(OwnedCardsStore())
            .previewDisplayName("Full Card Modal View")
    }
}
