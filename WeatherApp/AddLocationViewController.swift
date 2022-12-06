//
//  AddLocationViewController.swift
//  WeatherApp
//
//  Created by DWIJEN RATHOD on 2022-12-05.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var segment: UISegmentedControl!
    var c = ""
    var f = ""
    
    @IBOutlet weak var locationLabel: UILabel!
    var celcius = ""
    var farenheit = ""
    var locationName = ""
    
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        
        locationManager.delegate = self
        
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
//        self.locationName = locationLabel.text!
//        performSegue(withIdentifier: "addLocScreen", sender: self)
        
        
        
        if (locationLabel.text == "Location")
        {
            dismiss(animated: true)
            return
        }
        
        else{
            if let delegate = self.presentingViewController as? ViewController
                    {
                       delegate.loadWeather(search: locationLabel.text!)
                dismiss(animated: true)
                   }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.listName = self.locationName
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        return true
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        if let location = locations.last{
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            
            print(coordinates)
            
//            getURL(query: "(\(latitude),\(longitude))")
            loadWeather(search: coordinates)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print (error)
    }
        
        
    
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        
        
    }
    
    @IBAction func change(_ sender: UISegmentedControl) {
        if(segment.selectedSegmentIndex == 0){
           temperatureLabel.text = c
        }
        else if(segment.selectedSegmentIndex == 1){
            self.temperatureLabel.text = f
        }
        else{
            temperatureLabel.text = c
        }
        
    }
    
    
      func loadWeather(search: String?){
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
                    
                    self.locationLabel.text = weatherResponse.location.name
                    
                    self.c = "\(weatherResponse.current.temp_c)C"
                    self.f = "\(weatherResponse.current.temp_f)F"

                    if(self.segment.selectedSegmentIndex == 0){
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                    }
                    else if(self.segment.selectedSegmentIndex == 1){
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_f)F"
                    }
                    else{
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                    }

                    

                    
                    switch weatherResponse.current.condition.code{
                    case 1000:
                        return self.weatherConditionImage.image = UIImage(systemName: "sun.max.fill")!
                    case 1003:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.sun.fill")!
                    case 1006:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.fill")!
                    case 1009:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.circle")!
                    case 1030:
                        return self.weatherConditionImage.image = UIImage(systemName: "smoke.fill")!
                    case 1063:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")!
                    case 1066:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.snow")!
                    case 1069:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.sleet")!
                    case 1072:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.sleet.fill")!
                    case 1087:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.bolt")!
                    case 1114:
                        return self.weatherConditionImage.image = UIImage(systemName: "wind.snow")!
                    case 1117:
                        return self.weatherConditionImage.image = UIImage(systemName: "snowflake")!
                    case 1135:
                        return self.weatherConditionImage.image = UIImage(systemName: "cloud.fog")!
                    case 1213:
                        return self.weatherConditionImage.image = UIImage(systemName: "snowflake")!
                    
                    
                        
                    default:
                        print("default")
                        return self.weatherConditionImage.image = UIImage(systemName: "graduationcap.circle.fill")!
                    }
                    
                    
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
}




