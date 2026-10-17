import Testing
@testable import Repeach

@Suite("Questions") struct QuestionTests {

    @Test("Question should be complete") func QuestionIsComplete() async throws {
        let Question = await Question(prompt: "Is this a question?", answer: "Yes")
        #expect((await Question.isComplete))
    }
    
    @Test("Question should be incomplete") func QuestionIsIncomeplete() async throws {
        let questionEmpty = await Question()
        let questionEmptyQuestion = await Question(prompt: "")
        let questionWhiteSpaceQuestion = await Question(prompt: " ")
        let questionEmptyAnswer = await Question(answer: "")
        let questionWhiteSpaceAnswer = await Question(answer: " ")
        let questionWithoutAnswer = await Question(prompt: "Is this a question?", answer: "")
        let QuestionWithoutQuestion = await Question(prompt: "", answer: "Yes")
        
        #expect(!(await questionEmpty.isComplete))
        #expect(!(await questionEmptyQuestion.isComplete))
        #expect(!(await questionWhiteSpaceQuestion.isComplete))
        #expect(!(await questionEmptyAnswer.isComplete))
        #expect(!(await questionWhiteSpaceAnswer.isComplete))
        #expect(!(await questionWithoutAnswer.isComplete))
        #expect(!(await QuestionWithoutQuestion.isComplete))
    }

    @Test("Question should be reversable") func QuestionIsReversable() async throws {
        let question = await Question(prompt: "Is this a question?", answer: "Yes")
        let reversedQuestion = await question.reversed()
        #expect((await reversedQuestion.prompt) == "Yes")
        #expect((await reversedQuestion.answer) == "Is this a question?")

        let incompleteQuestion = await Question(prompt: "What is the meaning of live?")
        let reversedIncopleteQuestion = await incompleteQuestion.reversed()
        #expect((await reversedIncopleteQuestion.prompt) == "")
        #expect((await reversedIncopleteQuestion.answer) == "What is the meaning of live?")
    }
}
