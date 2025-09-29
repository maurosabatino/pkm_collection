//
//  ColorConstants.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI

struct AppColors {
    // Sfondi
    static let backgroundPrimary = Color.blue.opacity(UIConstants.backgroundOpacityMedium)
    static let cardBackground = Color.white
    static let modalBackground = Color.black.opacity(UIConstants.modalBackgroundOpacity)

    // Testo
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textGray = Color.gray
    static let textBlue = Color.blue
    static let modalCloseButton = Color.white

    // Elementi UI
    static let shadow = Color.black.opacity(UIConstants.backgroundOpacityHigh)
    static let progressTint = Color.green
    static let placeholder = Color.gray.opacity(UIConstants.backgroundOpacityHigh)
    static let error = Color.red
    static let warning = Color.orange
    static let accent = Color.accentColor
}
