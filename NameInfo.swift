import Foundation

/**
 NameInfo
 
 Holds information relevant to a set of names and pronouns that the user inputs
 */

struct NameInfo: Identifiable {
    var name: String                    // The associated name
    var subjectivePronoun: String       // The associated subjective pronoun (like "he")
    var objectivePronoun: String        // The associated objective pronoun (like "her")
    var possessivePronoun: String       // The associated possessive pronoun (like "their")
    var isFavorite: Bool = false        // Whether the set is a favorite
    var positiveSwipes: Int = 0         // Number of times the user has swiped positively on a sample with this name
    var negativeSwipes: Int = 0         // Number of times the user has swiped negatively on a sample with this name
    var acceptedSamples: [String] = []  // List of samples that were accepted with this name
    var rejectedSamples: [String] = []  // List of samples that were rejected with this name
    var id = UUID()                     // ID for Identifiable
    
    /**
    getSwipeRatio
     
    Gets the portion of times that the user has positively out of all swipes, scaled as an integer from 0-100
     */
    func getSwipeRatio() -> Int {
        if (positiveSwipes == 0 && negativeSwipes == 0) { // To avoid division by 0, the 0 positive swipes and 0 negative swipes edge case is interpreted as a 0% acceptance ratio
            return 0;
        }
        return Int(100*Double(positiveSwipes)/Double(negativeSwipes+positiveSwipes))
    }
    
    /**
     getPronounChain
     
     Gets a string with all the pronouns in order with the common format, eg. "he/him/his"
     */
    func getPronounChain() -> String {
        return subjectivePronoun+"/"+objectivePronoun+"/"+possessivePronoun
    }
    
    /**
    toggleFavorite
            
     toggles whether the sample is a favorite or not
     */
    mutating func toggleFavorite() -> Void {
        isFavorite = !isFavorite
    }
}
