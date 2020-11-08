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
        "View cases",
        "Generate PDF",
        "Mark location as crowded",
        "View heatmap",
        "Info",
        "Help"
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
            content.title = "It looks like you \(outside ? "went outside" : "came back home")"
            content.body = "Don't forget to \(outside ? "take your mask" : "wash your hands")!"
            if outside {
                self.sendPeriodicNotifications()
            } else {
                notificationCenter.removeAllPendingNotificationRequests()
            }
        } else {
            content.title = "It looks like you entered a crowded zone"
            content.body = "Try avoiding it if possible"
        }
        content.sound = .none
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
        UserDefaults.standard.setValue(outside, forKey: "outside")
    }

    private func sendPeriodicNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Wash your hands!"
        content.sound = .none
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
    }
    
    private func markLocationAsCrowded() {
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to mark your current location as crowded?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            if let location = self.locationManager.location {
                CoronaService.shared.markLocationAsCrowded(location: location) {
                    let finalAlertController = UIAlertController(title: "Done", message: "Your response was added", preferredStyle: .alert)
                    finalAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(finalAlertController, animated: true, completion: nil)
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
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
        return cell
    }
}
