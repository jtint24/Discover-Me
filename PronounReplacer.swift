import Foundation

/**
 pronounReplacer
 
 Replaces codes in a particular sample with the actual pronouns that the user entered
 */

struct PronounReplacer {
    /**
     replace
    
     inputs a sample and a set of name info, and replaces the annotated codes with the proper name or pronouns from it
     */
    
    static func replace(sample: String, from info: NameInfo) -> String {
        return sample
            .replacingOccurrences(of: ";him", with: info.objectivePronoun)
            .replacingOccurrences(of: ";he", with: info.subjectivePronoun)
            .replacingOccurrences(of: ";his", with: info.possessivePronoun)
            .replacingOccurrences(of: ";name", with: info.name)
            .capitalizingFirstLetter()
    }
}


extension String { // Extends string with a method that capitalizes the first letter, for convienience.
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
