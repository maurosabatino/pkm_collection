//
//  AppDetailColumn.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI
import CoreKit

struct AppDetailColumn: View {
    var selection: ModuleEntryDescriptor?
    @Binding var navigationPath: NavigationPath
    let navigator: ModuleNavigator

    var body: some View {
        Group {
            if let selection = selection {
                selection.makeView(navigator: navigator)
            } else {
                ContentUnavailableView(
                    AppStrings.selectExpansionPlaceholder,
                    systemImage: "folder",
                    description: Text(AppStrings.pickSomethingFromList)
                )
            }
        }
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        #endif
    }
}
