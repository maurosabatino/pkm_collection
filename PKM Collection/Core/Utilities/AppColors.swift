//
//  ColorConstants.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI

struct AppColors {
    // Sfondi
    static let backgroundPrimary = Color.blue.opacity(UIConstants.backgroundOpacityMedium) // Sfondo della lista in modalità chiara
    static let cardBackground = Color.white // Sfondo delle card in modalità chiara
    // Per un supporto completo a Dark Mode, potresti definire:
    // static let backgroundPrimary = Color(light: Color.blue.opacity(UIConstants.backgroundOpacityMedium), dark: Color.black.opacity(0.8))
    // static let cardBackground = Color(light: .white, dark: Color(.systemGray6))

    // Testo
    static let textPrimary = Color.primary // Si adatta automaticamente a Light/Dark Mode
    static let textSecondary = Color.secondary // Si adatta automaticamente a Light/Dark Mode
    static let textGray = Color.gray
    static let textBlue = Color.blue

    // Elementi UI
    static let shadow = Color.black.opacity(UIConstants.backgroundOpacityHigh)
    static let progressTint = Color.green
    static let placeholder = Color.gray.opacity(UIConstants.backgroundOpacityHigh)
    static let error = Color.red
    static let warning = Color.orange
    static let accent = Color.accentColor // Colore accentuato del sistema
}
