//
//  ViewController.swift
//  WeatherApp
//
//  Created by DWIJEN RATHOD on 2022-12-04.
//
import CoreLocation
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var MapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var c = ""
    var f = ""
    var temperature:Float = 0.0
    var condition = ""
    var latitude = 0.0
    var longitude = 0.0
    var code = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        addAnnotation(location: CLLocation(latitude: latitude, longitude: longitude))
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            loadWeather(search: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            setupMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error:: \(error.localizedDescription)")
       }
    

    
    private func setupMap(){
        MapView.delegate = self
        
        
        let location = CLLocation(latitude: latitude, longitude:longitude)
        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeters,
                                        longitudinalMeters: radiusInMeters)
        MapView.setRegion(region, animated: true)
        
    }
    
    private func addAnnotation(location: CLLocation){

        let annotation = MyAnnotation(coordinate: location.coordinate, title: "\(temperature) ℃" , subtitle: condition  )

        MapView.addAnnotation(annotation)
    }

    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        guard let url = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call complete")
            
            guard error == nil else{
                print("Received error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.temp_f)
                
                DispatchQueue.main.async {
                    
//                    self.locationLabel.text = weatherResponse.location.name
                    
                    self.c = "\(weatherResponse.current.temp_c)C"
                    self.f = "\(weatherResponse.current.temp_f)F"

                    self.temperature = weatherResponse.current.temp_c
                    self.condition = "\(weatherResponse.current.condition.text)"
                    self.addAnnotation(location: CLLocation(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon))
                    self.longitude = weatherResponse.location.lon
                    self.latitude = weatherResponse.location.lat
                    
                    self.code = weatherResponse.current.condition.code

                    
                    
                }
            
            }
    
        }
        dataTask.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "what is this"
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        
//        let image = UIImage()
        view.leftCalloutAccessoryView = UIImageView(image: showImage(code: code))
        view.markerTintColor = UIColor.blue
       
        
        func showImage(code: Int)->UIImage
        {
            switch code{
            case 1000:
                return UIImage(systemName: "sun.max.fill")!
            case 1003:
                return UIImage(systemName: "cloud.sun.fill")!
            case 1006:
                return UIImage(systemName: "cloud.fill")!
            case 1009:
                return UIImage(systemName: "cloud.circle")!
            case 1030:
                return UIImage(systemName: "smoke.fill")!
            case 1063:
                return UIImage(systemName: "cloud.drizzle")!
            case 1066:
                return UIImage(systemName: "cloud.snow")!
            case 1069:
                return UIImage(systemName: "cloud.sleet")!
            case 1072:
                return UIImage(systemName: "cloud.sleet.fill")!
            case 1087:
                return UIImage(systemName: "cloud.bolt")!
            case 1114:
                return UIImage(systemName: "wind.snow")!
            case 1117:
                return UIImage(systemName: "snowflake")!
            case 1135:
                return UIImage(systemName: "cloud.fog")!
            
            
                
            default:
                print("default")
                return UIImage(systemName: "graduationcap.circle.fill")!
            }
        }
        
        
        view.calloutOffset = CGPoint(x: 0, y: 10)
        //button on right
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button
        
        //image on right
        
        
        
        //color change
            
            if(temperature < 0 )
            {
                view.markerTintColor = UIColor.systemPurple
            }
            else if(temperature > 0 && temperature < 12){
                view.markerTintColor = UIColor.systemBlue
            }
            else if(temperature > 11 && temperature < 16){
                view.markerTintColor = UIColor.blue
            }
            else if(temperature > 15 && temperature < 25){
                view.markerTintColor = UIColor.systemOrange
            }
            else if(temperature > 24 && temperature < 31){
                view.markerTintColor = UIColor.systemRed
            }
            else if(temperature > 31){
                view.markerTintColor = UIColor.red
            }
            else{
                print("else")
            }
        
//        view.markerTintColor = UIColor.blue
        
        
        return view
    }
    
    
    
    private func getURL(query: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "2f4eb87413c94545b78154812220512"
        
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
           return nil
        }
        print(url)
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch{
            print("Error decoding")
        }
        return weather
    }
    

}


class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }


}



struct WeatherResponse: Decodable{
    let location: Location
    let current: Current
    
}

struct Location: Decodable{
    let name: String
    let lat: Double
    let lon: Double
}

struct Current : Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: Condition
}

struct Condition: Decodable{
    let text: String
    let code: Int
}

