import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            RestaurantListView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }

            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}
