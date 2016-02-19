//
//  Venue.swift
//  Map Test
//
//  Created by Greg Hochsprung on 2/18/16.
//  Copyright © 2016 Greg Hochsprung. All rights reserved.
//

import Foundation
import MapKit

class Venue: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let thumbnailImage: UIImage
    
    init(title: String, coordinate: CLLocationCoordinate2D, thumbnailImage: UIImage) {
        self.title = title
        self.coordinate = coordinate
        self.thumbnailImage = thumbnailImage
        
        super.init()
    }
}