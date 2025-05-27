import SwiftUI

struct OrdersView: View {
    @State private var orders: [Order] = []
    @State private var userId: Int = 1 // TODO: Получать из UserDefaults
    
    var body: some View {
        NavigationView {
            List(orders) { order in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Заказ #\(order.id)")
                            .font(.headline)
                        Spacer()
                        Text(order.status)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Адрес: \(order.address)")
                        .font(.subheadline)
                    
                    if !order.comment.isEmpty {
                        Text("Комментарий: \(order.comment)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Способ оплаты: \(order.payment)")
                        .font(.subheadline)
                    
                    Text("Итого: $\(String(format: "%.2f", order.totalPrice))")
                        .font(.subheadline)
                        .bold()
                    
                    if !order.items.isEmpty {
                        Text("Блюда:")
                            .font(.subheadline)
                            .padding(.top, 4)
                        
                        ForEach(order.items) { item in
                            HStack {
                                Text("• \(item.quantity)x")
                                Text("$\(String(format: "%.2f", item.price))")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Мои заказы")
            .onAppear {
                loadOrders()
            }
        }
    }
    
    private func loadOrders() {
        orders = DatabaseManager.shared.fetchOrders(forUserId: userId)
    }
}
