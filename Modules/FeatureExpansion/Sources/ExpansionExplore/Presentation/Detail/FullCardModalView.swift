//
//  FullCardModalView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import Kingfisher

struct FullCardModalView: View {
    let card: CardViewModel
    @Binding var isShowingModal: Bool // Binding per controllare la visibilità della modale
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore

    // Stati per la rotazione 3D
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var initialRotationX: Double = 0
    @State private var initialRotationY: Double = 0
    
    private let maxTilt: Double = 30
    private func clamp(_ value: Double, min minV: Double, max maxV: Double) -> Double {
        min(max(value, minV), maxV)
    }

    var body: some View {
        ZStack {
            // Sfondo scuro semitrasparente
            AppColors.modalBackground
                .ignoresSafeArea()
                .onTapGesture {
                    // Chiudi la modale se si tocca lo sfondo
                    isShowingModal = false
                }

            VStack {
                // Bottone di chiusura
                HStack {
                    Menu {
                        Button {
                            ownedCardsStore.toggleOwnership(for: card.id)
                        } label: {
                            Label(ownedCardsStore.isOwned(cardId: card.id) ? "Remove card" : "Add card", systemImage: ownedCardsStore.isOwned(cardId: card.id) ? "minus.circle" : "plus.circle")
                        }

                        Button("Add copy") {
                            ownedCardsStore.increment(cardId: card.id, step: 1)
                        }

                        if ownedCardsStore.isOwned(cardId: card.id) {
                            Button("Remove copy", role: .destructive) {
                                ownedCardsStore.increment(cardId: card.id, step: -1)
                            }
                        }
                    } label: {
                        Label {
                            Text(ownedCardsStore.isOwned(cardId: card.id) ? "Owned x\(ownedCardsStore.quantity(for: card.id))" : "Add to collection")
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
                        .padding(UIConstants.paddingMedium)
                    }

                    Spacer()

                    Button {
                        isShowingModal = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(AppColors.modalCloseButton)
                            .padding(UIConstants.paddingMedium)
                    }
                }
                Spacer()

                // Immagine della carta ingrandita e effetti foil/etch
                GeometryReader { geometry in
                    let cardWidth = min(geometry.size.width, geometry.size.height / UIConstants.cardImageAspectRatio) * UIConstants.modalCardSizeMultiplier
                    let cardHeight = cardWidth * UIConstants.cardImageAspectRatio

                    ZStack { // ZStack per sovrapporre l'immagine base e gli effetti foil/etch
                        // Immagine base della carta
                        KFImage(card.imageUrl)
                            .resizable()
                            .placeholder {
                                ProgressView()
                                    .frame(width: cardWidth, height: cardHeight)
                                    .background(AppColors.placeholder)
                                    .cornerRadius(UIConstants.cornerRadiusLarge)
                            }
                            .onFailure { error in
                                print("Error loading full card image: \(error.localizedDescription)")
                            }
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: cardWidth, height: cardHeight)))
                            .loadDiskFileSynchronously()
                            .fade(duration: 0.25)
                            .scaledToFit()
                            .frame(width: cardWidth, height: cardHeight)
                            .cornerRadius(UIConstants.cornerRadiusLarge)
                            .shadow(color: AppColors.shadow, radius: UIConstants.modalShadowRadius, x: UIConstants.shadowOffsetX, y: UIConstants.shadowOffsetY)
                            .allowsHitTesting(false)

                        // Effetto Foil (se disponibile)
                        if let foilUrl = card.foilImageUrl {
                            KFImage(foilUrl)
                                .resizable()
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: cardWidth, height: cardHeight)))
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .scaledToFit()
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(UIConstants.cornerRadiusLarge)
                                .blendMode(.screen)
                                .opacity(UIConstants.foilOverlayOpacity)
                                .allowsHitTesting(false)
                        }

                        // Effetto Etch (se disponibile)
                        if let etchUrl = card.etchImageUrl {
                            KFImage(etchUrl)
                                .resizable()
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: cardWidth, height: cardHeight)))
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .scaledToFit()
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(UIConstants.cornerRadiusLarge)
                                .blendMode(.overlay)
                                .opacity(UIConstants.foilOverlayOpacity * 0.7)
                                .allowsHitTesting(false)
                        }

                        // Shine dinamico in base alla rotazione
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .cornerRadius(UIConstants.cornerRadiusLarge)
                        .blendMode(.screen)
                        .opacity(
                            0.15 + 0.35 * min(abs(rotationX) + abs(rotationY), 60) / 60
                        )
                        .allowsHitTesting(false)
                    }
                    // Applica la rotazione 3D all'intero ZStack
                    .contentShape(Rectangle())
                    .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.85), value: rotationX)
                    .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.85), value: rotationY)
                    .rotation3DEffect(
                        .degrees(rotationX),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 1
                    )
                    .rotation3DEffect(
                        .degrees(rotationY),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 1
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newY = initialRotationY + (value.translation.width * UIConstants.rotationSensitivity)
                                let newX = initialRotationX - (value.translation.height * UIConstants.rotationSensitivity)
                                rotationY = clamp(newY, min: -maxTilt, max: maxTilt)
                                rotationX = clamp(newX, min: -maxTilt, max: maxTilt)
                            }
                            .onEnded { value in
                                // Salva la rotazione finale come iniziale per il prossimo trascinamento
                                initialRotationY = rotationY
                                initialRotationX = rotationX
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            rotationX = 0
                            rotationY = 0
                            initialRotationX = 0
                            initialRotationY = 0
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Occupa lo spazio disponibile
                Spacer()
            }
        }
    }
}

// MARK: - Preview for FullCardModalView
struct FullCardModalView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isShowingModal = true
        let sampleCard = CardViewModel(cardData: CardData(name: AppStrings.sampleCardName1, cardType: .pokemon, lang: "en", foil: Foil(type: .rainbow, mask: .holo), size: .standard, back: .pokemon1999, regulationMark: nil, setIcon: "", collectorNumber: CollectorNumber(full: "1/100", numerator: "1", denominator: "100", numeric: 1), rarity: nil, stage: .basic, hp: 60, types: [.lightning], weakness: nil, resistance: nil, retreat: 1, text: nil, abilities: nil, rules: nil, flavorText: nil, ext: Extension(tcgl: TcglExtension(cardID: "pi1", longFormID: "longpi1", archetypeID: "archpi1", reldate: "2020-01-01", key: "keypi1")), images: Images(tcgl: TcglImages(tex: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), png: ImagePaths(front: "https://images.pokemontcg.io/swsh1/1.png", back: nil, foil: nil, etch: nil), jpg: nil))))

        FullCardModalView(card: sampleCard, isShowingModal: $isShowingModal)
            .environmentObject(OwnedCardsStore())
            .previewDisplayName("Full Card Modal View")
    }
}

