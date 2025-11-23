import SwiftUI
import CoreKit

/// Rappresenta lo stato di errore con messaggio e azione di retry.
struct ErrorStateView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: UIConstants.paddingMedium) {
            Text(FeatureExpansionStrings.errorLoadingCardsPrefix + error.localizedDescription)
                .foregroundColor(AppColors.error)
                .multilineTextAlignment(.center)
            Button(FeatureExpansionStrings.retry, action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}
