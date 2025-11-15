//
//  PrefersTabNavigationEnvironmentKey.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

/*
Abstract:
The environment key that defines the preferred navigation style.
*/

import SwiftUI

public struct PrefersTabNavigationEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var prefersTabNavigation: Bool {
        get { self[PrefersTabNavigationEnvironmentKey.self] }
        set { self[PrefersTabNavigationEnvironmentKey.self] = newValue }
    }
}

#if os(iOS)
extension PrefersTabNavigationEnvironmentKey: UITraitBridgedEnvironmentKey {
    public static func read(from traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone || traitCollection.userInterfaceIdiom == .tv
    }
    
    public static func write(to mutableTraits: inout UIMutableTraits, value: Bool) {
        // Do not write.
    }
}
#endif
