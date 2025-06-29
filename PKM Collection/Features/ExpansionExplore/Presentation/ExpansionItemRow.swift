import SwiftUI

struct ExpansionListRow: View {
    let expansion: Expansion
    
    var body: some View {
        NavigationLink(value: expansion) {
            ExpansionItemView(expansion: expansion)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
}
