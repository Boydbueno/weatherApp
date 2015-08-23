import UIKit

public class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var lon: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setLocationText(location: String) {
        self.location.text = location
    }
    
    public func setLatAndLon(lat: String, lon: String) {
        self.lat.text = lat
        self.lon.text = lon
    }
    
    public func setTemperature(temp: Double) {
        self.temp.text = "°C"+toString(Int(temp))
    }
    
    public func setWeatherType(type: String) {
        self.type.text = type
    }
    
    public func setDateTimeText(dateTime: NSDate) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = dateFormatter.stringFromDate(dateTime)
        self.dateTime.text = dateString
    }

}
