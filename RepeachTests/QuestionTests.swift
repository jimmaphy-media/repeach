import Testing
@testable import Repeach

@Suite("Questions")
struct QuestionTests {
    @Test("Question should be complete")
    func questionIsComplete() throws {
        let Question = Question(prompt: "Is this a question?", answer: "Yes")
        #expect(Question.isComplete)
    }
    
    @Test("Question should be incomplete")
    func questionIsIncomeplete() throws {
        let questionEmpty = Question()
        let questionEmptyQuestion = Question(prompt: "")
        let questionWhiteSpaceQuestion = Question(prompt: " ", answer: "Yes")
        let questionEmptyAnswer = Question(answer: "")
        let questionWhiteSpaceAnswer = Question(prompt: "Is this a question?", answer: " ")
        let questionWithoutAnswer = Question(prompt: "Is this a question?", answer: "")
        let QuestionWithoutQuestion = Question(prompt: "", answer: "Yes")
        
        #expect(!questionEmpty.isComplete)
        #expect(!questionEmptyQuestion.isComplete)
        #expect(!questionWhiteSpaceQuestion.isComplete)
        #expect(!questionEmptyAnswer.isComplete)
        #expect(!questionWhiteSpaceAnswer.isComplete)
        #expect(!questionWithoutAnswer.isComplete)
        #expect(!QuestionWithoutQuestion.isComplete)
    }

    @Test("Question should be reversable")
    func questionIsReversable() throws {
        let question = Question(prompt: "Is this a question?", answer: "Yes")
        let reversedQuestion = question.reversed()
        #expect(reversedQuestion.prompt == "Yes" && question.prompt == "Is this a question?")
        #expect(reversedQuestion.answer == "Is this a question?" && question.answer == "Yes")

        let incompleteQuestion = Question(prompt: "What is the meaning of live?")
        let reversedIncopleteQuestion = incompleteQuestion.reversed()
        #expect(reversedIncopleteQuestion.prompt == "" && incompleteQuestion.prompt == "What is the meaning of live?")
        #expect(reversedIncopleteQuestion.answer == "What is the meaning of live?" && incompleteQuestion.answer == "")
    }
}
