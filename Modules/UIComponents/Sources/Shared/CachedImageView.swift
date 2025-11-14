//
//  CachedImageView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import Kingfisher
import CoreKit

public struct CachedImageView: View {
    private let url: URL?
    private let size: CGSize
    private let cornerRadius: CGFloat
    private let shadowRadius: CGFloat?
    private let placeholderColor: Color
    private let errorColor: Color

    public init(
        url: URL?,
        size: CGSize,
        cornerRadius: CGFloat,
        shadowRadius: CGFloat? = nil,
        placeholderColor: Color,
        errorColor: Color
    ) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.placeholderColor = placeholderColor
        self.errorColor = errorColor
    }

    public var body: some View {
        KFImage(url)
            .resizable()
            .placeholder {
                ProgressView()
                    .frame(width: size.width, height: size.height)
                    .background(placeholderColor)
                    .cornerRadius(cornerRadius)
            }
            .onFailure { error in
                print("Error loading image from \(url?.absoluteString ?? "nil url"): \(error.localizedDescription)")
            }
            .setProcessor(DownsamplingImageProcessor(size: size))
            .loadDiskFileSynchronously()
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius ?? 0)

            .overlay(
                Group {
                    if url == nil {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.width / 2, height: size.height / 2)
                            .foregroundColor(errorColor)
                    }
                }
            )
    }
}

// MARK: - Preview for CachedImageView
#Preview {
    VStack(spacing: UIConstants.spacingMedium) {
        CachedImageView(
            url: URL(string: "https://images.pokemontcg.io/swsh1/symbol.png"),
            size: CGSize(width: 80, height: 80),
            cornerRadius: UIConstants.cornerRadiusMedium,
            shadowRadius: UIConstants.shadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )

        CachedImageView(
            url: URL(string: "https://images.pokemontcg.io/swsh1/logo.png"),
            size: CGSize(width: 150, height: 50),
            cornerRadius: UIConstants.cornerRadiusSmall,
            shadowRadius: nil,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )

        CachedImageView(
            url: URL(string: "invalid-url"),
            size: CGSize(width: 80, height: 80),
            cornerRadius: UIConstants.cornerRadiusMedium,
            shadowRadius: UIConstants.shadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )

        CachedImageView(
            url: nil,
            size: CGSize(width: 80, height: 80),
            cornerRadius: UIConstants.cornerRadiusMedium,
            shadowRadius: UIConstants.shadowRadius,
            placeholderColor: AppColors.placeholder,
            errorColor: AppColors.error
        )
    }
    .padding()
}
