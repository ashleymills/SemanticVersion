import Foundation

public struct SemanticVersion: Comparable, Codable {
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major < rhs.major ||
            (lhs.major == rhs.major && lhs.minor < rhs.minor) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }

    public let major: UInt
    public let minor: UInt
    public let patch: UInt

    public init(major: UInt, minor: UInt = 0, patch: UInt = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension SemanticVersion {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let version = SemanticVersion(string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticVersion format: \(string)")
        }
        self = version
    }
}

public extension SemanticVersion {

    init?(_ string: String) {
        var components = string.components(separatedBy: ".")
        guard components.count > 0, components.count < 4 else { return nil }

        components.append(contentsOf: repeatElement("0", count: 3 - components.count))

        let values = components.compactMap { UInt($0) }

        guard values.count == components.count else { return nil }

        major = values[0]
        minor = values[1]
        patch = values[2]
    }

    var nextMajor: SemanticVersion {
        SemanticVersion(major: major + 1, minor: 0, patch: 0)
    }

    var nextMinor: SemanticVersion {
        SemanticVersion(major: major, minor: minor + 1, patch: 0)
    }

    var nextPatch: SemanticVersion {
        SemanticVersion(major: major, minor: minor, patch: patch + 1)
    }

    var majorString: String {
        "\(major)"
    }

    var minorString: String {
        "\(major).\(minor)"
    }
}

extension SemanticVersion: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
