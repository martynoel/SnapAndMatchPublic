// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SwiftyJSON
import URBNSwiftyModels

final class BackendController: NSObject {
    static let sharedBackendInstance = BackendController()
    var categorySelected = ""
    var shopCatalog: ShopCatalog?
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    var complementaryColor = ""
    var googleAPIKey = "AIzaSyA4aq5nsf-k3B6YWgg9rZKaSFMUwMMNY7Q"
    var urlString = "" // set by createUOSearchRequest
    
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
}

/// Image processing

extension BackendController {
    
    func analyzeResultsAndMatch(_ dataToParse: Data, completion: ((String) -> Void)? = nil) {
        
        // Update UI on the main thread
        //        DispatchQueue.main.async(execute: {
        OperationQueue.main.addOperation {
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print("There was an error")
            } else {
                
                // Parse the response
                let responses: JSON = json["responses"][0]
                
                // Get color properties
                let labelAnnotations: JSON = responses["imagePropertiesAnnotation"]["dominantColors"]
                
                print(labelAnnotations["colors"][0]["color"])
                
                if labelAnnotations.count > 0 {
                    let redRGB:Int = labelAnnotations["colors"][0]["color"]["red"].intValue
                    let greenRGB:Int = labelAnnotations["colors"][0]["color"]["green"].intValue
                    let blueRGB:Int = labelAnnotations["colors"][0]["color"]["blue"].intValue
                    
                    let colorTranslator = DBColorNames()
                    let hsv = self.rgbToComplementaryHue(r: CGFloat(redRGB)/255, g: CGFloat(greenRGB)/255, b: CGFloat(blueRGB)/255)
                    let complementaryUIColor = UIColor(hue: (hsv.h + 180).truncatingRemainder(dividingBy: 360), saturation: hsv.s, brightness: hsv.b, alpha: 1.0)
                    let complementaryColorString = colorTranslator.name(for: complementaryUIColor)
                    
                    print("UIColorTest: \(complementaryUIColor)")
                    
                    self.complementaryColor = complementaryColorString!
                    
                    completion?(complementaryColorString!)
                    print("complementaryColorString: \(complementaryColorString)")
                    print("HSV: \(hsv.h)")
                    
                }
                else {
                    print("Jack shit was found")
                }
            }
        }
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

/// Networking

extension BackendController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createGoogleVisionRequest(with imageBase64: String, completion: ((String) -> Void)?) {
        
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "IMAGE_PROPERTIES",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        self.runGoogleVisionRequest(request, completion: completion)
    }
    
    func runGoogleVisionRequest(_ request: URLRequest, completion: ((String) -> Void)? = nil) {
        
        OperationQueue.main.addOperation {
            // run the request
            let task: URLSessionDataTask = self.session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                self.analyzeResultsAndMatch(data, completion: completion)
            }
            task.resume()
        }
    }
    
    func createUOSearchRequest(_ token: String, category: String, color: String) {
        let colorQuery = color.replacingOccurrences(of: " ", with: "%20")
        urlString = "https://www.urbanoutfitters.com/api/catalog/v0/uo-us/pools/US_DIRECT/products/searches?q=" + "\(category)" + "%20" + "\(colorQuery)"
        print("------------------- URL String: \(urlString) -------------------")
        
        guard let url = URL(string: urlString) else { return }
        var searchRequest = URLRequest(url: url)
        
        print("------------------- Search request:\(searchRequest) -------------------")
        print("------------------- Token:\(token) -------------------")
        
        searchRequest.httpMethod = "GET"
        searchRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        searchRequest.addValue(token, forHTTPHeaderField: "X-Urbn-Auth-Token")
        searchRequest.addValue("ios", forHTTPHeaderField: "X-Urbn-Channel")
        searchRequest.addValue("en-US", forHTTPHeaderField: "X-Urbn-Language")
        searchRequest.addValue("USD", forHTTPHeaderField: "X-Urbn-Currency")
        
        // Run the request on a background thread
        DispatchQueue.global().async {
            self.runUORequestOnBackgroundThread(searchRequest)
        }
    }
    
    
    func runUORequestOnBackgroundThread(_ request: URLRequest) {
        
        // run the request
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                self.shopCatalog = try? ShopCatalog.decode(json)
                
                NotificationCenter.default.post(name: "ShopCatalogRequestFinished", queue: DispatchQueue.main, object: nil, userInfo: nil)
                
                // Print and everything after is for testing purposes only
                print("------------------- Shop Catalog: \(self.shopCatalog) -------------------")
                
                if let shopCatalog = self.shopCatalog {
                    for record in shopCatalog.records {
                        print(record.product.displayName)
                        print(record.product.priceInfo.listPriceLow)
                        print(record.product.defaultImage)
                        
                        //FOR URL TO UO
                        print("------------------- Product slug: \(record.product.productSlug) -------------------")
                        print("--")
                    }
                }
            }
            //            print("UO API data:\(JSON(data))")
        }
        task.resume()
    }
    
    func runAuthUORequestOnBackgroundThread(_ base64EncodedImage: String, completion: @escaping (String) -> ()) {
        
        // run the request
        
        // 1st
        var request = URLRequest(url: URL(string: "https://www.urbanoutfitters.com/api/token/v0/uo-us/auth")!)
        request.httpMethod = "POST"
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            let token = JSON(data)["authToken"].stringValue
            
            DispatchQueue.main.async {
                // Create request with base64 encoded image
                self.createGoogleVisionRequest(with: base64EncodedImage, completion: { (complementaryColor) in
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    
                    print("Complementary color: \(self.complementaryColor)")
                    
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    print("-------------------------------------------------")
                    
                    completion(complementaryColor)
                    //                    self.createUOSearchRequest(token, category: "dress", color: self.complementaryColor)
                    self.createUOSearchRequest(token, category: self.categorySelected, color: self.complementaryColor)
                    print("------------------- Category selected: \(self.categorySelected) -------------------")
                })
            }
        }
        print("runAuthUORequestOnBackgroundThread")
        task.resume()
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

/// Matching

extension BackendController {
    func rgbToComplementaryHue(r:CGFloat,g:CGFloat,b:CGFloat) -> (h:CGFloat, s:CGFloat, b:CGFloat) {
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
            if r == maxV {
                hue = (g - b) / delta
            }
            else if g == maxV {
                hue = 2 + (b - r) / delta
            }
            else {
                hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV
        return (h:((hue*360) + 180).truncatingRemainder(dividingBy: 360), s:saturation, b:brightness)
    }
}

