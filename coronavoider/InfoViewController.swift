//
//  InfoViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let data: [String] = [
        "Spălați-vă mâinile de multe ori.",
        "Evitați contactul cu persoane care sunt suspecte de infecții respiratorii acute.",
        "Nu vă atingeți ochii, nasul și gura cu mâinile.",
        "Acoperiți-vă gura și nasul dacă strănutați sau tușiți.",
        "Nu luați medicamente antivirale si nici antibiotice decât în cazul în care vă prescrie medicul.",
        "Curățați toate suprafețele cu dezinfectanți pe bază de clor sau alcool.",
        "Utilizați masca pentru protecția dumneavoastră.",
        "Produsele ”MADE in CHINA” sau pachetele primite din China nu sunt periculoase.",
        "Pentru informații suplimentare legate de prevenirea infectării cu virusul COVID–19 (coronavirus) puteți apela numărul 800800358 operaționalizat de Institutul Național de Sănătate Publică.",
        "Programul de funcționare al liniei verde este zilnic, între orele 08:00 și 23:00, inclusiv în zilele de sâmbătă și duminică.",
        "Spălarea și dezinfectarea mâinilor sunt acțiuni decisive pentru a preveni infecția. Mâinile se spală cu apă și săpun cel puțin 20 de secunde. Dacă nu există apă și săpun, puteți folosi un dezinfectant pentru mâini pe bază de alcool de 60%. Spălarea mâinilor elimină virusul."
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
    }
}

extension InfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.data[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        if indexPath.row == self.data.count - 1 {
            cell.textLabel?.textColor = .red
        }
        return cell
    }
}
