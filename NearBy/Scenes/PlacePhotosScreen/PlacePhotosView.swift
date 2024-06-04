//
//  PlacePhotosView.swift
//  NearBy
//
//  Created by Moataz Mohamed on 04/06/2024.
//

import UIKit

class PlacePhotosView: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let placeID:String
    let viewModel = PlacePhotosViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Photos"
        navigationController?.navigationBar.isHidden = false

        viewModel.reloadTable = {[weak self] in
            DispatchQueue.main.async{
                self?.tableView.reloadData()
            }
            
        }
        registerNib()
        viewModel.fetchPhotosUrl(id: placeID)
        print(placeID)
    }
    init( placeID: String) {
        self.placeID = placeID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func registerNib(){
        tableView.register(UINib(nibName: PhotoCell.identifier, bundle: nil), forCellReuseIdentifier: PhotoCell.identifier)
    }

}

extension PlacePhotosView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let photos = viewModel.fetchedPhotosData{
            print("11111")
            return photos.count
        }
        print("2222")
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let photos = viewModel.fetchedPhotosData else{return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.configImage(urlString: photos[indexPath.row].largePhotoUrlString!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        330
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
