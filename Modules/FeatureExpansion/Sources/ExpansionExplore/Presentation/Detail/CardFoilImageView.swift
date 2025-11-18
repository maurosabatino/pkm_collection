import SwiftUI
import CoreKit
import Kingfisher

struct CardFoilImageView: View {
    let card: CardViewModel
    let width: CGFloat

    var body: some View {
        let height = width * UIConstants.cardImageAspectRatio
        let cornerRadius = UIConstants.cornerRadiusLarge

        return baseLayers(width: width, height: height, cornerRadius: cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .blendMode(.screen)
            )
            .overlay(
            FoilWavePatternOverlay()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .blendMode(.colorDodge)
                .allowsHitTesting(false)
        )
        .overlay(
            FoilIridescenceOverlay()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .blendMode(.softLight)
                .allowsHitTesting(false)
        )
        .overlay(
            FoilNoiseOverlay()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
        )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.04),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .blendMode(.overlay)
                .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .blendMode(.overlay)
                    .allowsHitTesting(false)
            )
            .frame(width: width, height: height)
    }

    @ViewBuilder
    private func baseLayers(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        ZStack {
            baseImage(width: width, height: height, cornerRadius: cornerRadius)

            foilOverlay(width: width, height: height, cornerRadius: cornerRadius)
            etchOverlay(width: width, height: height, cornerRadius: cornerRadius)
        }
        .compositingGroup()
    }

    private func baseImage(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        KFImage(card.imageUrl)
            .resizable()
            .placeholder {
                ProgressView()
                    .frame(width: width, height: height)
                    .background(AppColors.placeholder)
                    .cornerRadius(cornerRadius)
            }
            .onFailure { error in
                print("Error loading card image: \(error.localizedDescription)")
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: width, height: height)))
            .loadDiskFileSynchronously()
            .fade(duration: 0.3)
            .scaledToFit()
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shadow(color: AppColors.shadow, radius: UIConstants.modalShadowRadius, x: UIConstants.shadowOffsetX, y: UIConstants.shadowOffsetY)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private func foilOverlay(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let foilUrl = card.foilImageUrl {
            KFImage(foilUrl)
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: width, height: height)))
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .scaledToFit()
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
                .blendMode(.plusLighter)
                .opacity(0.45)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func etchOverlay(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let etchUrl = card.etchImageUrl {
            KFImage(etchUrl)
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: width, height: height)))
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .scaledToFit()
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
                .blendMode(.hardLight)
                .opacity(0.3)
                .allowsHitTesting(false)
        }
    }
}

private struct FoilWavePatternOverlay: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            FoilWaveField(
                phase: phase,
                waveCount: 18,
                colors: [
                    Color(red: 0.9, green: 0.75, blue: 1.0),
                    Color(red: 0.5, green: 0.85, blue: 1.0)
                ],
                lineWidth: 1.1
            )
            .blendMode(.screen)

            FoilWaveField(
                phase: phase * 0.9,
                waveCount: 14,
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.65),
                    Color(red: 0.95, green: 0.6, blue: 0.75)
                ],
                lineWidth: 1.4
            )
            .rotationEffect(.degrees(32))
            .blendMode(.plusLighter)
        }
        .opacity(0.55)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                phase = .pi * 4
            }
        }
    }
}

private struct FoilWaveField: View {
    let phase: CGFloat
    let waveCount: Int
    let colors: [Color]
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let spacing = height / CGFloat(waveCount)

            ZStack {
                ForEach(0..<waveCount, id: \.self) { index in
                    let amplitude = spacing * (0.25 + CGFloat(index % 3) * 0.08)
                    let frequency = 1.1 + CGFloat(index % 4) * 0.15
                    let offsetPhase = phase + CGFloat(index) * 0.4

                    FoilWaveShape(
                        phase: offsetPhase,
                        amplitude: amplitude,
                        frequency: frequency
                    )
                    .stroke(
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing),
                        lineWidth: lineWidth
                    )
                    .opacity(0.25 + Double(index % 4) * 0.08)
                    .frame(height: amplitude * 2 + spacing * 0.3)
                    .offset(y: -height / 2 + spacing * CGFloat(index))
                }
            }
        }
    }
}

private struct FoilWaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let midY = rect.midY
        let step: CGFloat = max(2, width / 80)

        path.move(to: CGPoint(x: 0, y: midY))
        for x in stride(from: 0, through: width, by: step) {
            let progress = x / width
            let angle = (progress * frequency * .pi * 2) + phase
            let y = midY + sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
}

private struct FoilIridescenceOverlay: View {
    @State private var shift: CGFloat = -0.7

    var body: some View {
        GeometryReader { geometry in
            let diameter = max(geometry.size.width, geometry.size.height) * 1.6

            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.65),
                            Color(red: 0.65, green: 0.8, blue: 1.0),
                            Color(red: 0.95, green: 0.65, blue: 0.9),
                            Color(red: 1.0, green: 0.85, blue: 0.65)
                        ]),
                        center: .center
                    )
                )
                .frame(width: diameter, height: diameter)
                .offset(x: shift * diameter * 0.25, y: shift * diameter * 0.1)
                .blur(radius: 50)
                .opacity(0.28)
                .onAppear {
                    withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                        shift = 0.8
                    }
                }
        }
    }
}

private struct FoilNoiseOverlay: View {
    @State private var flicker = false

    var body: some View {
        GeometryReader { geometry in
            let gradient = Gradient(colors: [
                Color.white.opacity(0.25),
                Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.3),
                Color.white.opacity(0.1)
            ])

            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(
                    NoiseTexture()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(flicker ? 0.35 : 0.15)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                        flicker.toggle()
                    }
                }
        }
    }
}

private struct NoiseTexture: View {
    private let dots: [CGPoint] = (0..<120).map { _ in
        CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for point in dots {
                    let rect = CGRect(
                        x: point.x * geometry.size.width,
                        y: point.y * geometry.size.height,
                        width: 2.0,
                        height: 2.0
                    )
                    path.addRoundedRect(in: rect, cornerSize: CGSize(width: 1, height: 1))
                }
            }
            .fill(Color.white)
            .blur(radius: 0.6)
        }
    }
}

#if DEBUG
struct CardFoilImageView_Previews: PreviewProvider {
    static var previews: some View {
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

        return ZStack {
            Color.black.ignoresSafeArea()
            CardFoilImageView(card: sampleCard, width: 340)
                .padding()
        }
        .previewDisplayName("CardFoilImageView")
    }
}
#endif
