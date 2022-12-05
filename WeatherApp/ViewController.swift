//
//  ViewController.swift
//  WeatherApp
//
//  Created by DWIJEN RATHOD on 2022-12-04.
//
import CoreLocation
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var MapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var c = ""
    var f = ""
    var temperature = ""
    var condition = ""
    var latitude = 0.0
    var longitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        addAnnotation(location: CLLocation(latitude: latitude, longitude: longitude))
        // Do any additional setup after loading the view.
//        addAnnotation(location: )
     
        
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

        let annotation = MyAnnotation(coordinate: location.coordinate, title: temperature , subtitle: condition  )

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

                    self.temperature = "\(weatherResponse.current.temp_c)C"
                    self.condition = "\(weatherResponse.current.condition.text)"
                    self.addAnnotation(location: CLLocation(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon))
                    self.longitude = weatherResponse.location.lon
                    self.latitude = weatherResponse.location.lat

                    
//                    if (weatherResponse.current.condition.code == 1000){
//                        self.weatherConditionImage.image = UIImage(systemName: "sun.min")
//                    }
//                    else if(weatherResponse.current.condition.code == 1003){
//                        self.weatherConditionImage.image = UIImage(systemName: "cloud")
//                    }
//                    else if(weatherResponse.current.condition.code == 1006){
//                        self.weatherConditionImage.image = UIImage(systemName: "cloud.fill")
//                    }
//                    else if(weatherResponse.current.condition.code == 1009){
//                        self.weatherConditionImage.image = UIImage(systemName: "")
//                    }
                    
                    
                }
            
            }
    
        }
        dataTask.resume()
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

extension ViewController: MKMapViewDelegate{
    
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

