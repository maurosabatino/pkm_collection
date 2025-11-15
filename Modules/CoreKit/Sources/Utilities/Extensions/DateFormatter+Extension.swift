//
//  DateFormatter+Extension.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import Foundation

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
