import SwiftUI
import CoreKit

/// Barra di ricerca a scomparsa per ridurre ingombro visivo in lista e griglia.
struct CollapsibleSearchBar: View {
    @Binding var text: String
    let prompt: String

    @State private var isExpanded = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingSmall) {
            Button {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                    isSearchFocused = isExpanded
                }
            } label: {
                HStack {
                    Label(prompt, systemImage: "magnifyingglass")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.caption.bold())
                }
                .padding()
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium)
                        .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                TextField(prompt, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($isSearchFocused)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
