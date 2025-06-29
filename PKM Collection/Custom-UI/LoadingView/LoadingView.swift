import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Caricamento...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
