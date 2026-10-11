/// The QuizStyle is used to determine how a quiz is to be generated.
///
/// - A `linear` quiz asks all questions in order.
/// - A `linearRepeat` quiz asks all questions in order, repeating wrong answered question at the end of the quiz.
/// - A `shuffled` quiz asks all questions in random order.
/// - A `shuffledRepeat` quiz asks all questions in random order, repeating wrong answered question at the end of the quiz.
/// - An `extensive` quiz asks all questions in random order, having to answer each question correctly 4 times in a row.
enum QuizStyle: String, CaseIterable, Identifiable, Sendable {
    case linear
    case linearRepeat
    case shuffled
    case shuffledRepeat
    case extensive
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .linear: "Lineair"
        case .linearRepeat: "Lineair met herhaling"
        case .shuffled: "Willekeurig"
        case .shuffledRepeat: "Willekeurig met herhaling"
        case .extensive: "Uitgebreid"
        }
    }
    
    var explanation: String {
        switch self {
        case .linear: "Alle vragen worden één keer op volgorde van de lijst gesteld."
        case .linearRepeat: "Alle vragen worden op volgorde gesteld, waarna fouten antwoorden worden herhaald tot ze goed zijn."
        case .shuffled: "Alle vragen worden één keer op willekeurige volgorde gesteld."
        case .shuffledRepeat: "Alle vragen worden op willekeurige volgorde gesteld, waarna fouten antwoorden worden herhaald tot ze goed zijn."
        case .extensive: "De vragen worden op willekeurige volgorde gesteld, maar komen terug tot ze vier keer op rij goed zijn beantwoord."
        }
    }
}
