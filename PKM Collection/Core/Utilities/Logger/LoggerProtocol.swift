//
//  LoggerProtocol.swift
//  PKM Collection
//
//  Created by Mauro on 11/06/25.
//

// =================================================================
//  1. LoggerProtocol.swift - L'INTERFACCIA ASTRATTA
// =================================================================
// Definisce cosa DEVE fare un logger, senza specificare COME.
// Questo permette di usare diversi tipi di logger in modo intercambiabile.

import Foundation

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case fault
}

protocol LoggerProtocol {
    /// Logga un messaggio generico con un livello specificato.
    func log(_ level: LogLevel, _ message: @autoclosure () -> String, file: String, function: String, line: UInt)
    
    /// Logga un errore specifico.
    func log(error: Error, file: String, function: String, line: UInt)
}

// Estensione per fornire metodi di convenienza (es. `logger.debug("messaggio")`)
extension LoggerProtocol {
    func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.debug, message(), file: file, function: function, line: line)
    }
    
    func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.info, message(), file: file, function: function, line: line)
    }
    
    func warning(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.warning, message(), file: file, function: function, line: line)
    }
    
    func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.error, message(), file: file, function: function, line: line)
    }
    
    func fault(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.fault, message(), file: file, function: function, line: line)
    }
}
