//
//  NFCBottleScanner.swift
//  Ripple
//

import CoreNFC
import Foundation
import Observation

enum NFCBottleScannerError: LocalizedError {
    case unavailable
    case unreadableTag

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "NFC scanning is unavailable on this device."
        case .unreadableTag:
            "The tag does not contain a readable Ripple bottle link."
        }
    }
}

@MainActor
@Observable
final class NFCBottleScanner: NSObject {
    private(set) var isScanning = false

    @ObservationIgnored private var session: NFCNDEFReaderSession?
    @ObservationIgnored private var completion: ((Result<URL, Error>) -> Void)?

    func beginScan(completion: @escaping (Result<URL, Error>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NFCBottleScannerError.unavailable))
            return
        }

        self.completion = completion
        let session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session.alertMessage = "Hold your iPhone near the NFC tag on your bottle."
        self.session = session
        isScanning = true
        session.begin()
    }

    private func finish(_ result: Result<URL, Error>) {
        guard let completion else { return }
        self.completion = nil
        session = nil
        isScanning = false
        completion(result)
    }
}

extension NFCBottleScanner: NFCNDEFReaderSessionDelegate {
    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetectNDEFs messages: [NFCNDEFMessage]
    ) {
        let url = messages
            .flatMap(\.records)
            .compactMap { $0.wellKnownTypeURIPayload() }
            .first

        Task { @MainActor in
            if let url {
                finish(.success(url))
            } else {
                finish(.failure(NFCBottleScannerError.unreadableTag))
            }
        }
    }

    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didInvalidateWithError error: Error
    ) {
        Task { @MainActor in
            if let readerError = error as? NFCReaderError,
               readerError.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
                return
            }
            finish(.failure(error))
        }
    }
}
