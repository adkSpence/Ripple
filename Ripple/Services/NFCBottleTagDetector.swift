@preconcurrency import CoreNFC
import Foundation

@MainActor
protocol NFCBottleTagDetecting: AnyObject {
    func detectWritableTag(completion: @escaping (Result<Void, Error>) -> Void)
}

@MainActor
final class NFCBottleTagDetector: NSObject, NFCBottleTagDetecting {
    private var session: NFCNDEFReaderSession?
    private var completion: ((Result<Void, Error>) -> Void)?

    func detectWritableTag(completion: @escaping (Result<Void, Error>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NFCBottleWriterError.unavailable))
            return
        }

        self.completion = completion
        let session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        session.alertMessage = "Hold your iPhone near the tag you want to use."
        self.session = session
        session.begin()
    }

    private func finish(_ result: Result<Void, Error>, message: String? = nil) {
        guard let completion else { return }
        self.completion = nil
        if let message { session?.alertMessage = message }
        session?.invalidate()
        session = nil
        completion(result)
    }
}

extension NFCBottleTagDetector: NFCNDEFReaderSessionDelegate {
    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetectNDEFs messages: [NFCNDEFMessage]
    ) {}

    nonisolated func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetect tags: [NFCNDEFTag]
    ) {
        guard tags.count == 1, let tag = tags.first else {
            session.alertMessage = "Hold only one NFC tag near your iPhone."
            session.restartPolling()
            return
        }

        let tagBox = DetectedNDEFTagBox(tag)
        session.connect(to: tag) { [detector = self, tagBox] error in
            if let error {
                Task { @MainActor [detector] in detector.finish(.failure(error)) }
                return
            }

            tagBox.tag.queryNDEFStatus { [detector] status, _, error in
                Task { @MainActor [detector] in
                    if let error {
                        detector.finish(.failure(error))
                    } else if status == .readWrite {
                        detector.finish(.success(()), message: "Tag detected. Continue setup in Ripple.")
                    } else {
                        detector.finish(.failure(NFCBottleWriterError.readOnly))
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

private final class DetectedNDEFTagBox: @unchecked Sendable {
    nonisolated(unsafe) let tag: NFCNDEFTag

    nonisolated init(_ tag: NFCNDEFTag) {
        self.tag = tag
    }
}
