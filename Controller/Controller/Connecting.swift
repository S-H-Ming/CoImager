//
//  Connecting.swift
//  Controller
//
//  Created by CGLab on 2018/1/17.
//  Copyright © 2018年 S-H-Ming., All rights reserved.
//

import UIKit
import Foundation

class ConnectController: UIViewController{
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([String]?, String) -> ()
    
    var responses: [String] = []
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func getSearchResults(inputData: String, phpindex: String,completion: @escaping QueryResult) {
        
        errorMessage = ""
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "http://140.122.101.215/CoImagerD/"+phpindex+".php") {
            
            urlComponents.query = inputData
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                }
                else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.parseData(data)
                    
                    DispatchQueue.main.async {
                        completion(self.responses, self.errorMessage)
                    }
                    
                }
            }
            dataTask?.resume()
        }
    }
    
    fileprivate func parseData(_ data: Data) {
        
        var response: JSONDictionary?
        responses.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        if let ids = response?["ID"] as? [Any]{
            for id in ids{
                responses.append(id as! String)
            }
        }else{
            errorMessage += "Dictionary does not contain keys\n"
        }
    }
}


