import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct PKMCollectionApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var moduleRegistry = AppModuleRegistry()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(moduleRegistry)
                .environmentObject(moduleRegistry.ownedCardsStore)
                .environmentObject(moduleRegistry.wishlistStore)
                .environmentObject(moduleRegistry.deckStore)
                .environmentObject(moduleRegistry.navigator)
        }
    }
}
