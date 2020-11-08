//
//  Duty.swift
//  Coronavoider
//
//  Created by Octavian Custura on 07/11/2020.
//

import Foundation
import TPPDF
import UIKit

struct Work: Codable {
    let society: String
    let location: String
    let workPoints: [String]
    
    init(society: String, location: String, workPoints: [String]) {
        self.society = society
        self.location = location
        self.workPoints = workPoints
    }
}

enum Duty: String, CaseIterable {
    case medicalAssistance = "Asistență medicală care nu poate fi amânată și nici realizată de la distanță"
    case buyMeds = "Achiziționarea de medicamente"
    case caretaking = "Îngrijirea/însoțirea copilului și/sau asistența persoanelor vârstnice, bolnave sau cu dizabilități"
    case deceasedPerson = "Deces al unui membru al familiei"
}

struct User: Codable {
    let name: String
    let address: String
    let currentAddress: String
    let dateOfBirth: Date
    let placeOfBirth: String
}

struct Declaration: Codable {
    let user: User
    let date: Date
    let duties: [Bool]
    let workPlace: Work?
    
    var yesElement: PDFImage {
        PDFImage(image: UIImage(systemName: "play")!)
    }
    
    var noElement: PDFImage {
        PDFImage(image: UIImage(systemName: "pause")!)
    }

    public func createDocument() -> URL {
        let document = PDFDocument(format: .a4)

        let image = UIImage(named: "ms")!
        let imageElement = PDFImage(image: image)
        document.add(.headerRight, image: imageElement)
        document.add(.contentCenter, text: "DECLARATIE PE PROPRIE RASPUNDERE")
        document.add(text: "\n")
        document.set(font: .systemFont(ofSize: 14.0))
        document.add(text: "Subsemnatul/a: \(self.user.name)")
        document.add(text: "domiciliat/ă în: \(self.user.address)")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        document.add(text: "născut/ă în data de: \(formatter.string(from: user.dateOfBirth))  în localitatea \(user.placeOfBirth)")
        document.add(text: "declar pe proprie răspundere, cunoscând prevederile articolului 326 din Codul Penal privind falsul în declarații, că mă deplasez în afara locuinței, în intervalul orar 23.00 – 05.00, din următorul/următoarele motive:\n")
        
        if let workPlace = self.workPlace {
            document.add(image: self.yesElement)
            document.add(text: "În interes profesional. Menționez că îmi desfășor activitatea profesională la instituția/societatea/organizația \(workPlace.society) cu sediul în \(workPlace.location) și cu punct/e de lucru la următoarele adrese: ")
            workPlace.workPoints.forEach { workPoint in
                document.add(text: workPoint)
            }
        }
        
        Duty.allCases.enumerated().forEach { index, value in
            document.add(image: self.duties[index] ? self.yesElement : self.noElement)
            document.add(text: value.rawValue)
        }
        
        document.add(space: 25)
        document.add(.contentLeft, text: "Data \(formatter.string(from: self.date))")
        document.add(.contentRight, text: "Semnătura.................")
        
        document.set(.footerCenter, font: UIFont.systemFont(ofSize: 8))

        document.add(.footerCenter, text: "**Declarația pe propria răspundere poate fi stocată și prezentată pentru control pe dispozitive electronice mobile, cu condiția ca pe documentul prezentat să existe semnătura olografă a persoanei care folosește Declarația și data pentru care este valabilă declarația.")
        document.add(.footerCenter, text: "*Declarația pe propria răspundere poate fi scrisă de mână, cu condiția preluării tuturor elementelor prezentate mai sus")
        
        let generator = PDFGenerator(document: document)
        return try! generator.generateURL(filename: "declaratie.pdf")
    }
}
