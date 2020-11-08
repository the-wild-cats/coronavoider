//
//  HelpViewController.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit

enum ListItem: Hashable {
    case header(HeaderItem)
    case content(ContentItem)
}

struct HeaderItem: Hashable {
    let title: String?
    let items: [ContentItem]
}

struct ContentItem: Hashable {
    let name: String
}

class HelpViewController: UIViewController {
    let modelObjects = [
        HeaderItem(title: "RESPECTAȚI MĂSURILE DE IZOLARE ȘI PROTECȚIE​", items: [
            ContentItem(name: "Dacă ați călătorit în ultimele 21 de zile în zonele cu transmitere comunitară extinsă COVID-19, respectați cu strictețe măsurile de carantină, respectiv auto-izolare, la întoarcerea în țară.​"),
            ContentItem(name: "Rămâneți acasă dacă începeți să vă simțiți rău, chiar și cu simptome ușoare, cum ar fi dureri de cap și nas ușor curgător, până vă recuperați.​"),
            ContentItem(name: "Sunt recomandate odihna, administrarea de lichide și antitermice.​")
        ]),
        HeaderItem(title: "APELAȚI 112​", items: [
            ContentItem(name: "Dacă ați avut contact cu o persoană suspectă sau vă întoarceți dintr-o țară în care s-au identificat cazuri de Coronavirus și prezentați unul din simptomele specifice infecției cu acest virus, apelați numărul de urgență 112 sau Direcția de Sănătate Publică din județul în care vă aflați."),
        ]),
        HeaderItem(title: "EVITAȚI DEPLASAREA LA SPITAL​", items: [
            ContentItem(name: "În cazul în care suspectați că sunteți infectat cu COVID-19, nu vă deplasați la camerele de gardă ale spitalelor pentru a nu risca transmiterea virusului, ci apelați numărul de urgență 112!"),
        ]),
    ]
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<HeaderItem, ListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: listLayout)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 0.0),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
        ])
        
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HeaderItem> { (cell, indexPath, headerItem) in
            var content = cell.defaultContentConfiguration()
            content.text = headerItem.title
            cell.contentConfiguration = content
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: headerDisclosureOption)]
        }
        
        let contentCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ContentItem> {  (cell, indexPath, contentItem) in
            var content = cell.defaultContentConfiguration()
            content.text = contentItem.name
            cell.contentConfiguration = content
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<HeaderItem, ListItem>(collectionView: collectionView) { (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            switch listItem {
                case .header(let headerItem):
                    return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: headerItem)
                case .content(let contentItem):
                    return collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: contentItem)
            }
        }
        
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<HeaderItem, ListItem>()

        dataSourceSnapshot.appendSections(modelObjects)
        dataSource.apply(dataSourceSnapshot)
        
        for headerItem in modelObjects {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
            
            let headerListItem = ListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            let contentArray = headerItem.items.map { ListItem.content($0) }
            sectionSnapshot.append(contentArray, to: headerListItem)
            
            sectionSnapshot.expand([headerListItem])
            
            dataSource.apply(sectionSnapshot, to: headerItem, animatingDifferences: false)
        }
    }
}
