import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PKMCollectionApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var expansionStore = ExpansionStore()
    @StateObject var ownedCardsStore = OwnedCardsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(expansionStore)
            .environmentObject(ownedCardsStore)
        }
    }
}
