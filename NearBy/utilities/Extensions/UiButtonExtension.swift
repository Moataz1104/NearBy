//
//  UiButtonExtension.swift
//  NearBy
//
//  Created by Moataz Mohamed on 18/05/2024.
//

import Foundation
import UIKit

extension UIButton{
    
    func configureMenu(actionClosure:@escaping(UIAction)->Void){
        let modes = ["Realtime","Single Update"]
        var menuChildren:[UIMenuElement] = []
        
        for mode in modes{
            menuChildren.append(UIAction(title: mode, handler: actionClosure))
        }
        
        self.menu = UIMenu(options: .displayInline,children: menuChildren)
        self.showsMenuAsPrimaryAction = true
        self.changesSelectionAsPrimaryAction = true
    }
    
    
}
