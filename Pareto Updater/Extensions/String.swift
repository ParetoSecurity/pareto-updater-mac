//
//  String.swift
//  Pareto Updater
//
//  Created by Janez Troha on 06/07/2022.
//

import Foundation

extension String {
    var versionNormalize: String {
        var version = lowercased().removingWhitespaces()
        if version.contains("alpha") {
            version = version.replacingOccurrences(of: "alpha", with: "-alpha")
        }
        if version.contains("beta") {
            version = version.replacingOccurrences(of: "beta", with: "-beta")
        }
        version = version.replacingOccurrences(of: ".-", with: "-")
        version = version.replacingOccurrences(of: "release", with: "")
        version = version.replacingOccurrences(of: "version", with: "")
        version = version.replacingOccurrences(of: "(", with: "")
        version = version.replacingOccurrences(of: ")", with: "")
        version = version.replacingOccurrences(of: "v", with: "")
        return version
    }

    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let numbersOnly = replacingOccurrences(of: versionDelimiter, with: "")
        let otherNumbersOnly = otherVersion.replacingOccurrences(of: versionDelimiter, with: "")

        let zeroDiff = numbersOnly.count - otherNumbersOnly.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return numbersOnly.compare(otherNumbersOnly, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }

    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
