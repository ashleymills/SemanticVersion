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
    public let preRelease: [String]?
    public let build: [String]?

    public init(major: UInt, minor: UInt = 0, patch: UInt = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
        preRelease = nil
        build = nil
    }

    public init?(major: UInt, minor: UInt, patch: UInt, preRelease: [String]? = nil, build: [String]? = nil) { // TODO: [Ash] Make throws with useful messaging
        self.major = major
        self.minor = minor
        self.patch = patch
        
        let allowedIdentifierCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(arrayLiteral: "-"))
        
        if let preRelease {
            for component in preRelease {
                if let _ = component.rangeOfCharacter(from: allowedIdentifierCharacterSet.inverted) { // Must contain only alphanumerics
                    return nil
                }
                if component.count > 1, component.hasPrefix("0") { // Can't start with 0
                    return nil
                }
            }            
        } 
        self.preRelease = preRelease 

        if let build {
            for component in build {
                if let _ = component.rangeOfCharacter(from: allowedIdentifierCharacterSet.inverted) { // Must contain only alphanumerics
                    return nil
                }
                if component.count > 1, component.hasPrefix("0") { // Can't start with 0
                    return nil
                }
            }
        }
        self.build = build            
    }
    
    public static var v1_0_0: SemanticVersion {
        SemanticVersion(major: 1, minor: 0, patch: 0)
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

public extension SemanticVersion {

    init?(_ string: String) {
        
        let main: String
        let preRelease: String?
        let build: String?
        if let hyphenIndex = string.firstIndex(of: "-") {
            let prStart = string.index(after: hyphenIndex)            
            main = String(string[..<hyphenIndex])            
            let remainder = String(string[prStart...])
            if remainder.isEmpty {
                return nil
            }            
            preRelease = remainder
            build = nil
        } else {
            main = string
            preRelease = nil
            build = nil
        }
        
        var components = main.components(separatedBy: ".")
        guard components.count > 0, components.count < 4 else { return nil }

        components.append(contentsOf: repeatElement("0", count: 3 - components.count))

        let values = components.compactMap(UInt.init)

        guard values.count == components.count else { return nil }

        if let preRelease {
            let preRelease = preRelease.components(separatedBy: ".")
            let build = build?.components(separatedBy: ".") 
            self.init(major: values[0], minor: values[1], patch: values[2], preRelease: preRelease, build: build)
        } else {
            self.init(major: values[0], minor: values[1], patch: values[2])
        }        
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
        var version = "\(major).\(minor).\(patch)"
        
        if let preRelease {
            version.append("-" + preRelease.joined(separator: "."))
        }
        if let preRelease = build {
            version.append("-" + preRelease.joined(separator: "."))
        }
        return version
    }
}
