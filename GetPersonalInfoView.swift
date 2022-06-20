import Foundation
import SwiftUI

/**
 GetPersonalInfoView
 
 Gets the user's preferred name and pronouns, This view appears as a sheet over NameListView when the app is first opened and when the user adds a new name  set. When the app is first opened, this sheet cannot be closed without entering information, on subsequent attempts this sheet can be closed by swiping down to cancel out the action.
 */
struct GetPersonalInfoView: View {
    
    @State private var userName: String = ""        // the entered name
    @State private var userSubjPronoun: String = "" // the entered subjective pronoun
    @State private var userObjPronoun: String = ""  // the entered objective pronoun
    @State private var userPossPronoun: String = "" // the entered possessive pronoun
    @State private var showEmptyAlert: Bool = false // whether the alert for having an unfilled field is shown
    @Binding var currentName: NameInfo              // the user's currently selected name
    
    var nameListModel: NameListModel
    
    var body: some View {
        if nameListModel.sheetFirstTime { // show's the app's logo on the first time as it is the splash screen
            Image("discovermelogo")
                .resizable()
                .multilineTextAlignment(.center)
                .scaledToFit()
                .scaleEffect(x: 0.9, y: 0.9)
        }
        VStack{
            Text(nameListModel.sheetMessageText)    // shows message text
                .frame(minWidth: 100, idealWidth: 300, maxWidth: 300)
                .multilineTextAlignment(.center)
            TextField("Your name?",
                      text: $userName
            ).frame(minWidth: 100, idealWidth: 200, maxWidth: 300)
                .multilineTextAlignment(.center)
            TextField("Your subjective pronoun? (like they)",
                      text: $userSubjPronoun
            ).frame(minWidth: 100, idealWidth: 200, maxWidth: 300)
                .multilineTextAlignment(.center)
                .autocapitalization(.none) // pronouns aren't capitalized so it isn't forced
                .submitLabel(.continue)
                .onSubmit {
                    setSuggestedPronouns(pronoun: userSubjPronoun, enterredIn: 0)
                }
            TextField("Your objective pronoun? (like him)",
                      text: $userObjPronoun
            ).frame(minWidth: 100, idealWidth: 200, maxWidth: 300)
                .multilineTextAlignment(.center)
                .autocapitalization(.none) // pronouns aren't capitalized so it isn't forced
                .submitLabel(.continue)
                .onSubmit {
                    setSuggestedPronouns(pronoun: userObjPronoun, enterredIn: 1)
                }
            TextField("Your possessive pronoun? (like her)",
                      text: $userPossPronoun
            ).frame(minWidth: 100, idealWidth: 200, maxWidth: 300)
                .multilineTextAlignment(.center)
                .autocapitalization(.none) // pronouns aren't capitalized so it isn't forced
                .submitLabel(.continue)
                .onSubmit {
                    setSuggestedPronouns(pronoun: userPossPronoun, enterredIn: 2)
                }
            Button(nameListModel.sheetFirstTime ? "Continue" : "Add", action: addName)
                .accessibilityLabel(nameListModel.sheetFirstTime ? "Continue" : "Add")
                .buttonStyle(.bordered)
                .alert("Please enter something in all of the fields!", isPresented: $showEmptyAlert) { // show an alert if a user tries to continue without filling in all the fields
                    Button {
                        showEmptyAlert = false;
                    } label: {
                        Text("OK")
                    }
                }
        }.padding()
            .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(#colorLiteral(red: 0.42*1.5, green: 0.24*1.5, blue: 0.562*1.5, alpha: 1)), lineWidth: 4)
                .frame(minWidth: 350, idealWidth: 700, maxWidth: 800, alignment: .center)
        ).interactiveDismissDisabled(nameListModel.sheetFirstTime)
    }
    func addName() -> Void {
        setSuggestedPronouns(pronoun: userSubjPronoun, enterredIn: 0)
        setSuggestedPronouns(pronoun: userObjPronoun, enterredIn: 1)
        setSuggestedPronouns(pronoun: userPossPronoun, enterredIn: 2)
        print(userPossPronoun)
        if (userName.isEmpty || userSubjPronoun.isEmpty || userObjPronoun.isEmpty || userPossPronoun.isEmpty) {
            showEmptyAlert = true
            return
        }
        if nameListModel.nameInfoList.count == 0 && currentName.name.isEmpty { // writes directly to the current name if there is no current name selected
            currentName = NameInfo(name: userName.trimmingCharacters(in: .whitespaces), subjectivePronoun: userSubjPronoun.trimmingCharacters(in: .whitespaces), objectivePronoun: userObjPronoun.trimmingCharacters(in: .whitespaces), possessivePronoun: userPossPronoun.trimmingCharacters(in: .whitespaces))
        } else { // simply appends generated name to list
            nameListModel.addNameInfo(nameInfo: NameInfo(name: userName.trimmingCharacters(in: .whitespaces), subjectivePronoun: userSubjPronoun.trimmingCharacters(in: .whitespaces), objectivePronoun: userObjPronoun.trimmingCharacters(in: .whitespaces), possessivePronoun: userPossPronoun.trimmingCharacters(in: .whitespaces)))
        }
        nameListModel.showingSheet = false  // closes the sheet
    }
    func setSuggestedPronouns(pronoun: String, enterredIn: Int) -> Void {
        let pronounSet = [
            ["he", "him", "his"],
            ["she", "her", "her"],
            ["they", "them", "their"],
            ["xe", "xem", "xyr"],
            ["ey", "em", "eir"],
            ["zie", "zim", "zir"],
            ["ve", "ver", "vis"]
        ]
        print("this runs.")
        for pronouns in pronounSet {
            if pronouns[enterredIn] == pronoun {
                print("match found!")
                if !userSubjPronoun.isEmpty {
                    userSubjPronoun = pronouns[0]
                }
                if !userObjPronoun.isEmpty {
                    userObjPronoun = pronouns[1]
                }
                if !userPossPronoun.isEmpty {
                    userPossPronoun = pronouns[2]
                }
            }
        }
        
    }
}
