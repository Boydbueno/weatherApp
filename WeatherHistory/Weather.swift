import Foundation
import CoreData

class Weather: NSManagedObject {

    @NSManaged var dt: NSDate
    @NSManaged var lat: String
    @NSManaged var lon: String
    @NSManaged var name: String
    @NSManaged var temperature: NSNumber
    @NSManaged var type: String

}
