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

    // Stati per la rotazione 3D
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var initialRotationX: Double = 0
    @State private var initialRotationY: Double = 0

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
                            .aspectRatio(contentMode: .fit)
                            .frame(width: cardWidth, height: cardHeight)
                            .cornerRadius(UIConstants.cornerRadiusLarge)
                            .shadow(color: AppColors.shadow, radius: UIConstants.modalShadowRadius, x: UIConstants.shadowOffsetX, y: UIConstants.shadowOffsetY)

                        // Effetto Foil (se disponibile)
                        if let foilUrl = card.foilImageUrl {
                            KFImage(foilUrl)
                                .resizable()
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: cardWidth, height: cardHeight)))
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(UIConstants.cornerRadiusLarge)
                                .blendMode(.screen) // O .overlay, .colorDodge a seconda dell'effetto desiderato
                                .opacity(UIConstants.foilOverlayOpacity) // Regola l'opacità del foil
                        }

                        // Effetto Etch (se disponibile) - Potrebbe richiedere un blendMode diverso
                        if let etchUrl = card.etchImageUrl {
                            KFImage(etchUrl)
                                .resizable()
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: cardWidth, height: cardHeight)))
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(UIConstants.cornerRadiusLarge)
                                .blendMode(.overlay) // Esempio: blendMode diverso per l'etching
                                .opacity(UIConstants.foilOverlayOpacity * 0.7) // Opacità leggermente inferiore per l'etch
                        }
                    }
                    // Applica la rotazione 3D all'intero ZStack
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
                                // Calcola la rotazione in base al trascinamento
                                rotationY = initialRotationY + (value.translation.width * UIConstants.rotationSensitivity)
                                rotationX = initialRotationX - (value.translation.height * UIConstants.rotationSensitivity)
                            }
                            .onEnded { value in
                                // Salva la rotazione finale come iniziale per il prossimo trascinamento
                                initialRotationY = rotationY
                                initialRotationX = rotationX
                            }
                    )
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
            .previewDisplayName("Full Card Modal View")
    }
}
