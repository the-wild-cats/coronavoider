//
//  ViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.slider.value = 25
    }
    
    @IBAction func onDonePress(_ sender: UIButton, forEvent event: UIEvent) {
        if let circle = self.mapView.overlays.first as? MKCircle {
            UserDefaults.standard.set(circle.coordinate.latitude, forKey: "lat")
            UserDefaults.standard.set(circle.coordinate.longitude, forKey: "long")
            UserDefaults.standard.set(circle.radius, forKey: "radius")
            UserDefaults.standard.set(true, forKey: "outside")
            self.performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    @IBAction func onSliderValueChange(_ sender: UISlider, forEvent event: UIEvent) {
        if let circle = self.mapView.overlays.first {
            let newCircle = MKCircle(center: circle.coordinate, radius: Double(sender.value))
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(newCircle)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        self.mapView.setRegion(region, animated: true)
        let circle = MKCircle(center: userLocation.coordinate, radius: Double(self.slider.value))
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.15)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
}
