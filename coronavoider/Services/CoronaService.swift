//
//  CoronaService.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import Foundation
import SwiftSoup
import CoreLocation
import Firebase

class CoronaService {
    static let shared = CoronaService()
    private init() {}
    
    var crowdedZones = [CLLocation]()
    
    func getTable(completionHandler: @escaping ([[String]]) -> ()) {
        let date = Date()
        let url = self.getUrl(date: date)
        self.fetch(url: url) { html in
            let table = try? SwiftSoup.parse(html)
                .select("table")[0]
                .select("tr")[1...]
                .map { tr in
                    return try tr.select("td")[1...]
                        .map { td in
                            return try td.text().replacingOccurrences(of: "*", with: "")
                        }
                }
            completionHandler(table!)
        }
    }
    
    private func getUrl(date: Date) -> URL {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy/MM/dd"
        let str1 = formatter1.string(from: date)
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd-MM-yyyy"
        let str2 = formatter2.string(from: date)
        return URL(string: "http://www.ms.ro/\(str1)/buletin-informativ-\(str2)/")!
    }
    
    private func fetch(url: URL, completionHandler: @escaping (String) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                    case 404:
                        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                        let url = self.getUrl(date: date)
                        self.fetch(url: url, completionHandler: completionHandler)
                    case 200:
                        if let data = data, let str = String(data: data, encoding: .utf8) {
                            completionHandler(str)
                        }
                    default:
                        ()
                }
            }
        }.resume()
    }
    
    func markLocationAsCrowded(location: CLLocation, completionHandler: @escaping () -> ()) {
        Firestore
            .firestore()
            .collection("areas")
            .document()
            .setData([
                "coordinates": GeoPoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                "date": Date()
            ]) { _ in
                completionHandler()
            }
    }
    
    func startCrowdedZonesUpdate() {
//        let date = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        Firestore
            .firestore()
            .collection("areas")
//            .whereField("date", isGreaterThan: date)
            .addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    let newCrowdedZones = snapshot.documentChanges.filter { diff in
                        diff.type != .removed
                    }.map { diff in
                        diff.document
                    }.map { doc -> CLLocation? in
                        let data = doc.data()
                        if let geoPoint = data["coordinates"] as? GeoPoint {
                            return CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        } else {
                            return nil
                        }
                    }.compactMap { $0 }
                    self.crowdedZones.append(contentsOf: newCrowdedZones)
                    NotificationCenter.default.post(name: .init(rawValue: "crowdedZonesUpdate"), object: nil, userInfo: [
                        "zones": newCrowdedZones
                    ])
                }
        }
    }
}
