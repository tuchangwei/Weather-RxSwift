//
//  API.swift
//  Weath
//
//  Created by Vale on 06/06/2017.
//  Copyright © 2017 tuchangwei.github.io. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
class API: NSObject {
    struct Weather {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
        let weatherDesc: String
        
        static let empty = Weather(
            temp: 0,
            temp_min: 0,
            temp_max: 0,
            weatherDesc: "Clear"
        )
    }
    
    static var shared = API()
    private let apiKey = "663a9d3e01af8d7720720703c3aab2e7"
    let baseURLStr = "http://api.openweathermap.org/data/2.5/weather"
    
    func requestWeather(lat: Double, lon: Double) -> Observable<Weather> {
        let urlStr = baseURLStr + "?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request).map{ JSON(data:$0)}.map({ (json) -> Weather in
            
            print(json["weather"][0]["main"].string)
            return Weather(temp: json["main"]["temp"].double ?? 0,
                           temp_min: json["main"]["temp_min"].double ?? 0,
                           temp_max: json["main"]["temp_max"].double ?? 0,
                           weatherDesc: json["weather"][0]["main"].string ?? "Clear")
            
            
        })
    }
    
}
