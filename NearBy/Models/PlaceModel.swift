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
    let location : Location?
    let name : String?
    
    enum CodingKeys : String , CodingKey{
        case fsqID = "fsq_id"
        case location , name
    }
    
}

struct Location: Codable{
    let address : String?
    let formattedAddress : String?
    
    enum CodingKeys:String,CodingKey {
        case address
        case formattedAddress = "formatted_address"
    }
}
