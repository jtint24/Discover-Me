import SwiftUI

/**
 MyApp
 
 Controls the views for the app, which are housed in a simple TabView.
 */

@main
struct MyApp: App {
    @State var currentName =  NameInfo(name: "", subjectivePronoun: "", objectivePronoun: "", possessivePronoun: "")
    var nameListModelToUse = NameListModel()
    init() {
        nameListModelToUse = UserDefaults.standard.object(forKey: "nameListModel") as! NameListModel
        currentName = UserDefaults.standard.object(forKey: "NameList") as! NameInfo
        
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
            TabView {
                NameListView(currentName: $currentName, model: nameListModelToUse) // the screen for enterring names and seeing the name list
                    .tabItem {
                        Label("Name List", systemImage: "list.dash")
                    }
                TestView(currentName: $currentName)     // the screen for testing pronouns and names
                    .tabItem {
                        Label("Test Names", systemImage: "capsule.fill")
                    }
            }
        }
    }
}
