//
//  HeatmapViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit
import MapKit

class HeatmapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .followWithHeading
        self.mapView.delegate = self
        self.addCircles(zones: CoronaService.shared.crowdedZones)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCrowdedZonesUpdate(_:)), name: .init(rawValue: "crowdedZonesUpdate"), object: nil)
    }
    
    @objc private func onCrowdedZonesUpdate(_ notification: Notification) {
        if let newCrowdedZones = notification.userInfo?["zones"] as? [CLLocation] {
            self.addCircles(zones: newCrowdedZones)
        }
    }
    
    private func addCircles(zones: [CLLocation]) {
        self.mapView.addOverlays(zones.map { zone -> MKCircle in
            return MKCircle(center: zone.coordinate, radius: 50)
        })
    }
}

extension HeatmapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
}
