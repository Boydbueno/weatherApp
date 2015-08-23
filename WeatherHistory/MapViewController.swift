import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {
    
    let regionRadius: CLLocationDistance = 1000
    var lat: Double? = nil
    var lon: Double? = nil
    
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context : NSManagedObjectContext? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context = appDel.managedObjectContext!

        lat = NSUserDefaults.standardUserDefaults().doubleForKey("loc_lat_preference")
        lon = NSUserDefaults.standardUserDefaults().doubleForKey("loc_lon_preference")
        
        let initialLocation = CLLocation(latitude: lat!, longitude: lon!)
        
        centerMapOnLocation(initialLocation)
        
        // Now grab all different locations
        
        self.loadWeather()
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func loadWeather() {
        self.context = self.appDel.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Weather")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dt", ascending: false)]
        fetchRequest.returnsDistinctResults = true
        
        fetchRequest.propertiesToFetch = ["lat", "lon"]
        let predicate = NSPredicate(format: "name != nil")
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        let fetchedResults = self.context!.executeFetchRequest(fetchRequest, error: nil) as! [Weather]
        
        for result in fetchedResults {
            var annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: (result.lat as NSString).doubleValue,
                longitude: (result.lon as NSString).doubleValue
            )
            annotation.title = "°C"+toString(result.temperature.intValue)
            annotation.subtitle = result.name
            mapView.addAnnotation(annotation)
        }
    }

}
