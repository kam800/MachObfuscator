@testable import App
import Foundation

class ArraySentenceGenerator: SentenceGenerator {
    var sentences: [String] = []
    func getUniqueSentence(length: Int) -> String? {
        guard let sentenceIndex = sentences.firstIndex(where: { $0.count == length }) else {
            return nil
        }

        return sentences.remove(at: sentenceIndex)
    }
}
