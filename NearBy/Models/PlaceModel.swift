//
//  PlaceModel.swift
//  NearBy
//
//  Created by Moataz Mohamed on 15/05/2024.
//

import Foundation

struct PlaceModel : Codable{
    let results : [PlaceResult]?
}

struct PlaceResult : Codable{
    let fsqID : String?
    let categories : [PlaceCategory]?
    let location : Location?
    
}

struct PlaceCategory: Codable{
    let name : String?
}

struct Location: Codable{
    let formattedAddress : String?
}
