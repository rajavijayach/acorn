import Foundation
import Observation

/// Streams a container's logs via `container logs -f <name>`.
///
/// Lives for the lifetime of an app's detail view (not the Logs tab), so that
/// switching tabs does not tear down and restart the follow — which would
/// re-read the full history and duplicate output.
@MainActor
@Observable
final class LogStream {
    struct Line: Identifiable {
        let id: Int
        let text: String
    }

    private(set) var lines: [Line] = []
    private(set) var isPaused = false
    private(set) var isStreaming = false

    /// Buffered while paused, flushed on resume so no output is lost.
    private var pending: [Line] = []
    private var nextID = 0
    private var task: Task<Void, Never>?
    private var process: Process?

    /// The current buffer as plain text, for copying.
    var text: String {
        lines.map(\.text).joined(separator: "\n")
    }

    func start(appID: String, runtimeAvailable: Bool) {
        guard !isStreaming else { return }
        isStreaming = true

        guard runtimeAvailable else {
            // Apple Container isn't installed (development/testing). Drive the
            // same ingest path with simulated output so the UI is exercised.
            ingest("Apple Container is not installed — showing simulated output.")
            ingest("[postgres] database system is ready to accept connections")
            ingest("[postgres] listening on IPv4 address \"0.0.0.0\", port 5432")
            isStreaming = false
            return
        }

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["container", "logs", "-f", appID]
        process.standardOutput = pipe
        process.standardError = pipe
        self.process = process

        // The class is @MainActor, so this Task inherits the main actor and may
        // mutate observable state directly. `bytes.lines` handles line carry and
        // ends when the process terminates (EOF).
        task = Task { [weak self] in
            do {
                try process.run()
                for try await line in pipe.fileHandleForReading.bytes.lines {
                    self?.ingest(line)
                }
            } catch {
                self?.ingest("Failed to stream logs: \(error.localizedDescription)")
            }
            self?.isStreaming = false
        }
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
        lines.append(contentsOf: pending)
        pending = []
    }

    func clear() {
        lines = []
        pending = []
    }

    func stop() {
        task?.cancel()
        task = nil
        // Terminate the process explicitly: a follow blocked awaiting the next
        // byte won't observe Task cancellation until more output arrives.
        process?.terminate()
        process = nil
        isStreaming = false
    }

    private func ingest(_ text: String) {
        let line = Line(id: nextID, text: text)
        nextID += 1

        if isPaused {
            pending.append(line)
        } else {
            lines.append(line)
        }
    }
}
