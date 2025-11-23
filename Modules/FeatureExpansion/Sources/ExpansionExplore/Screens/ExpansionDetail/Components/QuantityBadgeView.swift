import SwiftUI
import CoreKit

/// Badge compatto per indicare il numero di copie possedute.
struct QuantityBadgeView: View {
    let quantity: Int

    var body: some View {
        Text("x\(quantity)")
            .font(.caption2.bold())
            .padding(6)
            .background(AppColors.badgeBackground)
            .foregroundColor(AppColors.badgeText)
            .clipShape(Capsule())
            .padding(6)
    }
}
