//
//  InfoView.swift
//  NearBy
//
//  Created by Moataz Mohamed on 17/05/2024.
//

import UIKit

class InfoView: UIViewController {
    
//    MARK: - Attributes and Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeButton: UIButton!
    
    let places : [PlaceResult]
    
//    MARK: - ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
        
    }
    
    init(places: [PlaceResult]) {
        self.places = places
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
//    MARK: - Privates
    private func registerCell(){
        tableView.register(UINib(nibName: PlaceInfoCell.identifier, bundle: nil), forCellReuseIdentifier: PlaceInfoCell.identifier)
    }
    
    

}

extension InfoView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceInfoCell.identifier, for: indexPath) as! PlaceInfoCell
        let place = places[indexPath.row]
        
        cell.placeName.text = place.name ?? "No Name"
        cell.placeAddress.text = place.location?.formattedAddress ?? "No Address"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }
    
    
    
}
