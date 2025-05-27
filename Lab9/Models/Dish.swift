import Foundation

struct Dish: Identifiable, Hashable {
    var id: Int
    var restaurantId: Int
    var name: String
    var description: String
    var price: Double
} 