//
//  UIConstants.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//

import SwiftUI

enum UIConstants {
    // Padding e Spacing
    static let paddingSmall: CGFloat = 4
    static let paddingMedium: CGFloat = 10
    static let paddingLarge: CGFloat = 15
    static let spacingMedium: CGFloat = 15
    static let spacingSmall: CGFloat = 3
    static let gridSpacing: CGFloat = 10

    // Dimensioni degli elementi
    static let symbolImageSize: CGFloat = 60
    static let logoImageWidth: CGFloat = 100
    static let logoImageHeight: CGFloat = 30
    static let navigationSymbolSize: CGFloat = 25
    static let progressBarWidth: CGFloat = 120
    static let cardGridMinimumItemSize: CGFloat = 100 // Dimensione minima per le card in griglia
    static let cardImageAspectRatio: CGFloat = 1.4 // Proporzione tipica delle carte (altezza / larghezza)
    static let modalCardSizeMultiplier: CGFloat = 0.8 // Moltiplicatore per la dimensione della carta nella modale
    static let modalCloseButtonSize: CGFloat = 30
    static let rotationSensitivity: CGFloat = 0.5 // Sensibilità per la rotazione della carta

    // Raggi degli angoli
    static let cornerRadiusMedium: CGFloat = 10
    static let cornerRadiusSmall: CGFloat = 5
    static let cornerRadiusLarge: CGFloat = 20 // Per la modale

    // Ombre
    static let shadowRadius: CGFloat = 3
    static let shadowOffsetX: CGFloat = 0
    static let shadowOffsetY: CGFloat = 2
    static let modalShadowRadius: CGFloat = 10

    // Opacità
    static let backgroundOpacityLow: Double = 0.05
    static let backgroundOpacityMedium: Double = 0.1
    static let backgroundOpacityHigh: Double = 0.2
    static let modalBackgroundOpacity: Double = 0.7
    static let foilOverlayOpacity: Double = 0.6 // Opacità per l'effetto foil

    // Limiti di linea
    static let lineLimitSingle: Int = 1
}
