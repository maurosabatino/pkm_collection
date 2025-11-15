// =================================================================
//  2. AppLogger.swift - L'IMPLEMENTAZIONE CONCRETA
// =================================================================
// Una classe che implementa LoggerProtocol usando il sistema di logging unificato di Apple.

import os
import Foundation

final class AppLogger: LoggerProtocol {
    
    private let logger: Logger
    
    init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    func log(_ level: LogLevel, _ message: @autoclosure () -> String, file: String, function: String, line: UInt) {
        #if DEBUG
        let messageToLog = "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(function) - \(message())"
        switch level {
        case .debug:
            logger.debug("\(messageToLog)")
        case .info:
            logger.info("\(messageToLog)")
        case .warning:
            logger.warning("\(messageToLog)")
        case .error:
            logger.error("\(messageToLog)")
        case .fault:
            logger.fault("\(messageToLog)")
        }
        #endif
    }
    
    func log(error: Error, file: String, function: String, line: UInt) {
        #if DEBUG
        let messageToLog = "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(function) - ERROR: \(error.localizedDescription)"
        logger.error("\(messageToLog)")
        #endif
    }
}

// =================================================================
//  3. Log.swift - IL PROVIDER DI ISTANZE
// =================================================================
// Un modo pulito per accedere a istanze pre-configurate del logger da tutta l'app.

enum Log {
    private static let subsystem = "com.maurosabatino.PKM-Collection" // Sostituisci con il tuo bundle ID

    /// Logger per tutto ciò che riguarda le chiamate di rete.
    static let network: LoggerProtocol = AppLogger(subsystem: subsystem, category: "Network")
    
    /// Logger per i cicli di vita delle viste e interazioni UI.
    static let ui: LoggerProtocol = AppLogger(subsystem: subsystem, category: "UI")
    
    /// Logger per i ViewModel.
    static let viewModel: LoggerProtocol = AppLogger(subsystem: subsystem, category: "ViewModel")
    
    /// Logger per il database o la persistenza.
    static let database: LoggerProtocol = AppLogger(subsystem: subsystem, category: "Database")
}
