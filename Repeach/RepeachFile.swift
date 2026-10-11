import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let repeach = UTType(exportedAs: "nl.repeach.questionnaire", conformingTo: .json)
}

struct RepeachFile: FileDocument {
    static let readableContentTypes: [UTType] = [.repeach, .json]
    var questionnaire: Questionnaire
    
    init() {
        self.questionnaire = Questionnaire()
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        questionnaire = try Questionnaire.decode(data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: try questionnaire.encode())
    }
}
