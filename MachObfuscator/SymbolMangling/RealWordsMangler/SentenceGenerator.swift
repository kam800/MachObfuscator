import Foundation

// TODO:
// Concatenate
// 0-1 adverb https://www.talkenglish.com/vocabulary/top-250-adverbs.aspx
// with
// 1-* nouns https://www.talkenglish.com/vocabulary/top-1500-nouns.aspx

class SentenceGenerator {
    private var previousSentences: Set<String> = []

    // Returns unique random sentence, or nil when unique sentence can not be generated.
    func getUniqueSentence(length: Int) -> String? {
        // try 20 times before giving up
        for _ in 0 ..< 20 {
            let sentence = getSentence(length: length)
            if !previousSentences.contains(sentence) {
                previousSentences.insert(sentence)
                return sentence
            }
        }
        return nil
    }

    private func getSentence(length: Int) -> String {
        var randomWords: [String] = []
        var remainingLength = length
        while remainingLength > 0 {
            var nextWord = Words.multiletterWords.random!
            if nextWord.count > remainingLength {
                nextWord = Words.englishWordsPerLength[remainingLength]!.random!
            }
            randomWords.append(nextWord)
            remainingLength -= nextWord.count
        }
        let randomCapitalizedWords = randomWords.isEmpty
            ? []
            : randomWords.prefix(upTo: 1) + randomWords.suffix(from: 1).map { $0.capitalizedOnFirstLetter }
        return randomCapitalizedWords.joined()
    }
}

private extension Array {
    var random: Element? {
        guard !isEmpty else {
            return nil
        }
        return self[count.random]
    }
}

private extension Int {
    var random: Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}

private extension Words {
    static let englishWordsPerLength: [Int: [String]] = Dictionary(grouping: englishTop1000, by: { $0.count })
    static let multiletterWords: [String] = englishTop1000.filter { $0.count >= 2 }
}
