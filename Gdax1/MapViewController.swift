//
//  MapViewController.swift
//  Gdax1
//
//  Created by Mohammed on 12/9/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit

import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var MyMapView: MKMapView!
    
    
    let manager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
//        manager.stopMonitoringSignificantLocationChanges()
        

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        manager.startUpdatingLocation()
        //manager.startMonitoringSignificantLocationChanges()
        
        
        DispatchQueue.global().async {
            sleep(5)
            self.performSearch(searchTerm: "Bitcoin atm")
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingLocation()
    }
    
    

    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    func performSearch(searchTerm:String)
    {
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchTerm
        request.region = MyMapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil
            {
                print("Error while searching: \(error!.localizedDescription)")
            }
            else if response!.mapItems.count == 0
            {
                print("No matches found")
            }
            else
            {
                
                for item in response!.mapItems
                {
                    //print("Name = \(item.name)")
                    //print("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    //print("Matching items = \(self.matchingItems.count)")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.MyMapView.addAnnotation(annotation)
                }
                
                
                //zoom to first result
                if response!.mapItems.count > 0
                {
                    let coord = response!.mapItems[0].placemark.coordinate
                    let span  = MKCoordinateSpanMake(0.1, 0.1)
                    let region = MKCoordinateRegionMake(coord, span)
                    
                    self.MyMapView.setRegion(region, animated: true)
                    
                }
                
                
                
            }
        })
    }


    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //        let location = locations[0]
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //        MyMapView.setRegion(region, animated: true)
        self.MyMapView.showsUserLocation = true
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()

    }
    


}





