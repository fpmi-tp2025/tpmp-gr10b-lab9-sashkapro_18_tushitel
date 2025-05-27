//
//  CartView.swift
//  Lab9
//
//  Created by Артем Гаврилов on 26.05.25.
//

import SwiftUI

struct CartView: View {
    let restaurant: Restaurant
    @Binding var cart: [Dish: Int]
    @State private var address = ""
    @State private var comment = ""
    @State private var selectedPayment = "Онлайн"
    @Environment(\.presentationMode) var presentationMode
    
    let paymentMethods = ["Онлайн", "ЕРИП", "Терминал", "Наличные"]
    
    var total: Double {
        cart.reduce(0) { $0 + ($1.key.price * Double($1.value)) }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ваш заказ")) {
                    ForEach(Array(cart.keys)) { dish in
                        HStack {
                            Text(dish.name)
                            Spacer()
                            Text("x\(cart[dish]!)")
                            Text("$\(String(format: "%.2f", dish.price * Double(cart[dish]!)))")
                        }
                    }
                    
                    HStack {
                        Text("Итого")
                            .font(.headline)
                        Spacer()
                        Text("$\(String(format: "%.2f", total))")
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Адрес доставки")) {
                    TextField("Введите адрес", text: $address)
                }
                
                Section(header: Text("Комментарий к заказу")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
                
                Section(header: Text("Способ оплаты")) {
                    Picker("Выберите способ оплаты", selection: $selectedPayment) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method)
                        }
                    }
                }
                
                Section {
                    Button(action: placeOrder) {
                        Text("Оформить заказ")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Оформление заказа")
            .navigationBarItems(trailing: Button("Закрыть") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func placeOrder() {
        // Получить userId из UserDefaults (или временно использовать 1)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let orderId = DatabaseManager.shared.insertOrder(
            userId: userId == 0 ? 1 : userId,
            restaurantId: restaurant.id,
            address: address,
            comment: comment,
            payment: selectedPayment,
            totalPrice: total
        )
        for (dish, quantity) in cart {
            DatabaseManager.shared.insertOrderItem(orderId: orderId, dishId: dish.id, quantity: quantity, price: dish.price)
        }
        cart.removeAll()
        presentationMode.wrappedValue.dismiss()
    }
}

