import SwiftUI

struct RestaurantListView: View {
    @State private var restaurants: [Restaurant] = []
    @State private var selectedCategory: String?
    
    let categories = ["Все", "Суши", "Пицца", "Бургеры", "Азиатская кухня"]
    
    var filteredRestaurants: [Restaurant] {
        guard let category = selectedCategory, category != "Все" else {
            return restaurants
        }
        return restaurants.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
                
                List(filteredRestaurants) { restaurant in
                    NavigationLink(destination: MenuView(restaurant: restaurant)) {
                        VStack(alignment: .leading) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Рестораны")
            .onAppear {
                loadRestaurants()
            }
        }
    }
    
    private func loadRestaurants() {
        let loaded = DatabaseManager.shared.fetchRestaurants()
        restaurants = loaded
    }
}
