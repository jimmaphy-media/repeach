import SwiftUI

struct QuestionnaireView: View {
    @Binding var document: RepeachFile
    @State private var quizStyle = QuizStyle.linear
    @State private var quiz: Quiz?
    @State private var showSettings = true
    @State private var newQuestionID: UUID?
    @State private var reversedQuiz = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case prompt(UUID)
        case answer(UUID)
    }
    
    private var ready: Bool {
        !document.questionnaire.questions.isEmpty && document.questionnaire.questions.allSatisfy(\.isComplete)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if document.questionnaire.questions.isEmpty {
                    ContentUnavailableView("Begin met een vraag", systemImage: "text.badge.plus", description: Text("Je hebt een lege lijst voor je. Begin snel met het toevoegen van de eerste vraag!"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                HStack {
                    Text("Vraag")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Antwoord")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(width: 80)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                
                Divider()

                ScrollViewReader { proxy in
                    List {
                        ForEach($document.questionnaire.questions) { $question in
                            HStack(alignment: .top) {
                                TextField("Vraag", text: $question.prompt, axis: .vertical)
                                    .focused($focusedField, equals: .prompt(question.id))
                                    .padding(.horizontal, 8)
                                    .onKeyPress(keys: [.tab], phases: .down) { press in
                                        guard press.modifiers.isEmpty else { return .ignored }
                                        focusedField = .answer(question.id)
                                        return .handled
                                    }
                                
                                TextField("Antwoord", text: $question.answer, axis: .vertical)
                                    .focused($focusedField, equals: .answer(question.id))
                                    .padding(.horizontal, 4)
                                    .onKeyPress(keys: [.return, KeyEquivalent("\u{3}")], phases: .down) { press in
                                        guard press.modifiers.isEmpty else { return .ignored }
                                        addQuestion(after: question.id)
                                        return .handled
                                    }
                                    .onKeyPress(keys: [.tab], phases: .down) { press in
                                        guard press.modifiers.isEmpty else { return .ignored }
                                        focusedField = .prompt(question.id)
                                        return .handled
                                    }
                                
                                HStack {
                                    Button("Omhoog", systemImage: "arrow.up") {
                                        moveUp(question.id)
                                    }
                                    .disabled(document.questionnaire.questions.first?.id == question.id)
                                    
                                    Button("Verwijderen", systemImage: "trash") {
                                        document.questionnaire.questions.removeAll { $0.id == question.id }
                                    }
                                }
                                .frame(minWidth: 80, maxWidth: 80)
                            }
                            .labelStyle(.iconOnly)
                            .textFieldStyle(.plain)
                            .buttonStyle(.borderless)
                            .padding(.vertical, 8)
                            .id(question.id)
                            .onAppear {
                                if newQuestionID == question.id {
                                    focusedField = .prompt(question.id)
                                    newQuestionID = nil
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                    .onChange(of: document.questionnaire.questions.count) {
                        if let newQuestionID {
                            proxy.scrollTo(newQuestionID)
                        }
                    }
                }
                }
            }
            .background(.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Text("\(document.questionnaire.questions.count) vragen")
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.bar)
                .overlay(Rectangle().frame(width: nil, height: 0.5, alignment: .top).foregroundColor(.gray.opacity(0.25)), alignment: .top)

            }
        }
        .frame(minWidth: 740, minHeight: 480)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Vraag Toevoegen", systemImage: "plus") {
                    addQuestion()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .help("Vraag toevoegen (⇧+⌘+N)")
            }
        }
        .inspector(isPresented: $showSettings) {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Picker("Overhoormethode", selection: $quizStyle) {
                            ForEach(QuizStyle.allCases) {
                                Text($0.title).tag($0)
                            }
                        }
                        .pickerStyle(.radioGroup)
                        .labelsHidden()
                        .accessibilityLabel("Overhoormethode")
                    } header: {
                        Label("Methode", systemImage: "chart.line.text.clipboard")
                    } footer: {
                        Text(quizStyle.explanation)
                        Spacer()
                    }

                    Section {
                        Picker("Vraagstelling", selection: $reversedQuiz) {
                            ForEach([false, true], id: \.self) {
                                Text($0 ? "Omgekeerd" : "Normaal").tag($0)
                            }
                        }
                        .pickerStyle(.radioGroup)
                        .labelsHidden()
                        .accessibilityLabel("Vraagstelling")
                    } header: {
                        Label("Vraagstelling", systemImage: "bubble.left.and.bubble.right")
                    } footer: {
                        Text(reversedQuiz ? "Je krijgt het antwoord te zien en moet de vraag invullen." : "Je geeft antwoord op de vragen")
                    }
                }
                .formStyle(.grouped)

                Button("Overhoren", systemImage: "play.fill") {
                    let questions = reversedQuiz
                        ? document.questionnaire.questions.map { $0.reversed() }
                        : document.questionnaire.questions

                    quiz = Quiz(asking: questions, style: quizStyle)
                }
                .help("Start overhoring")
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(20)
            }
            .toolbar {
                ToolbarItem {
                    Spacer()
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Overhoring", systemImage: "graduationcap") {
                        showSettings.toggle()
                    }
                    .help("Begin een overhoring")
                }
            }
            .inspectorColumnWidth(min: 260, ideal: 280, max: 320)
        }
        .sheet(isPresented: Binding(get: { quiz != nil }, set: { if !$0 { quiz = nil }})) {
            if let quiz { QuizView(quiz: quiz) }
        }
    }
    
    private func addQuestion(after id: UUID? = nil) {
        let question = Question()
        let index = id.flatMap { id in document.questionnaire.questions.firstIndex { $0.id == id }}
        
        newQuestionID = question.id
        document.questionnaire.questions.insert(question, at: index.map { $0 + 1 } ?? document.questionnaire.questions.count )
    }
    
    private func moveUp(_ id: UUID) {
        guard let index = document.questionnaire.questions.firstIndex(where: { $0.id == id }), index > 0 else { return }
        document.questionnaire.questions.swapAt(index, index - 1)
    }
}

#Preview {
    @Previewable @State var emptyFile = RepeachFile()
    QuestionnaireView(document: $emptyFile)
}
