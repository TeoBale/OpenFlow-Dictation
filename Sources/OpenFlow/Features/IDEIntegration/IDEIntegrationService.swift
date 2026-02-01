import Foundation
import AppKit

@MainActor
class IDEIntegrationService {
    static var shared: IDEIntegrationService {
        MainActor.assertIsolated()
        return IDEIntegrationService()
    }
    
    private var currentIDE: IDETypes = .none
    
    enum IDETypes {
        case cursor
        case windsurf
        case vscode
        case none
    }
    
    private init() {
        detectCurrentIDE()
    }
    
    private func detectCurrentIDE() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            currentIDE = .none
            return
        }
        
        let bundleId = frontmostApp.bundleIdentifier ?? ""
        
        switch bundleId {
        case "com.cursor.app":
            currentIDE = .cursor
        case "com.exafunction.windsurf":
            currentIDE = .windsurf
        case "com.microsoft.VSCode":
            currentIDE = .vscode
        default:
            currentIDE = .none
        }
    }
    
    func processForIDE(text: String) -> String {
        detectCurrentIDE()
        
        var processed = text
        
        switch currentIDE {
        case .cursor, .windsurf:
            processed = handleFileTagging(processed)
            processed = handleCommandInjection(processed)
        case .vscode:
            break
        case .none:
            break
        }
        
        return processed
    }
    
    private func handleFileTagging(_ text: String) -> String {
        let pattern = "tag ([a-zA-Z0-9_\\.]+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return text
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var result = text
        
        for match in matches.reversed() {
            if let fileRange = Range(match.range(at: 1), in: text) {
                let filename = String(text[fileRange])
                result = result.replacingCharacters(in: Range(match.range, in: text)!, with: "@\(filename)")
            }
        }
        
        return result
    }
    
    private func handleCommandInjection(_ text: String) -> String {
        let commands: [String: String] = [
            "run this": "Run this code: ",
            "execute this": "Execute this code: ",
            "explain this": "Explain this code: ",
            "refactor this": "Refactor this code: ",
            "fix this": "Fix this code: ",
            "optimize this": "Optimize this code: ",
            "document this": "Document this code: ",
            "test this": "Write tests for this code: "
        ]
        
        var result = text.lowercased()
        
        for (trigger, prefix) in commands {
            if result.contains(trigger) {
                result = result.replacingOccurrences(of: trigger, with: prefix)
            }
        }
        
        return result
    }
    
    func getCurrentIDE() -> IDETypes {
        detectCurrentIDE()
        return currentIDE
    }
}
