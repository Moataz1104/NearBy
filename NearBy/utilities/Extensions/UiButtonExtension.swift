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
        let selectedMode = UserDefaults.standard.string(forKey: "selectedMode") ?? modes.first
        
        for mode in modes{
            let action = UIAction(title: mode) { action in
                actionClosure(action)
                UserDefaults.standard.set(action.title,forKey: "selectedMode")
                self.setTitle(mode, for: .normal)
            }
            action.state = (mode == selectedMode) ? .on : .off
            menuChildren.append(action)
        }
        
        self.menu = UIMenu(options: .displayInline,children: menuChildren)
        self.showsMenuAsPrimaryAction = true
        self.changesSelectionAsPrimaryAction = true
        
        self.setTitle(selectedMode, for: .normal)
        

    }
    
    
}
