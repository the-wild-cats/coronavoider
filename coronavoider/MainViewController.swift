//
//  MainViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit
import CoreLocation
import UserNotifications

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let rows = [
        "Vizualizează numărul de cazuri pe județ",
        "Generează declarație pe propria răspundere",
        "Marchează locația ca fiind aglomerată",
        "Vizualizează harta zonelor aglomerate",
        "Informații generale despre SARS-CoV-2",
        "Ce fac dacă suspectez că am COVID-19?"
    ]

    let locationManager = CLLocationManager()
    
    let homeLocation: CLLocation = {
        let lat = UserDefaults.standard.double(forKey: "lat")
        let long = UserDefaults.standard.double(forKey: "long")
        return CLLocation(latitude: lat, longitude: long)
    }()
    
    let radius = UserDefaults.standard.double(forKey: "radius")
    
    var outside: Bool {
        return UserDefaults.standard.bool(forKey: "outside")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 10
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        CoronaService.shared.startCrowdedZonesUpdate()
        
        let didAgree = UserDefaults.standard.bool(forKey: "didAgree")
        if !didAgree {
            let alertController = UIAlertController(title: "Atenție", message: "Lăsați aplicația să ruleze în fundal, nu o închideți forțat", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default, handler: { _ in
                UserDefaults.standard.set(true, forKey: "didAgree")
            }))
            self.present(alertController, animated: true)
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let distance = location.distance(from: self.homeLocation)
            if distance > self.radius && !self.outside {
                self.sendNotification(outside: true)
            } else if distance < self.radius && self.outside {
                self.sendNotification(outside: false)
            }
            DispatchQueue.global(qos: .background).async {
                for zone in CoronaService.shared.crowdedZones {
                    let distance = zone.distance(from: location)
                    let distanceFromHome = zone.distance(from: self.homeLocation)
                    if distance < 25, distanceFromHome > self.radius {
                        self.sendNotification(zone: true)
                        break
                    }
                }
            }
        }
    }

    private func sendNotification(outside: Bool? = nil, zone: Bool? = nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        if let outside = outside {
            content.title = "Se pare că \(outside ? "ai plecat de acasă" : "te-ai întors acasă")"
            content.body = "Nu uita să \(outside ? "îți iei masca de protecție" : "te speli pe mâini")!"
            if outside {
                self.sendPeriodicNotifications()
            } else {
                notificationCenter.removeAllPendingNotificationRequests()
            }
            UserDefaults.standard.setValue(outside, forKey: "outside")
        } else {
            content.title = "Se pare că ai intrat într-o zonă aglomerată"
            content.body = "Încearcă să o eviți pe cât posibil!"
        }
        content.sound = .none
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    private func sendPeriodicNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Nu uita"
        content.body = "Spală-te pe mâini!"
        content.sound = .none
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
    }
    
    private func markLocationAsCrowded() {
        let alertController = UIAlertController(title: "Confirmare", message: "Sigur dorești să marchezi locația curentă ca fiind aglomerată?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Da", style: .default, handler: { _ in
            if let location = self.locationManager.location {
                CoronaService.shared.markLocationAsCrowded(location: location) {
                    let finalAlertController = UIAlertController(title: "Efectuat", message: "Răspunsul tău a fost înregistrat", preferredStyle: .alert)
                    finalAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(finalAlertController, animated: true, completion: nil)
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Nu", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "cases", sender: self)
            case 1:
                self.performSegue(withIdentifier: "generate", sender: self)
            case 2:
                self.markLocationAsCrowded()
            case 3:
                self.performSegue(withIdentifier: "heatmap", sender: self)
            case 4:
                self.performSegue(withIdentifier: "info", sender: self)
            case 5:
                self.performSegue(withIdentifier: "help", sender: self)
            default:
                ()
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.rows[indexPath.row]
        switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(systemName: "person.crop.circle.badge.questionmark")!
            case 1:
                cell.imageView?.image = UIImage(systemName: "pencil.circle")!
            case 2:
                cell.imageView?.image = UIImage(systemName: "mappin.circle")!
            case 3:
                cell.imageView?.image = UIImage(systemName: "map")!
            case 4:
                cell.imageView?.image = UIImage(systemName: "info.circle")!
            case 5:
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")!
            default:
                ()
        }
        return cell
    }
}
