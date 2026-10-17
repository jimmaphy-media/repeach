import Foundation
import Testing
@testable import Repeach

@Suite("Questionnaire")
struct QuestionnaireTests {
    private func getBasicQuestionnaire(withMissingValues: Bool = false) -> Questionnaire {
        .init(questions: [
            .init(prompt: "First question", answer: withMissingValues ? "" : "First answer"),
            .init(prompt: withMissingValues ? "" : "Second question", answer: "Second answer"),
        ])
    }
    
    @Test("Questionnaire is encodable when empty")
    func questionnaireEmptyIsEncodable() throws {
        let questionnaire = Questionnaire()
        _ = try questionnaire.encode()
    }
    
    @Test("Questionnaire with questions is encodable")
    func questionnaireWithQuestionsIsEncodable() {
        let questionnaire = getBasicQuestionnaire()
        _ = try? questionnaire.encode()
    }
    
    @Test("Questionnaire with incomplete questions is encodable")
    func questionnaireWithIncompleteQuestionsIsEncodable() {
        let questionnaire = getBasicQuestionnaire(withMissingValues: true)
        _ = try? questionnaire.encode()
    }
    
    @Test("File without content is not decodable")
    func questionnaireCannotBeDecodedFromNothing() throws {
        #expect(throws: (any Error).self) {
            _ = try Questionnaire.decode(Data())
        }
    }
    
    @Test("File without questions is decodable")
    func questionnaireWithoutQuestionsIsDecodable() throws {
        let questionnaire = Questionnaire()
        let data = try questionnaire.encode()
        _ = try Questionnaire.decode(data)
    }
    
    @Test("File with questions is decodable")
    func questionnaireWithQuestionsIsDecodable() throws {
        let questionnaire = getBasicQuestionnaire()
        let data = try questionnaire.encode()
        _ = try Questionnaire.decode(data)
    }
    
    @Test("File with incomplete questions is decodable")
    func questionnaireWithIncompleteQuestionsIsDecodable() throws {
        let questionnaire = getBasicQuestionnaire(withMissingValues: true)
        let data = try questionnaire.encode()
        _ = try Questionnaire.decode(data)
    }
}
