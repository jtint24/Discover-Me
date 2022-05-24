import Foundation
import NaturalLanguage

/**
 TextSorter
 
 Uses Natural Language Processing to find text samples which are dissimilar to ones that the user has already made a swipe on. This helps show the user a diverse range of samples quickly so they can get an accurate feeling for how a name and pronoun set feels to them in a variety of situations.
  */
struct TextSorter {
    var embedding: NLEmbedding = NLEmbedding()  // The embedding to check for text similarity between two samples
    private var preparedSample = ""
    /**
     findNextTextSample
     
     checks for a sample within a sample space which would be appropriate to show the user next. If enough swipe data has been made to properly compare against, then the NL model is used. Otherwise, a random sample in the sample space is chosen.
     */
    
    func findNextTextSample(sampleSpace: [String], currentName: NameInfo) -> String {
        if (currentName.rejectedSamples.count<5 || currentName.acceptedSamples.count<5) {
            return sampleSpace.randomElement()!
        }
        return findNeutralSample(sampleCat1: currentName.rejectedSamples, sampleCat2: currentName.acceptedSamples, sampleSpace: sampleSpace)
    }
    
    /**
    findNeutralSample
     
     Finds a text sample in a sample space which is roughly as similar to one category as a second. This helps find text samples which are not super close to either the accepted samples nor the rejected samples for a particular name; that is to say, samples which are already clearly in one category. This helps show the user diverse and decisive samples rather than ones which are similar to samples they've already swiped on.
     
     Because checking a sample's average similarity to two categories is relatively expensive, and new samples need to be generated quickly for a responsive UI, a probabalistic method using a running confidence interval is used to find a sample within the sample space which is *likely* close to the minimum neutrality, allowing it to stop well before traversing the entire sample space.
     
     */
    
    private func findNeutralSample(sampleCat1: [String], sampleCat2: [String], sampleSpace: [String]) -> String {
        var neutralitySum = 0.0 // Sum of all the neutrality scores seen so far
        var neutralitySumSQ = 0.0 // Sum of the squares of all the neutrality
        var minNeutralityCandidate: (neutrality: Double, content: String) = (neutrality: 100.0, content: sampleSpace[0]) // holds information on the textual content and the neutrality of the sample with the minimum neutrality, as well as what that minimun neutrality is
        var candidatesExamined = 1 // number of candidate samples examined
        //print("---")
        for candidate in sampleSpace {
            if !sampleCat2.contains(candidate) && !sampleCat1.contains(candidate) { // doesn't examine samples that have already been shown
                let neutrality = findAvgNeutrality(sample: candidate, sampleCat1: sampleCat1, sampleCat2: sampleCat2) // finds the neutrality of a particular sample
                neutralitySum += neutrality
                neutralitySumSQ += neutrality*neutrality
                let neutralityAvg = neutralitySum/Double(candidatesExamined) // running average of neutrality
                let neutralityStDev = sqrt((neutralitySumSQ-2*neutralityAvg*neutralitySum)/Double(candidatesExamined)+(neutralityAvg*neutralityAvg)) // running standard deviation of neutrality
                
                if (neutrality<minNeutralityCandidate.neutrality) { // evaluates whether the current sample has the minimum neutrality so far
                    minNeutralityCandidate = (neutrality: neutrality, candidate)
                }
                if (minNeutralityCandidate.neutrality-neutralityAvg)/(neutralityStDev/sqrt(Double(candidatesExamined))) <= -1.64 { // evaluates if the current minimum neutrality sample lies outside of the 95% one-sided confidence interval on the neutrality of samples, assuming neutrality is normally distributed. Essentially, finds whether the odds of finding an even lower sample in the space is under 5%
                    return minNeutralityCandidate.content // returns the lowest neutrality sample encountered so far and stops iterating through list
                }
                candidatesExamined += 1
            }
        }
        if (candidatesExamined==1) { // if all samples have been swiped on already, just pick a random candidate
            return sampleSpace.randomElement()!
        }
        return minNeutralityCandidate.content // if all samples had to be examined, return minimum neutrality candidate so far.
    }
    
    /**
    findAvgNeutrality
     
     finds the difference in the average distance for a sample between two different categories. A lower score indicates more neutrality.  A random sample is used to improve performace. A modified cosine distance is used that favors longer samples with more total semantic information. This is to show users samples that have more to look at and evaluate first.
     */
    
    private func findAvgNeutrality(sample: String, sampleCat1: [String], sampleCat2: [String]) -> Double {
        var sampleDistance1 = 0.0
        for _ in 1...min(sampleCat1.count,20) { // limits the number of investigated samples to 20
            let testSample = sampleCat1.randomElement()!
            sampleDistance1 += embedding.distance(between: testSample, and: sample, distanceType: .cosine)/Double(testSample.countOccurancesOf(char: " ")) // divides distance by length in words (approximated by count of spaces for speed purposes) to favor longer samples
        }
        sampleDistance1 /= Double(sampleCat1.count) // divides by count to get average sample distance
        
        var sampleDistance2 = 0.0
        for _ in 1...min(sampleCat2.count,20) { // limits the number of investigated samples to 20
            let testSample = sampleCat1.randomElement()!
            sampleDistance2 += embedding.distance(between: testSample, and: sample, distanceType: .cosine)/Double(testSample.countOccurancesOf(char: " ")) // divides distance by length in words (approximated by count of spaces for speed purposes) to favor longer samples
        }
        sampleDistance2 /= Double(sampleCat2.count) // divides by count to get average sample distance
        
        return abs(sampleDistance1-sampleDistance2)
    }
}

extension String {  // extends string so that occurances of a character can be counted for the space-counting system in findAvgNeutrality
    func countOccurancesOf(char: Character) -> Int {
        return self.filter { $0 == char }.count
    }
}
