import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quiz: Quiz
    @State private var answer = ""
    @State private var feedback: String?
    @State private var currentSound: NSSound?
    @FocusState private var answerFocused: Bool
    
    var answeredCorrectly: Bool { feedback == nil }
    
    init(quiz: Quiz) {
        self.quiz = quiz
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label(quiz.style.title, systemImage: "graduationcap")
                    .font(.headline)
                Spacer()
                Button("Sluiten", systemImage: "xmark") { dismiss() }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.cancelAction)
                    .help("Sluiten (Esc)")
            }
            .padding(20)
            .background(.bar)
            
            ScrollView {
                VStack (alignment: .leading, spacing: 24) {
                    if let question = quiz.currentQuestion {
                        HStack {
                            Text("Ronde \(quiz.round)")
                            Spacer()
                            Text("\(quiz.attempts) beantwoord")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        
                        if quiz.style == .extensive {
                            ProgressView(value: Double(quiz.mastered), total: Double(quiz.questions.count)) {
                                Text("\(quiz.mastered) van \(quiz.questions.count) vragen geleerd")
                            }
                        }
                        
                        Text(question.prompt)
                            .font(.system(.title, design: .rounded, weight: .medium))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 16)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Je antwoord")
                                .font(.headline)
                            
                            TextField("Type je antwoord", text: $answer, axis: .vertical)
                                .font(.title3)
                                .textFieldStyle(.plain)
                                .padding(14)
                                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(answerFocused ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: answerFocused ? 2 : 1)
                                }
                                .focused($answerFocused)
                            
                            if quiz.style == .extensive {
                                Text("Deze vraag: \(quiz.currentStreak) van \(Quiz.masteryThreshold) op rij goed")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if quiz.attempts > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Label(answeredCorrectly ? "Goed!" : "Nog niet goed", systemImage: answeredCorrectly ? "checkmark.circle.fill" : "arrow.trianglehead.clockwise")
                                    .font(.headline)
                                    .foregroundStyle(answeredCorrectly ? .green : .orange)
                                
                                if !answeredCorrectly {
                                    Text("Juiste antwoord")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(feedback ?? "")
                                        .textSelection(.enabled)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(.background, in: RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text ("Hoofdletters en spaties aan het begin/einde tellen niet mee. Accenten en leestekens wel.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(.green)
                            
                            Text("Overhoring afgerond")
                                .font(.title.bold())
                            
                            Text("\(quiz.correctAnswers) van \(quiz.attempts) antwoorden goed.")
                                .foregroundStyle(.secondary)
                            
                            if (quiz.style == .extensive) {
                                Text("Alle \(quiz.questions.count) vragen vier keer op rij goed beantwoord.")
                            }
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(32)
            }
            
            HStack {
                Spacer()
                
                if quiz.isFinished {
                    Button("Terug naar de lijst") { dismiss() }
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Controleer") {
                        feedback = quiz.submitAndContinue(answer: answer)
                        answer = ""
                        answerFocused = true
                        
                        playingSound(for: answeredCorrectly)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(answer.isEmpty)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(20)
            .background(.bar)
        }
        .background(.background.secondary)
        .frame(width: 620, height: 580)
        .onAppear { answerFocused = true }
    }
    
    private func playingSound(for answeredCorrectly: Bool) {
        currentSound?.stop()

        let soundName = answeredCorrectly ? "Funk" : "Sosumi"
        currentSound = NSSound(named: NSSound.Name(soundName))
        currentSound?.play()
    }
}

#Preview {
    let quiz = Quiz(asking: [
        Question(prompt: "What comes after A", answer: "B"),
        Question(prompt: "What comes after B", answer: "C"),
        Question(prompt: "What comes after C", answer: "D")
    ], style: .extensive)
    
    QuizView(quiz: quiz)
}
