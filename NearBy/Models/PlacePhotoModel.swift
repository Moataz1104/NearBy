//
//  PlacePhotoModel.swift
//  NearBy
//
//  Created by Moataz Mohamed on 17/05/2024.
//

import Foundation


struct PlacePhotoModel:Codable , Equatable {
    let id : String?
    let createdAt : String?
    let prefix : String?
    let suffix : String?
    let width:Int?
    let height:Int?
    
    
    
    var photoUrlString : String? {
        //Returns the full url of the photo
        guard let suffix = suffix , let prefix = prefix else { return nil }
        let photoDimentions = "100x100"
        
        let urlString = prefix.appending(photoDimentions).appending(suffix)
        return urlString
    }
}
