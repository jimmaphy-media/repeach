import Foundation

/// A questionnaire is a collection of `Question`, encodable to and decodable from `json`.
struct Questionnaire: Codable, Equatable, Sendable {
    let version: UInt8
    var questions: [Question]
    
    init(questions: [Question] = []) {
        self.version = 1
        self.questions = questions
    }
    
    /// Try to decode a questionnaire from `json`.
    /// - Throws: `fileReadUnsupportedScheme` if the version of the file is unknown.
    ///           `fileReadCorruptFile` if the file has duplicate identifiers.
    ///           `dataCorrupted` if the syntax of the file is invalid.
    static func decode(_ data: Data) throws -> Self {
        let list = try JSONDecoder().decode(Self.self, from: data)
        guard list.version == 1 else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }
        
        let uniqueQuestionIds = Set(list.questions.map(\.id))
        guard uniqueQuestionIds.count == list.questions.count else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        return list
    }
    
    /// Try to encode a questionnaire to `json`.
    /// - Throws: `invalidValue` if the data is not encodable.
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }
}
