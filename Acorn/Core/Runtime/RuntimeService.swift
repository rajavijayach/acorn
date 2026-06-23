import Foundation

protocol RuntimeService {
    func isInstalled() async -> Bool
    func version() async -> String?
}

struct RuntimeInfo: Equatable {
    var isInstalled: Bool
    var version: String?

    static let unavailable = RuntimeInfo(isInstalled: false, version: nil)
}

struct AppleContainerRuntimeService: RuntimeService {
    func isInstalled() async -> Bool {
        await run(arguments: ["which", "container"])?.exitCode == 0
    }

    func version() async -> String? {
        guard await isInstalled() else {
            return nil
        }

        let result = await run(arguments: ["container", "--version"])
        guard result?.exitCode == 0 else {
            return nil
        }

        return result?.standardOutput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
    }

    func info() async -> RuntimeInfo {
        let installed = await isInstalled()
        return RuntimeInfo(isInstalled: installed, version: installed ? await version() : nil)
    }

    private func run(arguments: [String]) async -> ProcessResult? {
        await Task.detached {
            let process = Process()
            let output = Pipe()
            let error = Pipe()

            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = arguments
            process.standardOutput = output
            process.standardError = error

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = output.fileHandleForReading.readDataToEndOfFile()
                let errorData = error.fileHandleForReading.readDataToEndOfFile()

                return ProcessResult(
                    exitCode: process.terminationStatus,
                    standardOutput: String(decoding: outputData, as: UTF8.self),
                    standardError: String(decoding: errorData, as: UTF8.self)
                )
            } catch {
                return nil
            }
        }.value
    }
}

private struct ProcessResult {
    var exitCode: Int32
    var standardOutput: String
    var standardError: String
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
