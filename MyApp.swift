import SwiftUI

/**
 MyApp
 
 Controls the views for the app, which are housed in a simple TabView.
 */

@main
struct MyApp: App {
    @State var currentName: NameInfo = NameInfo(name: "nully", subjectivePronoun: "nully", objectivePronoun: "nully", possessivePronoun: "nully")
    var nameListModelToUse = NameListModelStruct()
    init() {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        do {
            UserDefaults.standard.register(defaults: [
                DefaultKeys.currentName: try encoder.encode(NameInfo(name: "", subjectivePronoun: "", objectivePronoun: "", possessivePronoun: "")),
                DefaultKeys.nameListModelStruct: try encoder.encode(NameListModelStruct())
            ])
        } catch {
            print("can't set defaults!")
        }
        print("app initialized!")
        
        if let currentNameData = UserDefaults.standard.data(forKey: DefaultKeys.currentName) {
            do {
                //currentName = try decoder.decode(NameInfo.self, from: currentNameData)
                //print("current name info: \(currentName.name) \(currentName.getPronounChain())`")
                print("name info gotten directly: \(try JSONDecoder().decode(NameInfo.self, from: UserDefaults.standard.data(forKey: DefaultKeys.currentName)!).getPronounChain())")
                //_currentName = NameInfo(name: "nully", subjectivePronoun: "nully", objectivePronoun: "nully", possessivePronoun: "nully")
                self._currentName = State(initialValue: try JSONDecoder().decode(NameInfo.self, from: UserDefaults.standard.data(forKey: DefaultKeys.currentName)!))
                //currentName = NameInfo(name: "nully", subjectivePronoun: "nully", objectivePronoun: "nully", possessivePronoun: "nully")
                //print("name info gotten from currentName: \(currentName.name) \(currentName.getPronounChain())`")

            } catch {
                print("Can't decode the current name data!")
            }
        }
        if let nameListData = UserDefaults.standard.data(forKey: DefaultKeys.nameListModelStruct) {
            do {
                nameListModelToUse = try decoder.decode(NameListModelStruct.self, from: nameListData)
                print("name list model info: \(nameListModelToUse.nameInfoList.count)")
            } catch {
                print("Can't decode the name list data!")
            }
        }
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
            TabView {
                NameListView(currentName: $currentName, model: NameListModel(nameListModelToUse)) // the screen for enterring names and seeing the name list
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
