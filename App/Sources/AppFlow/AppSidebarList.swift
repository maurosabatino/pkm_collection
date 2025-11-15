//
//  AppSidebarList.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI
import CoreKit

struct AppSidebarList: View {
    let entries: [ModuleEntryDescriptor]
    @Binding var selection: ModuleEntryDescriptor?

    var body: some View {
        List(entries, selection: $selection) { entry in
            NavigationLink(value: entry) {
                Label(entry.title, systemImage: entry.systemImage)
            }
        }
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList(entries: AppModuleRegistry().entries, selection: .constant(nil))
    } detail: {
        Text(verbatim: "Check out that sidebar!")
    }
}
