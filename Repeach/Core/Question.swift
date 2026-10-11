import Foundation

/// A straightforward question with a prompt and an answer stored as `String`.
struct Question: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var prompt: String
    var answer: String
    
    init(prompt: String = "", answer: String = "") {
        self.id = UUID()
        self.prompt = prompt
        self.answer = answer
    }
    
    private init(_ id: UUID, _ prompt: String, _ answer: String) {
        self.id = id
        self.prompt = prompt
        self.answer = answer
    }
    
    /// A question is considered complete when it has both a prompt and an answer that are neither empty or whitespaced.
    var isComplete: Bool {
        !prompt.isBlank && !answer.isBlank
    }
    
    /// Reverse the prompt and the answer, preserving the identifier of the question.
    func reversed() -> Question {
        return Question(id, answer, prompt)
    }
}

