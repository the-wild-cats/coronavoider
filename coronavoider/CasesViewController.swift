//
//  CasesViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit

class CasesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var data: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        CoronaService.shared.getTable { data in
            self.data = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension CasesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let data = self.data[indexPath.row]
        if indexPath.row == self.data.count - 1 {
            cell.textLabel?.text = "Cazuri totale - \(data[1])"
        } else {
            cell.textLabel?.text = "\(data[0]) - \(data[2])"
        }
        return cell
    }
}
