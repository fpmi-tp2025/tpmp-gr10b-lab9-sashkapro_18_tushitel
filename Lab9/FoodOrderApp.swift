// FoodOrderApp.swift
import SwiftUI

@main
struct FoodOrderApp: App {
    init() {
        DatabaseManager.shared.createDatabase()
        DatabaseManager.shared.createTables()
        addTestDataIfNeeded()
    }

    private func addTestDataIfNeeded() {
        let restaurants = DatabaseManager.shared.fetchRestaurants()
        if restaurants.isEmpty {
            DatabaseManager.shared.insertRestaurant(name: "Sushi Place", category: "Суши", latitude: 53.9, longitude: 27.5667)
            DatabaseManager.shared.insertRestaurant(name: "Pizza House", category: "Пицца", latitude: 53.91, longitude: 27.57)
            DatabaseManager.shared.insertRestaurant(name: "Burger Town", category: "Бургеры", latitude: 53.92, longitude: 27.58)
            DatabaseManager.shared.insertRestaurant(name: "Asia Wok", category: "Азиатская кухня", latitude: 53.93, longitude: 27.59)
            DatabaseManager.shared.insertRestaurant(name: "Coffee Point", category: "Кофейня", latitude: 53.94, longitude: 27.565)
            DatabaseManager.shared.insertRestaurant(name: "Vegan Life", category: "Вегетарианское", latitude: 53.95, longitude: 27.56)
            DatabaseManager.shared.insertRestaurant(name: "Steak House", category: "Стейки", latitude: 53.96, longitude: 27.55)
        }
        let allRestaurants = DatabaseManager.shared.fetchRestaurants()
        for restaurant in allRestaurants {
            let dishes = DatabaseManager.shared.fetchDishes(forRestaurantId: restaurant.id)
            if dishes.isEmpty {
                switch restaurant.category {
                case "Суши":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Филадельфия", description: "Ролл с лососем и сыром", price: 12.5)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Калифорния", description: "Ролл с крабом и авокадо", price: 11.0)
                case "Пицца":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Маргарита", description: "Пицца с томатами и сыром", price: 9.0)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Пепперони", description: "Пицца с пепперони и сыром", price: 10.5)
                case "Бургеры":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Чизбургер", description: "Бургер с сыром и говядиной", price: 8.0)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Вегги бургер", description: "Бургер с овощами", price: 7.5)
                case "Азиатская кухня":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Лапша удон", description: "Удон с курицей и овощами", price: 10.0)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Том Ям", description: "Острый суп с морепродуктами", price: 13.0)
                case "Кофейня":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Капучино", description: "Кофе с молоком", price: 3.5)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Эклер", description: "Французская выпечка", price: 2.5)
                case "Вегетарианское":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Салат с тофу", description: "Салат с овощами и тофу", price: 7.0)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Смузи", description: "Фруктовый смузи", price: 4.0)
                case "Стейки":
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Рибай", description: "Стейк из мраморной говядины", price: 18.0)
                    DatabaseManager.shared.insertDish(restaurantId: restaurant.id, name: "Стейк из лосося", description: "Лосось на гриле", price: 16.0)
                default:
                    break
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
