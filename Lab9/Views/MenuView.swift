import SwiftUI

struct MenuView: View {
    let restaurant: Restaurant
    @State private var dishes: [Dish] = []
    @State private var cart: [Dish: Int] = [:]
    @State private var showingCart = false
    
    var body: some View {
        VStack {
            List {
                ForEach(dishes) { dish in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dish.name)
                                .font(.headline)
                            Text(dish.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("$\(String(format: "%.2f", dish.price))")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if cart[dish] ?? 0 > 0 {
                                    cart[dish]! -= 1
                                    if cart[dish] == 0 {
                                        cart.removeValue(forKey: dish)
                                    }
                                }
                            }) {
                                Image(systemName: "minus.circle")
                            }
                            
                            Text("\(cart[dish] ?? 0)")
                            
                            Button(action: {
                                cart[dish] = (cart[dish] ?? 0) + 1
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                }
            }
            
            if !cart.isEmpty {
                Button(action: {
                    showingCart = true
                }) {
                    Text("Перейти к оформлению заказа")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle(restaurant.name)
        .sheet(isPresented: $showingCart, onDismiss: { cart.removeAll() }) {
            CartView(restaurant: restaurant, cart: $cart)
        }
        .onAppear {
            // Здесь будет загрузка блюд из базы данных
            loadDishes()
        }
    }
    
    private func loadDishes() {
        dishes = DatabaseManager.shared.fetchDishes(forRestaurantId: restaurant.id)
    }
}
