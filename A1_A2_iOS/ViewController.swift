
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directionBtn: UIButton!
    
    // create location manager
    var locationMnager = CLLocationManager()
    
    // destination variable
    var destination: CLLocationCoordinate2D!
    
    // create the places array
//    let places = Place.getPlaces()
    
    var places = [Place]()
    
    var placeName = ["A", "B", "C"]
    
    var myLocation: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = true
        map.showsUserLocation = true
        
        directionBtn.isHidden = true
        
        // we assign the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // we define the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        // 1st step is to define latitude and longitude
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
        // 2nd step is to display the marker on the map
//        displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here")
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
        uilpgr.minimumPressDuration = 1
//        uilpgr.delaysTouchesBegan = true
        map.addGestureRecognizer(uilpgr)
        
        // add double tap
//        addDoubleTap()
        
        // giving the delegate of MKMapViewDelegate to this class
        map.delegate = self
        
        // add annotations for the places
//        addAnnotationsForPlaces()
        
        // add polyline
//        addPolyline()
        
        // add polygon
//        addPolygon()
        
        
    }
    
    //MARK: - draw route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationMnager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        removePin()
//        print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        myLocation = Place(title: "My Location", subtitle: "you are here", coordinate: coordinates)
        displayLocation(latitude: latitude, longitude: longitude, title: "My Location", subtitle: "you are here")
        locationMnager.stopUpdatingLocation()
    }
    
    //MARK: - add annotations for the places
    func addAnnotationsForPlaces() {
//        map.addAnnotations(places)
        var coordinates = [CLLocationCoordinate2D]()
        for place in places {
            coordinates.append(place.coordinate)
        }
        let overlays = places.map {_ in MKPolygon(coordinates: coordinates, count: 3)}
        map.addOverlays(overlays)
    }
    
    //MARK: - polyline method
    func addPolyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.title = "hi"
        polyline.boundingMapRect
        map.addOverlay(polyline)
    }
    
    //MARK: - polygon method
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
    }
    
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        
        // add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "my destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionBtn.isHidden = false
    }
    
    func addLabel() {
        let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 105, height: 30))
        annotationLabel.textAlignment = .center
        annotationLabel.font = UIFont(name: "Rockwell", size: 10)
        annotationLabel.text = "Hello"
    }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
                    return
        }
        if(places.count == 3) {
            places.removeAll()
            map.removeOverlays(map.overlays)
            removePin()
            displayLocation(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude, title: myLocation!.title!, subtitle: myLocation!.subtitle!)
        }
        
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        let place = Place(title: placeName[places.count], subtitle: "Location", coordinate: coordinate)
        annotation.title = placeName[places.count]
        annotation.coordinate = coordinate
        places.append(place)
        map.addAnnotation(annotation)
        if(places.count == 3) {
            addAnnotationsForPlaces()
            addPolyline()
        }
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
//        map.removeAnnotations(map.annotations)
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        map.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }

}

extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "my location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "my destination":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        case "my favorite":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        case "A", "B", "C":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.annotation = annotation
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let coordinate0 = CLLocation(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        let coordinate1 = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
//        print(coordinate1.coordinate.longitude, coordinate1.coordinate.latitude)
//        print(coordinate0.coordinate.longitude, coordinate0.coordinate.latitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        let title = view.annotation?.title!
        let distance = Double(round(100*(distanceInMeters/1000))/100)
        let message = "Distance between your location and \(title!) is: \(distance) KM"
        let alertController = UIAlertController(title: "Distance", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}

