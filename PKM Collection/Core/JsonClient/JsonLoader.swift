//
//  Untitled.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//


import Foundation

final class JsonLoader {
    static func loadJSONData(fromFile fileName: String, withExtension fileExtension: String = "json") throws -> Data {
           guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
               throw DomainError.dataNotFound(message: "File '\(fileName).\(fileExtension)' non trovato nel bundle.")
           }
           
           do {
               let data = try Data(contentsOf: url)
               return data
           } catch {
               throw DomainError.unknownError
           }
       }
}
