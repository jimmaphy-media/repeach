import Foundation

extension String {
    /// Whether the string is either empty, or contains exclusively whitespaces and newlines.
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Normalize the string to lowercase, trimmed of whitespace and newlines, and canonical mapping.
    func normalize() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
            .lowercased()
    }
}
