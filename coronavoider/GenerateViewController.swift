//
//  GenerateViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 08/11/2020.
//

import UIKit

class GenerateViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var textFields: [UITextField?] = [nil, nil, nil, nil]
    let textFieldPlaceholders = ["Nume", "Adresă de domiciliu", "Adresă de reședință", "Localitatea nașterii"]
    var datePickers: [UIDatePicker?] = [nil, nil]
    let datePickerPlaceholders = ["Data nașterii", "Data declarației"]
    var duties = [false, false, false, false]
    var workPlace: Work?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.textFields[0]?.text == "" {
            if let declaration = UserDefaults.standard.object(forKey: "declaration") as? Data {
                let decoder = JSONDecoder()
                if let declaration = try? decoder.decode(Declaration.self, from: declaration) {
                    self.textFields[0]?.text = declaration.user.name
                    self.textFields[1]?.text = declaration.user.address
                    self.textFields[2]?.text = declaration.user.currentAddress
                    self.textFields[3]?.text = declaration.user.placeOfBirth
                    self.datePickers[0]?.date = declaration.user.dateOfBirth
                    self.duties = declaration.duties
                    self.workPlace = declaration.workPlace
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func onPressGenerate(_ sender: UIButton, forEvent event: UIEvent) {
        let user = User(
            name: self.textFields[0]?.text ?? "",
            address: self.textFields[1]?.text ?? "",
            currentAddress: self.textFields[2]?.text ?? "",
            dateOfBirth: self.datePickers[0]?.date ?? Date(),
            placeOfBirth: self.textFields[3]?.text ?? ""
        )
        let declaration = Declaration(
            user: user,
            date: self.datePickers[1]?.date ?? Date(),
            duties: self.duties,
            workPlace: self.workPlace
        )
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(declaration) {
            UserDefaults.standard.set(encoded, forKey: "declaration")
        }
        let url = declaration.createDocument()
        self.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }
}

extension GenerateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 6...9:
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
                    self.duties[indexPath.row - 6].toggle()
                }
            case 10:
                let alertController = UIAlertController(title: "Adaugă loc de muncă", message: nil, preferredStyle: .alert)
                ["Societate", "Locație", "Puncte de lucru (separate prin virgulă)"].forEach { placeholder in
                    alertController.addTextField { textField in
                        textField.placeholder = placeholder
                    }
                }
                alertController.addAction(.init(title: "OK", style: .default, handler: { _ in
                    let society = alertController.textFields?[0].text ?? ""
                    let location = alertController.textFields?[1].text ?? ""
                    let workpoints = (alertController.textFields?[2].text ?? "").components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    let work = Work(
                        society: society,
                        location: location,
                        workPoints: workpoints
                    )
                    self.workPlace = work
                    self.tableView.reloadData()
                }))
                alertController.addAction(.init(title: "Anulare", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            default:
                ()
        }
    }
}

extension GenerateViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4 + 2 + 4 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0...3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell")!
                let textField = cell.viewWithTag(1) as! UITextField
                textField.placeholder = self.textFieldPlaceholders[indexPath.row]
                self.textFields[indexPath.row] = textField
                return cell
            case 4...5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell")!
                let label = cell.viewWithTag(1) as! UILabel
                label.text = self.datePickerPlaceholders[indexPath.row - 4]
                let datePicker = cell.viewWithTag(2) as! UIDatePicker
                self.datePickers[indexPath.row - 4] = datePicker
                return cell
            case 6...9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.text = Duty.allCases[indexPath.row - 6].rawValue
                cell.textLabel?.numberOfLines = 0
                cell.accessoryType = self.duties[indexPath.row - 6] ? .checkmark : .none
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                if let workPlace = self.workPlace {
                    cell.textLabel?.text = "Loc de muncă: \(workPlace.society)"
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.numberOfLines = 0
                } else {
                    cell.textLabel?.text = "Adaugă loc de muncă"
                    cell.textLabel?.textColor = .blue
                }
                return cell
            default:
                fatalError()
        }
    }
}
