//
//  LoadingView.swift
//  NearBy
//
//  Created by Moataz Mohamed on 14/05/2024.
//

import UIKit

class LoadingView: UIViewController {
    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.startAnimating()
    }


}
