//
//  InfoView.swift
//  NearBy
//
//  Created by Moataz Mohamed on 17/05/2024.
//

import UIKit
import RxSwift
import RxCocoa

class InfoView: UIViewController {
    
    //    MARK: - Attributes and Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var stateImage: UIImageView!
    
    
    let disposeBag = DisposeBag()
    let places : [PlaceResult]
    var viewModel : InfoViewModel!
    
    
    //    MARK: - ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = InfoViewModel()
        tableView.delegate = self
        tableView.dataSource = self
        view.bringSubviewToFront(modeButton)
        
        
        modeButton.configureMenu{action in
            print(action.title)
        }
        
        subscribeToStatePublisher()
        registerCell()
        
    }
    
    init(places: [PlaceResult]) {
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //    MARK: - View Model Subscribetions
    
    //Subscribe to the state publisher to get the state
    private func subscribeToStatePublisher(){
        viewModel.statePublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self]state in
                if state{
                    self?.configUiState(state: .requesting)
                }else{
                    self?.configUiState(state: .error)
                    
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
    
    
    //    MARK: - Privates
    private func registerCell(){
        tableView.register(UINib(nibName: PlaceInfoCell.identifier, bundle: nil), forCellReuseIdentifier: PlaceInfoCell.identifier)
    }
    
    
//    MARK: - State
    private enum loadingState{
        case requesting , error , noData
    }
    
    private func configUiState(state : loadingState){
        switch state{
        case .requesting:
            tableView.isHidden = false
            stateImage.isHidden = true
        case .error:
            tableView.isHidden = true
            stateImage.isHidden = false
            stateImage.image = .errorView
        case .noData:
            tableView.isHidden = true
            stateImage.isHidden = false
            stateImage.image = .noDataView

        }
    }

    
}



extension InfoView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.isEmpty{
            configUiState(state: .noData)
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceInfoCell.identifier, for: indexPath) as! PlaceInfoCell
        
        cell.viewModel = viewModel
        
        cell.configImage(with: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }
    
    
    
}
