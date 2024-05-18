//
//  LoadingView.swift
//  NearBy
//
//  Created by Moataz Mohamed on 14/05/2024.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class LoadingView: UIViewController {
    
//    MARK: - Attributes and Outlets
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var indicatorStack: UIStackView!
    
    let disposeBag = DisposeBag()
    var viewModel : LoadingViewModel!

//    MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoadingViewModel(disposeBag: disposeBag)
        subscribeToStatePublisher()
        subscribeToPlacesDataPublisher()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        viewModel.checkAuthorizationStatus()

    }
    
    
    
//    MARK: - View Model Subscribetions
    
    //Subscribe to the state publisher to get the state
    private func subscribeToStatePublisher(){
        viewModel.statePublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] state in
                if state{
                    self?.configUiState(state: .requesting)
                }else{
                    self?.configUiState(state: .error)

                }
            }
            .disposed(by: disposeBag)
    }
    
    //receive the places data
    private func subscribeToPlacesDataPublisher(){
        viewModel.placesDataPublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] places in
                if let results = places.element , places.element?.count != 0{
                    self?.navigationController?.setViewControllers([InfoView(places: results)], animated: true)

                }else{
                    self?.configUiState(state: .noData)

                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
//    MARK: - State

    private enum loadingState{
        case requesting , error , noData
    }
    
    //configure state based on the state publisher
    private func configUiState(state : loadingState){
        switch state{
        case .requesting:
            indicator.startAnimating()
            indicatorStack.isHidden = false
            errorImage.isHidden = true
        case .error:
            indicator.stopAnimating()
            indicatorStack.isHidden = true
            errorImage.isHidden = false
            errorImage.image = .errorView
        case .noData:
            indicator.stopAnimating()
            indicatorStack.isHidden = true
            errorImage.isHidden = false
            errorImage.image = .noDataView

        }
    }
}


