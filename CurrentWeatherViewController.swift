import UIKit
import CoreData
import SwiftHTTP

class CurrentWeatherViewController: UIViewController {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context : NSManagedObjectContext? = nil
    var locationName: String? = nil
    var lat: String? = nil
    var lon: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.context = appDel.managedObjectContext!
        
        // Load the current latest one
        self.loadWeather()
        
        // Grab location name from settings
        locationName = NSUserDefaults.standardUserDefaults().stringForKey("loc_name_preference")
        
        // Grab lat and long from settings
        lat = NSUserDefaults.standardUserDefaults().stringForKey("loc_lat_preference")
        lon = NSUserDefaults.standardUserDefaults().stringForKey("loc_lon_preference")
        
        // Load latest weather of current location (name)
        // This always fetches, even without sync on
        self.fetchAndStoreWeatherData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchAndStoreWeatherData() {
        var request = HTTPTask()
        request.GET("http://178.62.153.139/api/weather?lat="+lat!+"&lon="+lon!, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                println("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            if let data = response.responseObject as? NSData {
                let records = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
                if records.count > 0 {
                    self.storeWeatherRecords(records)
                }
            }
        })
    }
    
    // Store weather data in local storage
    private func storeWeatherRecords(records: NSArray) {
        for weatherRecord in records {
            var dateString:String = weatherRecord["dt"] as! String
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var dateFromString = dateFormatter.dateFromString(dateString)
            
            if (!self.doesRecordExistsInCoreData(dateFromString!)) {
                var newWeather: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Weather", inManagedObjectContext: self.context!) as! NSManagedObject
                
                newWeather.setValue(locationName, forKey: "name")
                newWeather.setValue(weatherRecord["lat"], forKey: "lat")
                newWeather.setValue(weatherRecord["lon"], forKey: "lon")
                newWeather.setValue(weatherRecord["type"], forKey: "type")
                newWeather.setValue(weatherRecord["temp"]!!.doubleValue, forKey: "temperature")
                newWeather.setValue(dateFromString, forKey: "dt")
                
                self.context!.save(nil)
                // Add the net items to the ManagedObjects
                self.loadWeather()
            }
            // This actually doesn't do anything, my webservice already handles storing the weather when retrieving it.
            // Just kinda showing that I understand how it works
            var request = HTTPTask()
            request.POST("http://178.62.153.139/api/weather", parameters: weatherRecord as? Dictionary<String, AnyObject>, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let data = response.responseObject as? NSData{
                    let records: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    // Just to show that the data is really being send to my webservice and that is in proper to handle if was needed
                    println("response after storing")
                    print(records)
                }
            })
            
        }
    }
    
    // Grab the latest
    private func loadWeather() {
        self.context = self.appDel.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Weather")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dt", ascending: false)]
        fetchRequest.fetchLimit = 1
        let predicate = NSPredicate(format: "name != nil")
        fetchRequest.predicate = predicate
        let fetchedResults = self.context!.executeFetchRequest(fetchRequest, error: nil) as! [Weather]
        
        let result = fetchedResults.first!
        
        typeLabel.text = result.type
        temperatureLabel.text = "°C"+toString(result.temperature.intValue)
    }
    
    private func doesRecordExistsInCoreData(dt: NSDate) -> Bool {
        let request = NSFetchRequest(entityName: "Weather")
        let predicate = NSPredicate(format: "dt == %@", dt)
        request.predicate = predicate
        
        var count = self.context!.countForFetchRequest(request, error: nil) as NSInteger
        
        return (count != 0);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
