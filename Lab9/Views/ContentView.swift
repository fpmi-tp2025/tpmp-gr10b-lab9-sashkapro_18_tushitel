import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainView()
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}
