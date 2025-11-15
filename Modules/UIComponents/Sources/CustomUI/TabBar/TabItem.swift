//
//  TabItem.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 22/06/25.
//

import SwiftUI

public struct TabItem: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String

    public init(id: String, title: LocalizedStringKey, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}
