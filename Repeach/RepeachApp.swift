import SwiftUI

@main
struct RepeachApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: RepeachFile()) { file in
            QuestionnaireView(document: file.$document)
        }
        .defaultSize(width: 1040, height: 680)
        .windowToolbarStyle(.unified)
    }
}
