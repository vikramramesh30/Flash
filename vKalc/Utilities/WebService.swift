//
//  WebService.swift
//  vKalc
//
//  Created by cis on 22/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class WebService: NSObject {
    static let sharedInstance = WebService()
    //    AF.request("https://httpbin.org/get") { urlRequest in
    //        urlRequest.timeoutInterval = 5
    //        urlRequest.allowsConstrainedNetworkAccess = false
    //    }
    //    .response(...)
    
    //MARK:Functions
    func request<T : Encodable>(url: String, param: T?, Success: @escaping (_ data: [String:Any]?) -> Void, Error: @escaping (_ message: String) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var method:HTTPMethod = .post
        if param == nil {
            method = .get
        } else {
            method = .post
        }
        let headers: HTTPHeaders = [
            "Content-Type":"Application/json"
        ]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(param) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        }
        
        AF.request(url, method: method, parameters: param, encoder: JSONParameterEncoder.default, headers: headers, interceptor: nil).response { response in
            debugPrint(response)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    guard let data = value else {
                        Error("\(String(describing: response.error?.localizedDescription))")
                        return
                    }
                    do {
                        // let json =  try JSONSerialization.jsonObject(with: data, options: [])
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        Success(json)
                    }catch let err {
                        print(err)
                        Error("\(err.localizedDescription)")
                    }
                }else{
                    print(response.response?.statusCode ?? -1)
                    Error("\(String(describing: response.error?.localizedDescription))")
                }
            case .failure(let error):
                print(error)
                Error("\(error.localizedDescription)")
            }
        }
    }
    
    //    func uploadPhoto(_ url: String, image: UIImage, params: [String : Any], header: [String:String], completion: @escaping (JSON) -> ()) {
    //        let httpHeaders = HTTPHeaders(header)
    //        AF.upload(multipartFormData: { multiPart in
    //            for p in params {
    //                multiPart.append("\(p.value)".data(using: String.Encoding.utf8)!, withName: p.key)
    //            }
    //            multiPart.append(image.jpegData(compressionQuality: 0.4)!, withName: "avatar", fileName: "file.jpg", mimeType: "image/jpg")
    //        }, to: url, method: .post, headers: httpHeaders).responseJSON(completionHandler: { data in
    //            print("upload finished: \(data)")
    //        }).response { (response) in
    //            switch response.result {
    //            case .success(let resut):
    //                print("upload success result: \(String(describing: resut))")
    //            case .failure(let err):
    //                print("upload err: \(err)")
    //            }
    //        }
    //    }
    
    func requestMultipart<T: Decodable>(url: String, param: [String:Any]?, decodingType: T.Type, Success: @escaping (_ data: Decodable?) -> Void, Error: @escaping (_ message: String) -> Void)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var method:HTTPMethod = .post
        if param == nil {
            method = .get
        } else {
            method = .post
        }
        
//        let headers: HTTPHeaders
//        headers = ["Content-type": "multipart/form-data",
//                   "Content-Disposition" : "form-data"]
        
        AF.upload(multipartFormData: { multipartFormData in
            if param != nil {
                for (key, value) in param! {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
                }
            }
        }, to: url, usingThreshold: UInt64.init(), method: method, headers: nil, interceptor: nil).responseJSON { data in
            print(data)
        }.response { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch response.result {
            case .success(let result):
                if response.response?.statusCode == 200 {
                    guard let data = result else {
                        Error("\(String(describing: response.error?.localizedDescription))")
                        return
                    }
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        Success(genericModel)
                    }catch let err {
                        print(err)
                        Error("\(err.localizedDescription)")
                    }
                }else{
                    print(response.response?.statusCode ?? -1)
                    Error("\(String(describing: response.error?.localizedDescription))")
                }
                
            case .failure(let error):
                print(error)
                Error("\(error.localizedDescription)")
                
            }
        }
    }
}
