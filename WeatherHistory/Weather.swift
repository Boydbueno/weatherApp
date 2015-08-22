import Foundation
import CoreData

class Weather: NSManagedObject {
    @NSManaged var lat: NSString
    @NSManaged var lon: NSString
    @NSManaged var type: NSString
    @NSManaged var dt: NSDate
}