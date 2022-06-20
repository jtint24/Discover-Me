import Foundation
import SwiftUI

/**
 TestView
 
 The view where the user is shown different samples with their pronouns and name inserted, and can swipe to determine if they like or dislike them. Right swipes are positive and left swipes are negative, Tinder-style. Additionally, an accept and reject button is shown underneath the sample, which when tapped do the same thing as swiping. The accept button is on the right and the reject is on the left. These buttons are there to allow users a faster, less involved, way to go through the samples, and their presence helps visually remind the user which direction indicates which sentiment. Between these buttons is the ratio of how many times the user has swiped positively versus negatively for a particular, to show them their overall affinity towards a particular name and pronoun set. At the top is the currently tested name with a favorite button, so the user knows what name they're on and can favorite it from the testing screen. At the bottom is a box to change the context of the samples (eg. from a casual setting to an academic setting) which help the user try out different environments for the pronoun set.
 
 */

struct TestView: View {
    @Binding var currentName: NameInfo                                          // Currently tested name
    @State var cardSwipe: Double = 0                                            // The sample card's swipe x position
    @State var selection: String = "Casual"                                     // Selected context
    @State var shownSample: String = "Hi there, ;name, it's nice to meet you!"  // Currently shown sample
    let generator = UIImpactFeedbackGenerator(style: .medium)                   // Haptic generator for feedback after swipe
    var textSorter: TextSorter = TextSorter()                                   // A sorter struct to optimize what names are shown to them
    let contexts = ["Casual", "Academic", "Professional"]                       // The list of contexts
    
    var body: some View {
        VStack {    //Elements are stacked vertically
            Spacer()
            HStack {    //Name and favorite button are shown alongside each other horizontally
                Spacer()
                Text(currentName.name)
                    .font(.title)
                Button {    // Favorite button
                    currentName.isFavorite.toggle()
                } label: {
                    Image(systemName: currentName.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.accentColor)
                }
                Spacer()
            }
            Text(PronounReplacer.replace(sample: shownSample, from: currentName))   // The sample text. The pronoun replacer is applied here so that when the pronoun set is changed, the sample is automatically updated right away.
                .multilineTextAlignment(.center)
                .padding()
                .frame(minWidth: 100, idealWidth: 700, maxWidth: 800, minHeight: 70, idealHeight: 500, maxHeight: 600, alignment: .center)
                .background(    // BG is a rounded rectangle to look like a flashcard
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .shadow(radius: 10)
                ).padding()
                .rotation3DEffect(.degrees(cardSwipe/3.0), axis: (x: 0, y: 1, z: 0)) // Gives a 3D rotation effect to the sample card as it's swiped
                .offset(x: cardSwipe)       // The text follows horizontal swipes
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            cardSwipe = value.translation.width // Recognize changes in swipe distance
                        }.onEnded({ value in                    // Recognize when a swipe has been completed
                            if (value.translation.width > 100) {
                                acceptText()
                            }
                            if (value.translation.width < -100) {
                                rejectText()
                            }
                            cardSwipe = 0
                        })
                )
            HStack {
                Spacer()
                
                Image(systemName: "x.circle.fill")     // Rejection button
                    .resizable()
                    .scaleEffect(x: 0.5-cardSwipe/1000.0, y: 0.5-cardSwipe/1000.0, anchor: .center)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.red)
                    .frame(minHeight: 30, idealHeight: 30, maxHeight: 100)
                    .padding()
                    .opacity(1-abs(cardSwipe/1000.0))
                    .gesture(
                        TapGesture().onEnded({ value in
                            rejectText()
                        })
                    )
                
                
                
                Spacer()
                
                Text("\(currentName.getSwipeRatio())% Ratio")
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")   // Acceptance button
                    .resizable()
                    .scaleEffect(x: 0.5+cardSwipe/1000.0, y: 0.5+cardSwipe/1000.0, anchor: .center)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
                    .frame(minHeight: 30, idealHeight: 30, maxHeight: 100)
                    .padding()
                    .opacity(1-abs(cardSwipe/1000.0))
                    .gesture(
                        TapGesture().onEnded({ value in
                            acceptText()
                        })
                    )
                
                Spacer()
                
            }
            HStack {        // Context selector
                Spacer()
                Text("Current Context:")
                    .font(.title2)
                Spacer()
                Menu {
                    Picker("---", selection: $selection) {
                        ForEach(contexts, id: \.self) { context in
                            Text(context)
                                .font(.title2)
                        }
                    }
                } label: {
                    Text(selection)
                        .font(.title2)
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(.white)
            )
            .padding()
            Spacer()
        }.background(Color(.systemGray6)) // Grey background to match the BG of listPicker
    }
    func rejectText() -> Void {
        currentName.negativeSwipes+=1
        currentName.rejectedSamples.append(shownSample)
        let pluralityGetter = currentName.subjectivePronoun=="they" ? Samples.getPlural : Samples.getSingular
        let sampleSpace: [(String, String)] = {
            switch selection {
                case "Academic" : return Samples.academic
                case "Casual" : return Samples.casual
                case "Professional" : return Samples.professional
                default: return Samples.casual
            }
        }()
        shownSample = textSorter.findNextTextSample(sampleSpace: pluralityGetter(sampleSpace), currentName: currentName)
        generator.impactOccurred()
        let encoder = JSONEncoder()
        do {
            let nameData = try encoder.encode(currentName)
            UserDefaults.standard.setValue(nameData, forKey: DefaultKeys.currentName)

            print("Current name saved successfully!")
            print("name saved: \(try JSONDecoder().decode(NameInfo.self, from: UserDefaults.standard.data(forKey: DefaultKeys.currentName)!).name)")
        } catch {
            print("Can't encode current name data!")
        }
    }
    func acceptText() -> Void {
        currentName.positiveSwipes+=1
        currentName.acceptedSamples.append(shownSample)
        let pluralityGetter = currentName.subjectivePronoun=="they" ? Samples.getPlural : Samples.getSingular
        let sampleSpace: [(String, String)] = {
            switch selection {
                case "Academic" : return Samples.academic
                case "Casual" : return Samples.casual
                case "Professional" : return Samples.professional
                default: return Samples.casual
            }
        }()
        shownSample = textSorter.findNextTextSample(sampleSpace: pluralityGetter(sampleSpace), currentName: currentName)
        generator.impactOccurred()
        let encoder = JSONEncoder()
        do {
            let nameData = try encoder.encode(currentName)
            UserDefaults.standard.setValue(nameData, forKey: DefaultKeys.currentName)

            print("Current name saved successfully!")
            print("name saved: \(try JSONDecoder().decode(NameInfo.self, from: UserDefaults.standard.data(forKey: DefaultKeys.currentName)!).name)")
        } catch {
            print("Can't encode current name data!")
        }
    }
}
