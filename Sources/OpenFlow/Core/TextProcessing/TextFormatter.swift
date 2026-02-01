import Foundation

class TextFormatter {
    private let fillerWords = [
        "um", "uh", "ah", "er",
        "you know", "i mean", "sort of", "kind of",
        "basically", "literally", "actually"
    ]
    
    private let backtrackPatterns = [
        "actually",
        "i mean",
        "make that",
        "scratch that"
    ]
    
    private let customDictionary: [String: String] = [:]
    
    func process(_ text: String, partial: Bool = false) -> String {
        var processed = text
        
        if !partial {
            processed = removeFillerWords(processed)
            processed = addPunctuation(processed)
            processed = applyCustomDictionary(processed)
        }
        
        processed = processed.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return processed
    }
    
    private func removeFillerWords(_ text: String) -> String {
        var result = text.lowercased()
        
        for filler in fillerWords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: filler))\\b"
            result = result.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return result
    }
    
    private func addPunctuation(_ text: String) -> String {
        var result = text
        
        let punctuationKeywords: [String: String] = [
            "comma": ",",
            "period": ".",
            "question mark": "?",
            "exclamation mark": "!",
            "new line": "\n",
            "new paragraph": "\n\n"
        ]
        
        for (keyword, punctuation) in punctuationKeywords {
            result = result.replacingOccurrences(of: "\\b\(keyword)\\b", with: punctuation, options: .regularExpression)
        }
        
        if !result.isEmpty {
            let firstChar = result.prefix(1).uppercased()
            result = firstChar + result.dropFirst()
            
            if !result.hasSuffix(".") && !result.hasSuffix("?") && !result.hasSuffix("!") && !result.hasSuffix("\n") {
                result += "."
            }
        }
        
        return result
    }
    
    private func applyCustomDictionary(_ text: String) -> String {
        var result = text
        
        for (original, replacement) in customDictionary {
            result = result.replacingOccurrences(of: original, with: replacement, options: .caseInsensitive)
        }
        
        return result
    }
    
    func addCustomWord(original: String, replacement: String) {
        // To be implemented with persistent storage
    }
}
