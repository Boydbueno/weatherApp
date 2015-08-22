import UIKit
import SwiftHTTP
import CoreData

class HistoryController: UITableViewController {

    var weatherStore = [NSManagedObject]()
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context : NSManagedObjectContext? = nil
    var locationName: String? = nil
    var lat: String? = nil
    var lon: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context = appDel.managedObjectContext!
        
        // Retrieve name of location
        locationName = NSUserDefaults.standardUserDefaults().stringForKey("loc_name_preference")
        
        // Start by loading weather from coreData
        self.loadWeather()
        
        // Grab lat and long from settings
        lat = NSUserDefaults.standardUserDefaults().stringForKey("loc_lat_preference")
        lon = NSUserDefaults.standardUserDefaults().stringForKey("loc_lon_preference")
        
        // Grab auto sync from settings
        let autoSync = NSUserDefaults.standardUserDefaults().boolForKey("sync_enabled_preference")
        
        // If auto sync is true
        if (autoSync) {
            // Retrieve new weather data
            self.fetchAndStoreWeatherData()
            sleep(1)
            self.tableView.reloadData()
        }
        
        // Setup pull to refresh
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.fetchAndStoreWeatherData()
        sleep(1)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Load the last 10 weather reports (from current location)
    // Newest will be first
    private func loadWeather() {
        self.context = self.appDel.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Weather")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dt", ascending: false)]
        fetchRequest.fetchLimit = 10
        let predicate = NSPredicate(format: "name == %@", locationName!)
        fetchRequest.predicate = predicate
        let fetchedResults = self.context!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        if let results = fetchedResults {
            weatherStore = results
        } else {
            println("Could not fetch weather")
        }
    }
    
    private func fetchAndStoreWeatherData() {
        var newWeather: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Weather", inManagedObjectContext: context!) as! NSManagedObject

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
                self.tableView.reloadData()
            }
        }
    }
    
    private func doesRecordExistsInCoreData(dt: NSDate) -> Bool {
        let request = NSFetchRequest(entityName: "Weather")
        let predicate = NSPredicate(format: "dt == %@", dt)
        request.predicate = predicate
        
        var count = self.context!.countForFetchRequest(request, error: nil) as NSInteger

        return (count != 0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherStore.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! WeatherTableViewCell
        
        let weather = weatherStore[indexPath.row]
        cell.setLocationText((weather.valueForKey("name") as? String)!)
        cell.setLatAndLon((weather.valueForKey("lat") as? String)!, lon: (weather.valueForKey("lon") as? String)!)
        cell.setTemperature((weather.valueForKey("temperature") as? Double)!)
        cell.setWeatherType((weather.valueForKey("type") as? String)!)
        cell.setDateTimeText((weather.valueForKey("dt") as? NSDate)!)
        
        return cell
    }
}