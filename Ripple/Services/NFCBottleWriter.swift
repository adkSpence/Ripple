//
//  NFCBottleWriter.swift
//  Ripple
//

@preconcurrency import CoreNFC
import Foundation

enum NFCBottleWriterError: LocalizedError, Equatable {
    case unavailable
    case readOnly
    case insufficientCapacity
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "NFC tag writing is unavailable on this device."
        case .readOnly:
            "This NFC tag is read-only. Use a blank or rewritable tag."
        case .insufficientCapacity:
            "This NFC tag does not have enough space."
        case .invalidPayload:
            "Ripple could not prepare the bottle tag."
        }
    }
}

@MainActor
protocol NFCBottleWriting: AnyObject {
    func beginWrite(
        url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

@MainActor
final class NFCBottleWriter: NSObject, NFCBottleWriting {
    private var session: NFCNDEFReaderSession?
    private var message: NFCNDEFMessage?
    private var completion: ((Result<Void, Error>) -> Void)?

    func beginWrite(
        url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NFCBottleWriterError.unavailable))
            return
        }

        guard let payload = NFCNDEFPayload.wellKnownTypeURIPayload(
            string: url.absoluteString
        ) else {
            completion(.failure(NFCBottleWriterError.invalidPayload))
            return
        }

        self.message = NFCNDEFMessage(records: [payload])
        self.completion = completion

        let session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        session.alertMessage = "Hold your iPhone near the NFC tag for this bottle."
        self.session = session
        session.begin()
    }

    private func finish(
        _ result: Result<Void, Error>,
        alertMessage: String? = nil
    ) {
        guard let completion else { return }
        self.completion = nil

        if let alertMessage {
            session?.alertMessage = alertMessage
        }
        session?.invalidate()
        session = nil
        message = nil
        completion(result)
    }
}

extension NFCBottleWriter: NFCNDEFReaderSessionDelegate {
    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetectNDEFs messages: [NFCNDEFMessage]
    ) {}

    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetect tags: [NFCNDEFTag]
    ) {
        guard tags.count == 1, let tag = tags.first else {
            session.alertMessage = "More than one tag detected. Hold only one tag near your iPhone."
            session.restartPolling()
            return
        }

        let tagBox = NFCNDEFTagBox(tag)

        session.connect(to: tag) { [writer = self, tagBox] connectionError in
            if let connectionError {
                Task { @MainActor [writer] in
                    writer.finish(.failure(connectionError))
                }
                return
            }

            tagBox.tag.queryNDEFStatus { [writer, tagBox] status, capacity, statusError in
                if let statusError {
                    Task { @MainActor [writer] in
                        writer.finish(.failure(statusError))
                    }
                    return
                }

                Task { @MainActor [writer, tagBox] in
                    guard let message = writer.message else { return }

                    guard status == .readWrite else {
                        writer.finish(.failure(NFCBottleWriterError.readOnly))
                        return
                    }

                    guard message.length <= capacity else {
                        writer.finish(.failure(NFCBottleWriterError.insufficientCapacity))
                        return
                    }

                    tagBox.tag.writeNDEF(message) { [writer] writeError in
                        Task { @MainActor [writer] in
                            if let writeError {
                                writer.finish(.failure(writeError))
                            } else {
                                writer.finish(
                                    .success(()),
                                    alertMessage: "Bottle tag connected."
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didInvalidateWithError error: Error
    ) {
        Task { @MainActor in
            guard completion != nil else { return }
            finish(.failure(error))
        }
    }
}

private final class NFCNDEFTagBox: @unchecked Sendable {
    nonisolated(unsafe) let tag: NFCNDEFTag

    nonisolated init(_ tag: NFCNDEFTag) {
        self.tag = tag
    }
}
