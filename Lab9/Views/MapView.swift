import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D?) -> Void)?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion?(locations.first?.coordinate)
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2)
    }
}

struct MapView: View {
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.9, longitude: 27.5667),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var restaurants: [Restaurant] = []
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var selectedRestaurant: Restaurant?
    @State private var selectedCategory: String? = nil
    @State private var showLocationAlert = false
    @State private var showMenu = false
    @State private var menuRestaurant: Restaurant? = nil
    @ObservedObject private var locationManager = LocationManager.shared
    
    var body: some View {
        VStack {
            Picker("Категория", selection: $selectedCategory) {
                Text("Все").tag(String?.none)
                ForEach(Array(Set(restaurants.map { $0.category })), id: \.self) { category in
                    Text(category).tag(String?.some(category))
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            ZStack {
                Map(position: $cameraPosition) {
                    ForEach(filteredRestaurants) { restaurant in
                        Annotation(restaurant.name, coordinate: restaurant.coordinate) {
                            Button(action: {
                                withAnimation {
                                    selectedRestaurant = restaurant
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: restaurant.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    ))
                                }
                            }) {
                                Image(systemName: selectedRestaurant?.id == restaurant.id ? "mappin.circle.fill" : "mappin.circle")
                                    .foregroundColor(selectedRestaurant?.id == restaurant.id ? .blue : .red)
                                    .font(.title)
                                    .scaleEffect(selectedRestaurant?.id == restaurant.id ? 1.3 : 1.0)
                                    .shadow(radius: selectedRestaurant?.id == restaurant.id ? 8 : 0)
                            }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    loadRestaurants()
                    LocationManager.shared.requestLocation { location in
                        userLocation = location
                        if location == nil {
                            showLocationAlert = true
                        }
                        if let location = location, let nearest = nearestRestaurant(from: location, category: selectedCategory) {
                            withAnimation {
                                selectedRestaurant = nearest
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: nearest.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                ))
                            }
                        }
                    }
                }
                .onChange(of: selectedCategory) { newCategory in
                    if let location = userLocation, let nearest = nearestRestaurant(from: location, category: newCategory) {
                        withAnimation {
                            selectedRestaurant = nearest
                            cameraPosition = .region(MKCoordinateRegion(
                                center: nearest.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                    }
                }
                .alert(isPresented: $showLocationAlert) {
                    Alert(title: Text("Нет доступа к геолокации"), message: Text("Разрешите доступ к местоположению в настройках, чтобы видеть ближайшие рестораны."), dismissButton: .default(Text("OK")))
                }
                
                if let restaurant = selectedRestaurant {
                    VStack {
                        Spacer()
                        RestaurantCard(restaurant: restaurant, onMenu: {
                            menuRestaurant = restaurant
                            showMenu = true
                        })
                        .padding(.bottom)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .sheet(isPresented: $showMenu) {
                if let menuRestaurant = menuRestaurant {
                    MenuView(restaurant: menuRestaurant)
                }
            }
        }
    }
    
    private var filteredRestaurants: [Restaurant] {
        guard let category = selectedCategory else { return restaurants }
        return restaurants.filter { $0.category == category }
    }
    
    private func loadRestaurants() {
        restaurants = DatabaseManager.shared.fetchRestaurants()
    }
    
    private func nearestRestaurant(from location: CLLocationCoordinate2D, category: String?) -> Restaurant? {
        let filtered = category == nil ? restaurants : restaurants.filter { $0.category == category }
        guard !filtered.isEmpty else { return nil }
        return filtered.min(by: {
            $0.location.distance(to: location) < $1.location.distance(to: location)
        })
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    var onMenu: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(restaurant.name)
                .font(.title2)
                .bold()
            Text(restaurant.category)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button(action: {
                onMenu?()
            }) {
                Text("Открыть меню")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}
