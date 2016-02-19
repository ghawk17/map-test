//
//  Server.swift
//  Map Test
//
//  Created by Greg Hochsprung on 2/18/16.
//  Copyright © 2016 Greg Hochsprung. All rights reserved.
//

import Foundation
import MapKit

let clientID = "KB45V00TQB1PCVWOWRWQP3VPYAAB15BEG5VCZVGA3LADGA4B"
let clientSecret = "J3R4VAADPG4N4IATDCA2NVOU1Q0FQ5LQ0ZS3TBNTFM2DVKFT"
let v = "20160218"

final class Server {
    func getVenuesForLatitude(latitude: Double, longitude: Double, completion: (result: [Venue], latRange: Double) -> Void) {
        let requestURL = NSURL(string: "https://api.foursquare.com/v2/venues/explore?ll=\(latitude),\(longitude)&client_id=\(clientID)&client_secret=\(clientSecret)&v=\(v)")!
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // do stuff
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary
                
                var minLat = 9999.0
                var maxLat = -9999.0
                var venues: [Venue] = []
                
                if let response = json!["response"] as? NSDictionary {
                    if let groups = response["groups"] as? NSArray {
                        for group in groups {
                            if let items = group["items"] as? NSArray {
                                for item in items {
                                    if let venue = item["venue"] {
                                        if let name = venue!["name"] as? String {
                                            if let location = venue!["location"] {
                                                if let lat = location!["lat"] as? Double {
                                                    if minLat > lat {
                                                        minLat = lat
                                                    }
                                                    if maxLat < lat {
                                                        maxLat = lat
                                                    }
                                                    if let lng = location!["lng"] as? Double {
                                                        if let tips = item["tips"] as? NSArray {
                                                            if let tip = tips[0] as? NSDictionary {
                                                                if let photoURL = tip["photourl"] as? String {
                                                                    let url = NSURL(string:photoURL)
                                                                    let data = NSData(contentsOfURL:url!)
                                                                    var image = UIImage()
                                                                    if data != nil {
                                                                        image = UIImage(data:data!)!
                                                                    }
                                                                    let tempVenue = Venue(title: name, coordinate: CLLocationCoordinate2DMake(lat, lng), thumbnailImage: image)
                                                                    venues.append(tempVenue)
                                                                }  else {
                                                                    let tempVenue = Venue(title: name, coordinate: CLLocationCoordinate2DMake(lat, lng), thumbnailImage: UIImage())
                                                                    venues.append(tempVenue)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                completion(result: venues, latRange: maxLat - minLat)
            } catch {
                print("Error with JSON: \(error)")
            }
        }
        task.resume()
    }
}