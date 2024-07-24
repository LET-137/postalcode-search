import SwiftUI

@main
struct PostalCodeSearchApp: App {
    @StateObject var postAddress = PostAddress()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(postAddress)
        }
    }
}
