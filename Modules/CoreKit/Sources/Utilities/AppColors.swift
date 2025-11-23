//
//  ColorConstants.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI

public struct AppColors {}

public extension AppColors {
    // Sfondi
    static let backgroundPrimary = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let modalBackground = Color(.systemBackground).opacity(0.95)

    // Testo
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textGray = Color(.tertiaryLabel)
    static let textBlue = Color(.systemBlue)
    static let modalCloseButton = Color(.secondaryLabel)

    // Elementi UI
    static let shadow = Color(.label).opacity(0.18)
    static let progressTint = Color(.systemGreen)
    static let placeholder = Color(.tertiaryLabel)
    static let error = Color(.systemRed)
    static let warning = Color(.systemOrange)
    static let accent = Color.accentColor
    static let badgeBackground = Color(.systemGray5).opacity(0.7)
    static let badgeText = Color(.label)
}
