import SwiftUI
import CoreKit
import UIComponents

/// Rendering della carta con livelli foil/etch e shader animati.
struct CardFoilImageView: View {
    let card: CardViewModel
    let width: CGFloat

    var body: some View {
        let height = width * UIConstants.cardImageAspectRatio
        let cornerRadius = UIConstants.cornerRadiusLarge

        return baseLayers(width: width, height: height, cornerRadius: cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .blendMode(.screen)
            )
            .overlay(
                FoilWavePatternOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .blendMode(.colorDodge)
                    .allowsHitTesting(false)
            )
            .overlay(
                FoilSpecularSweepOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .blendMode(.screen)
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
                        Color.white.opacity(0.09),
                        Color.white.opacity(0.025),
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
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
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
        CachedImageView(
            url: card.imageUrl,
            size: CGSize(width: width, height: height),
            cornerRadius: cornerRadius,
            shadowRadius: UIConstants.modalShadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )
        .scaledToFit()
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func foilOverlay(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let foilUrl = card.foilImageUrl {
            CachedImageView(
                url: foilUrl,
                size: CGSize(width: width, height: height),
                cornerRadius: cornerRadius,
                shadowRadius: nil,
                placeholderColor: .clear,
                errorColor: .clear
            )
            .scaledToFit()
            .frame(width: width, height: height)
            .blendMode(.plusLighter)
            .opacity(0.34)
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func etchOverlay(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let etchUrl = card.etchImageUrl {
            CachedImageView(
                url: etchUrl,
                size: CGSize(width: width, height: height),
                cornerRadius: cornerRadius,
                shadowRadius: nil,
                placeholderColor: .clear,
                errorColor: .clear
            )
            .scaledToFit()
            .frame(width: width, height: height)
            .blendMode(.hardLight)
            .opacity(0.22)
            .allowsHitTesting(false)
        }
    }
}

/// Overlay animato che simula le onde del foil.
private struct FoilWavePatternOverlay: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            FoilWaveField(
                phase: phase,
                waveCount: 12,
                colors: [
                    Color(red: 0.92, green: 0.82, blue: 0.98),
                    Color(red: 0.65, green: 0.85, blue: 1.0)
                ],
                lineWidth: 0.8
            )
            .blendMode(.screen)
            .opacity(0.8)

            FoilWaveField(
                phase: phase * 0.85,
                waveCount: 8,
                colors: [
                    Color(red: 1.0, green: 0.92, blue: 0.72),
                    Color(red: 0.95, green: 0.7, blue: 0.82)
                ],
                lineWidth: 0.9
            )
            .rotationEffect(.degrees(32))
            .blendMode(.plusLighter)
            .opacity(0.6)
        }
        .opacity(0.32)
        .blur(radius: 9)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                phase = .pi * 4
            }
        }
    }
}

/// Collezione di onde colorate usata come pattern foil.
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
                    let amplitude = spacing * (0.12 + CGFloat(index % 3) * 0.05)
                    let frequency = 0.8 + CGFloat(index % 4) * 0.12
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
                    .opacity(0.18 + Double(index % 4) * 0.05)
                    .frame(height: amplitude * 2 + spacing * 0.3)
                    .offset(y: -height / 2 + spacing * CGFloat(index))
                }
            }
        }
    }
}

/// Traccia una singola onda sinusoidale per il pattern foil.
private struct FoilWaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let midY = rect.midY
        let step: CGFloat = max(3, width / 60)

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

private struct FoilSpecularSweepOverlay: View {
    @State private var travel: CGFloat = -1.1

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let diagonal = hypot(width, height)
            let bandThickness = max(width, height) * 0.28

            ZStack {
                specularBand(
                    length: diagonal * 1.1,
                    thickness: bandThickness,
                    tilt: 16,
                    colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.45),
                        Color.white.opacity(0.05)
                    ],
                    baseOpacity: 0.38
                )
                .offset(x: travel * width * 0.95, y: -height * 0.18)

                specularBand(
                    length: diagonal * 0.9,
                    thickness: bandThickness * 0.75,
                    tilt: -22,
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.82).opacity(0.0),
                        Color(red: 1.0, green: 0.95, blue: 0.82).opacity(0.55),
                        Color(red: 0.9, green: 0.8, blue: 1.0).opacity(0.1)
                    ],
                    baseOpacity: 0.28
                )
                .offset(x: (travel + 0.45) * width * 0.7, y: height * 0.22)
            }
            .onAppear {
                withAnimation(.linear(duration: 5.5).repeatForever(autoreverses: false)) {
                    travel = 1.25
                }
            }
        }
    }

    @ViewBuilder
    private func specularBand(length: CGFloat, thickness: CGFloat, tilt: Double, colors: [Color], baseOpacity: Double) -> some View {
        RoundedRectangle(cornerRadius: thickness / 2, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            .frame(width: thickness, height: length)
            .rotationEffect(.degrees(tilt))
            .blur(radius: 18)
            .opacity(baseOpacity)
    }
}

private struct FoilIridescenceOverlay: View {
    @State private var shift: CGFloat = -0.7

    var body: some View {
        GeometryReader { geometry in
            let diameter = max(geometry.size.width, geometry.size.height) * 1.4

            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.98, green: 0.9, blue: 0.75),
                            Color(red: 0.7, green: 0.85, blue: 1.0),
                            Color(red: 0.95, green: 0.75, blue: 0.9),
                            Color(red: 0.98, green: 0.9, blue: 0.75)
                        ]),
                        center: .center
                    )
                )
                .frame(width: diameter, height: diameter)
                .offset(x: shift * diameter * 0.18, y: shift * diameter * 0.08)
                .blur(radius: 38)
                .opacity(0.16)
                .onAppear {
                    withAnimation(.linear(duration: 9).repeatForever(autoreverses: true)) {
                        shift = 0.6
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
                Color.white.opacity(0.18),
                Color(red: 1.0, green: 0.94, blue: 0.78).opacity(0.22),
                Color.white.opacity(0.08)
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
                        .opacity(flicker ? 0.25 : 0.1)
                )
                .opacity(0.24)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                        flicker.toggle()
                    }
                }
        }
    }
}

private struct NoiseTexture: View {
    private let dots: [CGPoint] = (0..<90).map { _ in
        CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for point in dots {
                    let rect = CGRect(
                        x: point.x * geometry.size.width,
                        y: point.y * geometry.size.height,
                        width: 1.6,
                        height: 1.6
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
