import UIKit
import CoreLocation

class SettingsViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var autoSync: UISwitch!
    
    let locationManager = CLLocationManager()
    
    @IBAction func onNameChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(locationName.text, forKey: "loc_name_preference")
    }
    
    @IBAction func onLatitudeChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(latitude.text, forKey: "loc_lat_preference")
    }
    
    @IBAction func onLongitudeChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(longitude.text, forKey: "loc_lon_preference")
    }
    
    @IBAction func onGpsClick(sender: AnyObject) {
        locationManager.requestWhenInUseAuthorization()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func onAutoSyncChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(autoSync.on, forKey: "sync_enabled_preference")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        latitude.text = "\(locValue.latitude)"
        longitude.text = "\(locValue.longitude)"

        NSUserDefaults.standardUserDefaults().setValue("\(locValue.latitude)", forKey: "loc_lat_preference")
        NSUserDefaults.standardUserDefaults().setValue("\(locValue.longitude)", forKey: "loc_lon_preference")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Got nothing!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen to changes in the settings
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "defaultsChanged:",
            name: NSUserDefaultsDidChangeNotification,
            object: nil
        )
        
        updateSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func defaultsChanged(notification : NSNotification) {
        updateSettings()
    }
    
    func updateSettings() {
        var location = NSUserDefaults.standardUserDefaults().stringForKey("loc_name_preference")
        var lat = NSUserDefaults.standardUserDefaults().stringForKey("loc_lat_preference")
        var lon = NSUserDefaults.standardUserDefaults().stringForKey("loc_lon_preference")
        var automaticSync = NSUserDefaults.standardUserDefaults().boolForKey("sync_enabled_preference")
        
        locationName.text = location
        latitude.text = lat
        longitude.text = lon
        autoSync.setOn(automaticSync, animated: false)
    }
}