//
//  AR.swift
//  AshteMobile
//
//  Hardened reader for Debian ar archives.
//

import Foundation

final class AR: NSObject {
    private let data: Data

    /// Reads the archive without force-try. Invalid or unreadable files are reported
    /// to the caller instead of crashing the app.
    init(with url: URL) throws {
        do {
            self.data = try Data(contentsOf: url, options: [.mappedIfSafe])
        } catch {
            throw ARError.badArchive("Unable to read archive: \\(error.localizedDescription)")
        }
        super.init()
    }

    func extract() async throws -> [ARFileModel] {
        let magic: [UInt8] = [0x21, 0x3c, 0x61, 0x72, 0x63, 0x68, 0x3e, 0x0a]
        guard data.count >= magic.count, Array(data.prefix(magic.count)) == magic else {
            throw ARError.badArchive("Invalid archive signature")
        }

        var offset = magic.count
        var files: [ARFileModel] = []

        while offset < data.count {
            // Every ar member starts with a fixed 60-byte header.
            guard data.count - offset >= 60 else {
                throw ARError.badArchive("Truncated archive header")
            }

            let headerEnd = offset + 60
            guard data[offset + 58] == 0x60, data[offset + 59] == 0x0a else {
                throw ARError.badArchive("Invalid archive member header")
            }

            var name = try Self.field(data, offset, 16)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if name.hasSuffix("/") { name.removeLast() }
            guard !name.isEmpty else {
                throw ARError.badArchive("Archive member has no name")
            }

            let modificationDate = try Self.integerField(data, offset + 16, 12, radix: 10)
            let ownerId = try Self.integerField(data, offset + 28, 6, radix: 10)
            let groupId = try Self.integerField(data, offset + 34, 6, radix: 10)
            let mode = try Self.integerField(data, offset + 40, 8, radix: 8)
            let size = try Self.integerField(data, offset + 48, 10, radix: 10)

            guard size >= 0, size <= data.count - headerEnd else {
                throw ARError.badArchive("Archive member size is out of bounds")
            }

            let contentEnd = headerEnd + size
            let content = data.subdata(in: headerEnd..<contentEnd)

            files.append(
                ARFileModel(
                    name: name,
                    modificationDate: Date(timeIntervalSince1970: TimeInterval(modificationDate)),
                    ownerId: ownerId,
                    groupId: groupId,
                    mode: mode,
                    size: size,
                    content: content
                )
            )

            // ar members are padded to an even byte boundary.
            let padding = size % 2
            guard contentEnd <= data.count, padding <= data.count - contentEnd else {
                throw ARError.badArchive("Truncated archive padding")
            }
            offset = contentEnd + padding
        }

        return files
    }

    private static func field(_ data: Data, _ offset: Int, _ length: Int) throws -> String {
        guard offset >= 0, length >= 0, offset <= data.count, length <= data.count - offset,
              let value = String(data: data[offset..<(offset + length)], encoding: .ascii) else {
            throw ARError.badArchive("Invalid archive field")
        }
        return value
    }

    private static func integerField(_ data: Data, _ offset: Int, _ length: Int, radix: Int) throws -> Int {
        let raw = try field(data, offset, length)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty, let value = Int(raw, radix: radix) else {
            throw ARError.badArchive("Invalid numeric archive field")
        }
        return value
    }
}

enum ARError: Error, LocalizedError {
    case badArchive(String)

    var errorDescription: String? {
        if case .badArchive(let message) = self { return message }
        return "Invalid archive"
    }
}
