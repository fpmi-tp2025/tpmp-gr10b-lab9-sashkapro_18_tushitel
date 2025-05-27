import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if isRegistering {
                Button("Register") {
                    DatabaseManager.shared.insertUser(username: username, password: password)
                    isLoggedIn = true
                }
            } else {
                Button("Login") {
                    if DatabaseManager.shared.validateUser(username: username, password: password) {
                        isLoggedIn = true
                    }
                }
            }

            Button(isRegistering ? "Already have an account?" : "Create new account") {
                isRegistering.toggle()
            }
        }
        .padding()
    }
}
