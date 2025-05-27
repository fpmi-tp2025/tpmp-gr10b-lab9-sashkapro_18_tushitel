import Foundation
import SQLite3
import CoreLocation

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {}

    func createDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("FoodOrder.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Error opening database")
        }
    }

    func createTables() {
        let createUsers = """
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
        );
        """

        let createRestaurants = """
        CREATE TABLE IF NOT EXISTS Restaurants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            latitude REAL,
            longitude REAL
        );
        """

        let createDishes = """
        CREATE TABLE IF NOT EXISTS Dishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            restaurant_id INTEGER,
            name TEXT,
            description TEXT,
            price REAL,
            FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id)
        );
        """

        let createOrders = """
        CREATE TABLE IF NOT EXISTS Orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            restaurant_id INTEGER,
            address TEXT,
            comment TEXT,
            payment TEXT,
            status TEXT,
            total_price REAL,
            FOREIGN KEY (user_id) REFERENCES Users(id),
            FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id)
        );
        """

        let createOrderItems = """
        CREATE TABLE IF NOT EXISTS OrderItems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER,
            dish_id INTEGER,
            quantity INTEGER,
            price REAL,
            FOREIGN KEY (order_id) REFERENCES Orders(id),
            FOREIGN KEY (dish_id) REFERENCES Dishes(id)
        );
        """

        if sqlite3_exec(db, createUsers, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating Users table")
        }

        if sqlite3_exec(db, createRestaurants, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating Restaurants table")
        }

        if sqlite3_exec(db, createDishes, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating Dishes table")
        }

        if sqlite3_exec(db, createOrders, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating Orders table")
        }

        if sqlite3_exec(db, createOrderItems, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating OrderItems table")
        }
    }

    func insertUser(username: String, password: String) {
        let insert = "INSERT INTO Users (username, password) VALUES (?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, username, -1, nil)
            sqlite3_bind_text(stmt, 2, password, -1, nil)
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func validateUser(username: String, password: String) -> Bool {
        let query = "SELECT * FROM Users WHERE username = ? AND password = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, username, -1, nil)
            sqlite3_bind_text(stmt, 2, password, -1, nil)

            if sqlite3_step(stmt) == SQLITE_ROW {
                sqlite3_finalize(stmt)
                return true
            }
        }

        sqlite3_finalize(stmt)
        return false
    }

    func insertRestaurant(name: String, category: String, latitude: Double, longitude: Double) {
        let insert = "INSERT INTO Restaurants (name, category, latitude, longitude) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, name, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(stmt, 2, category, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_double(stmt, 3, latitude)
            sqlite3_bind_double(stmt, 4, longitude)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func fetchRestaurants() -> [Restaurant] {
        var restaurants = [Restaurant]()
        let query = "SELECT * FROM Restaurants;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let category = String(cString: sqlite3_column_text(stmt, 2))
                let latitude = sqlite3_column_double(stmt, 3)
                let longitude = sqlite3_column_double(stmt, 4)
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                restaurants.append(Restaurant(id: id, name: name, category: category, location: location))
            }
        }

        sqlite3_finalize(stmt)
        return restaurants
    }

    func insertDish(restaurantId: Int, name: String, description: String, price: Double) {
        let insert = "INSERT INTO Dishes (restaurant_id, name, description, price) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(restaurantId))
            sqlite3_bind_text(stmt, 2, name, -1, nil)
            sqlite3_bind_text(stmt, 3, description, -1, nil)
            sqlite3_bind_double(stmt, 4, price)
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func fetchDishes(forRestaurantId restaurantId: Int) -> [Dish] {
        var dishes = [Dish]()
        let query = "SELECT * FROM Dishes WHERE restaurant_id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(restaurantId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let restaurantId = Int(sqlite3_column_int(stmt, 1))
                let name = String(cString: sqlite3_column_text(stmt, 2))
                let description = String(cString: sqlite3_column_text(stmt, 3))
                let price = sqlite3_column_double(stmt, 4)
                
                dishes.append(Dish(id: id, restaurantId: restaurantId, name: name, description: description, price: price))
            }
        }

        sqlite3_finalize(stmt)
        return dishes
    }

    func insertOrder(userId: Int, restaurantId: Int, address: String, comment: String, payment: String, totalPrice: Double) -> Int {
        let insert = "INSERT INTO Orders (user_id, restaurant_id, address, comment, payment, status, total_price) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        var orderId: Int = 0

        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(userId))
            sqlite3_bind_int(stmt, 2, Int32(restaurantId))
            sqlite3_bind_text(stmt, 3, address, -1, nil)
            sqlite3_bind_text(stmt, 4, comment, -1, nil)
            sqlite3_bind_text(stmt, 5, payment, -1, nil)
            sqlite3_bind_text(stmt, 6, "Новый", -1, nil)
            sqlite3_bind_double(stmt, 7, totalPrice)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                orderId = Int(sqlite3_last_insert_rowid(db))
            }
        }

        sqlite3_finalize(stmt)
        return orderId
    }

    func insertOrderItem(orderId: Int, dishId: Int, quantity: Int, price: Double) {
        let insert = "INSERT INTO OrderItems (order_id, dish_id, quantity, price) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(orderId))
            sqlite3_bind_int(stmt, 2, Int32(dishId))
            sqlite3_bind_int(stmt, 3, Int32(quantity))
            sqlite3_bind_double(stmt, 4, price)
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func fetchOrders(forUserId userId: Int) -> [Order] {
        var orders = [Order]()
        let query = """
            SELECT o.*, GROUP_CONCAT(oi.dish_id || ',' || oi.quantity || ',' || oi.price) as items
            FROM Orders o
            LEFT JOIN OrderItems oi ON o.id = oi.order_id
            WHERE o.user_id = ?
            GROUP BY o.id;
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(userId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let userId = Int(sqlite3_column_int(stmt, 1))
                let restaurantId = Int(sqlite3_column_int(stmt, 2))
                let address = String(cString: sqlite3_column_text(stmt, 3))
                let comment = String(cString: sqlite3_column_text(stmt, 4))
                let payment = String(cString: sqlite3_column_text(stmt, 5))
                let status = String(cString: sqlite3_column_text(stmt, 6))
                let totalPrice = sqlite3_column_double(stmt, 7)
                
                var items: [OrderItem] = []
                if let itemsString = sqlite3_column_text(stmt, 8) {
                    let itemsArray = String(cString: itemsString).components(separatedBy: ",")
                    for i in stride(from: 0, to: itemsArray.count, by: 3) {
                        if i + 2 < itemsArray.count {
                            let dishId = Int(itemsArray[i]) ?? 0
                            let quantity = Int(itemsArray[i + 1]) ?? 0
                            let price = Double(itemsArray[i + 2]) ?? 0.0
                            items.append(OrderItem(id: 0, orderId: id, dishId: dishId, quantity: quantity, price: price))
                        }
                    }
                }
                
                orders.append(Order(id: id, userId: userId, restaurantId: restaurantId, address: address, comment: comment, payment: payment, status: status, totalPrice: totalPrice, items: items))
            }
        }

        sqlite3_finalize(stmt)
        return orders
    }
}
