import Foundation

struct Order: Identifiable {
    var id: Int
    var userId: Int
    var restaurantId: Int
    var address: String
    var comment: String
    var payment: String
    var status: String
    var totalPrice: Double
    var items: [OrderItem]
}

struct OrderItem: Identifiable {
    var id: Int
    var orderId: Int
    var dishId: Int
    var quantity: Int
    var price: Double
}
