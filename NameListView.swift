import Foundation
import SwiftUI

/**
 NameListView
 
 A view that displays all the names that the user has entered as a list. The currently selected name is shown at the top, followed by  a list of all names. At the bottom of the list there is a button to add a name to the list. Each name can be favorited with a star button, and names other than the current one can be deleted. Names can be swapped with the current one by tapping on them.
 */
struct NameListView: View {
    @Binding var currentName: NameInfo          // Stores the currently used name
    @ObservedObject var model: NameListModel    // Stores a model of all the other info used to create this view

    var body: some View {
        VStack {
            List {     // The main name list
                Section ("Current Name:") {
                    HStack(spacing: 20) {   //Information about the current name
                        
                        Text(currentName.name+" ("+currentName.getPronounChain()+")")
                        
                        Spacer()
                        
                        Button { // Favorite button
                            currentName.isFavorite.toggle()
                        } label: {
                            Image(systemName: currentName.isFavorite ? "star.fill" : "star")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.accentColor)
                                .frame(minWidth: 10, idealWidth: 20, maxWidth: 20, minHeight: 10, idealHeight: 15, maxHeight: 20, alignment: .trailing)
                        }.buttonStyle(PlainButtonStyle())
                         
                    }
                }
                
                Section ("Other Names:") { // Info about all other names
                    ForEach(0..<model.nameInfoList.count, id: \.self) {i in // iterate over range of indexes and not names to be able to ID names by their index later when they need to be favorited/deleted
                        let nameInfoEntry = model.nameInfoList[i]
                        HStack(spacing: 20) { // Info about the name is arranged horizontally
                            Button { // The name and pronouns are displayed as a button, when pressed it swaps the name with the current one
                                let currentNameHold = currentName
                                currentName = model.nameInfoList[i]
                                model.nameInfoList.remove(at: i)
                                model.nameInfoList.insert(currentNameHold, at: i)
                                let encoder = JSONEncoder()
                                do {
                                    let nameData = try encoder.encode(currentName)
                                    UserDefaults.standard.setValue(nameData, forKey: DefaultKeys.currentName)

                                    print("Current name saved successfully!")
                                    print("name saved: \(try JSONDecoder().decode(NameInfo.self, from: UserDefaults.standard.data(forKey: DefaultKeys.currentName)!).name)")
                                } catch {
                                    print("Can't encode current name data!")
                                }
                                model.saveModel()
                                
                            } label: {
                                Text(nameInfoEntry.name+" ("+nameInfoEntry.getPronounChain()+")")
                            }
                            Spacer()
                            
                            Button { // Favorite name button
                                model.toggleFavoriteOn(idx: i)
                            } label: {
                                Image(systemName: nameInfoEntry.isFavorite ? "star.fill" : "star")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.accentColor)
                                    .frame(minWidth: 10, idealWidth: 20, maxWidth: 20, minHeight: 10, idealHeight: 15, maxHeight: 20, alignment: .trailing)
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button { // Delete name button
                                model.removeNameInfoEntry(idx: i)
                            } label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.red) // RED to warn user
                                    .frame( minHeight: 10, idealHeight: 15, maxHeight: 20, alignment: .trailing)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Button { // Button to add name
                    model.showingSheet.toggle() // Shows the GetPersonalInfoView sheet
                    model.sheetMessageText = "How would you like to be called?" // This sheet has a different name the first time it is shown so after it is shown for the first time, the message gets set to this
                    model.sheetFirstTime = false
                } label: {
                    HStack {
                        Spacer()
                    
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .frame(minWidth: 30, idealWidth: 40, maxWidth: 50, minHeight: 30, idealHeight: 40, maxHeight: 50, alignment: .center)
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                }.sheet(isPresented: $model.showingSheet) { // attach the getPersonalInfo sheet
                    GetPersonalInfoView(currentName: $currentName, nameListModel: model)
                }
            }
        }
    }
}


/**
 NameListModel
 
 Holds the information for the NameListView, including the actual list of names, whether the sheet should be showing, and what the sheet should say. This particular data is encapsulated so it can be passed to the GetPersonalInfoView which also needs to use it.
 */

class NameListModel: ObservableObject {
    @Published var nameInfoList: [NameInfo] = []    // List of enterred names and name infos
    @Published var showingSheet = true              // Whether the GetPersonalInfoView sheet is being shown
    var sheetMessageText = "Hi there 😄! Please enter some info on how you'd like to be called:" // Message for the attached sheet
    var sheetFirstTime = true                       // Whether it's the first time the sheet is being shown
    
    init(_ innameInfoList: [NameInfo], _ inshowingSheet: Bool, _ insheetMessageText: String, _ insheetFirstTime: Bool) {
        nameInfoList = innameInfoList
        showingSheet = inshowingSheet
        sheetMessageText = insheetMessageText
        sheetFirstTime = insheetFirstTime
    }
    init(_ nmlStruct: NameListModelStruct) {
        nameInfoList = nmlStruct.nameInfoList
        showingSheet = nmlStruct.showingSheet
        sheetMessageText = nmlStruct.sheetMessageText
        sheetFirstTime = nmlStruct.sheetFirstTime
    }
    init() {}
    
    func toggleFavoriteOn(idx: Int) -> Void {       // Toggle whether a particular entry in the name list is a favorite
        nameInfoList[idx].toggleFavorite()
        saveModel()
    }
    func removeNameInfoEntry(idx: Int) -> Void {    // Remove a particular name from the list
        nameInfoList.remove(at: idx)
        saveModel()
    }
    func addNameInfo(nameInfo: NameInfo) -> Void {  // Add a name to the list
        nameInfoList.append(nameInfo)
        saveModel()
    }
    
    func toNameListModelStruct() -> NameListModelStruct {
        return NameListModelStruct(nameInfoList, showingSheet, sheetMessageText, sheetFirstTime)
    }
    
    func saveModel() -> Void {
        let encoder = JSONEncoder()
        
        do {
            let modelData = try encoder.encode(self.toNameListModelStruct())
            DispatchQueue.main.async {

                UserDefaults.standard.setValue(modelData, forKey: DefaultKeys.nameListModelStruct)
            }

            print("Data saved successfully!")
        } catch {
            print("Can't encode model data!")
        }
        
    }
}

struct NameListModelStruct: Codable {
    var nameInfoList: [NameInfo] = []    // List of enterred names and name infos
    var showingSheet = true              // Whether the GetPersonalInfoView sheet is being shown
    var sheetMessageText = "Hi there 😄! Please enter some info on how you'd like to be called:" // Message for the attached sheet
    var sheetFirstTime = true                       // Whether it's the first time the sheet is being shown
    
    init() {}
    
    init(_ innameInfoList: [NameInfo], _ inshowingSheet: Bool, _ insheetMessageText: String, _ insheetFirstTime: Bool) {
        nameInfoList = innameInfoList
        showingSheet = inshowingSheet
        sheetMessageText = insheetMessageText
        sheetFirstTime = insheetFirstTime
    }
    
    func toNameListModel() -> NameListModel {
        return NameListModel(nameInfoList, showingSheet, sheetMessageText, sheetFirstTime)
    }
}
