import Foundation

/// A quiz provides an interactive way to learn the questions in a questionnaire.
/// Supplying a seed makes its randomized ordering reproducible.
struct Quiz: Sendable {
    static let groupSize = 5
    public static let masteryThreshold = 4

    let questions: [Question]
    let style: QuizStyle
    
    var attempts = 0
    var correctAnswers = 0
    var round = 1

    private var queue: [Int] = []
    private var streaks: [Int: Int] = [:]
    private var waiting: [Int] = []
    private var activeGroup: [Int] = []
    private var failures: [Int] = []
    private var rng: SeededRandomNumberGenerator
        
    init(asking questions: [Question], style: QuizStyle, seed: UInt64 = .random(in: .min ... .max)) {
        self.rng = SeededRandomNumberGenerator(with: seed)
        self.questions = questions.filter(\.isComplete)
        self.style = style

        switch style {
        case .linear, .linearRepeat:
            queue = Array(self.questions.indices)
        
        case .shuffled, .shuffledRepeat:
            queue = self.questions.indices.shuffled(using: &rng)
        
        case .extensive:
            waiting = self.questions.indices.shuffled(using: &rng)
            fillGroup()
        }
    }

    var currentQuestion: Question? { queue.first.map { questions[$0] } }
    var isFinished: Bool { queue.isEmpty }
    var mastered: Int { streaks.values.count { $0 >= Self.masteryThreshold } }
    var currentStreak: Int { queue.first.map { streaks[$0, default: 0] } ?? 0 }

    /// Submit an answer to the current question and proceed with the quiz.
    /// - Returns: A string with the correct answer is returned if the provided answer is incorrect.
    mutating func submitAndContinue(answer: String) -> String? {
        guard let index = queue.first else { return nil }
        let correctAnswer = questions[index].answer
        let answeredCorrectly = answer.normalize() == correctAnswer.normalize()
        
        attempts += 1
        queue.removeFirst()

        if answeredCorrectly {
            correctAnswers += 1
            streaks[index] = streaks[index, default: 0] + 1
        }
        
        if !answeredCorrectly {
            streaks[index] = 0
            failures.append(index)
        }

        if style == .extensive {
            replaceMasteredQuestions()
        }

        if queue.isEmpty {
            startNextRound(after: index)
        }
        
        return answeredCorrectly ? nil : correctAnswer
    }

    private mutating func startNextRound(after previousIndex: Int) {
        if style == .linearRepeat || style == .shuffledRepeat {
            queue = failures
        }
        
        if style == .extensive {
            queue = activeGroup.shuffled(using: &rng)
            preventRepeatingQuestion(after: previousIndex)
        }

        failures.removeAll()
        round += queue.isEmpty ? 0 : 1
    }
    
    private mutating func preventRepeatingQuestion(after previousIndex: Int) {
        if queue.count > 1 && queue.first == previousIndex {
            queue.swapAt(0, 1)
        }
    }
    
    private mutating func replaceMasteredQuestions() {
        activeGroup.removeAll { streaks[$0, default: 0] >= Self.masteryThreshold }
        fillGroup()
    }
    
    private mutating func fillGroup() {
        let additions = Array(waiting.prefix(Self.groupSize - activeGroup.count))
        waiting.removeFirst(additions.count)
        activeGroup.append(contentsOf: additions)
        queue.append(contentsOf: additions)
    }
}
