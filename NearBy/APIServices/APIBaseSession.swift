//
//  APIBaseSession.swift
//  NearBy
//
//  Created by Moataz Mohamed on 15/05/2024.
//

import Foundation


struct APIBaseSession{
    
    
    static func baseSession(request : URLRequest , completion: @escaping (Result<Data?,Error>) -> Void){
        
        let session = URLSession.shared
        
        session.dataTask(with: request){ data , response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else{
                completion(.failure(NSError(domain: "HTTP response error", code: 0)))
                return
            }
            
            if (200...300).contains(response.statusCode){
                print("success from baseSession")
                completion(.success(data))
            }else{
                print("Error from baseSession")
                completion(.failure(NSError(domain: "HTTP Error", code: response.statusCode)))
                
            }
            
        }
    }
}
