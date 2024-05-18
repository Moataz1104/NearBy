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
    var viewModel : InfoViewModel!
    
    
    //    MARK: - ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = InfoViewModel()
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
        let place = places[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceInfoCell.identifier, for: indexPath) as! PlaceInfoCell
        
//        Fetch the photos url then pass it to the cell
        viewModel.fetchPhotosUrl(place: place) { url , error in
            if let url = url , error == nil{
                cell.configImage(with: url)
            }else{
                //HAndle errors
            }
        }
        cell.placeName.text = place.name ?? "No Name"
        cell.placeAddress.text = place.location?.formattedAddress ?? "No Address"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }
    
    
    
}
