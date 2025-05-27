import Foundation
import CoreLocation

struct Restaurant: Identifiable {
    var id: Int
    var name: String
    var category: String
    var location: CLLocationCoordinate2D
    
    var coordinate: CLLocationCoordinate2D {
        location
    }
} 