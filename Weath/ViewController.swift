//
//  ViewController.swift
//  Weath
//
//  Created by Vale on 06/06/2017.
//  Copyright © 2017 tuchangwei.github.io. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx
class ViewController: UIViewController {
    @IBOutlet weak var noNetworkLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var bgImgView: UIImageView!
    
    let locationManager =  CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        locationManager.distanceFilter = 3000
        locationManager.rx.didChangeAuthorization.subscribe(onNext: { status in
            if status == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            } else if status == .authorizedWhenInUse || status == .authorizedAlways   {
                self.locationManager.startUpdatingLocation()
            } else if status == .denied || status == .restricted {
                self.showAlert("Please grant Location permissions in Settings app", title: "No Location Permission", okHandler: { (_) in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                })
            }
        }).addDisposableTo(rx_disposeBag)
       
        let location = locationManager.rx.didUpdateLocations.map({ locations in
            return locations[0]
        })
        
        let tap =  refreshBtn.rx.tap.asObservable().startWith(())
        let weather = Observable.combineLatest(location,tap) { (o1, o2) -> CLLocation in
            return o1
            }.throttle(0.5, scheduler: MainScheduler.instance)
            .flatMapLatest { location in
                return API.shared.requestWeather(lat: location.coordinate.latitude,
                                                 lon: location.coordinate.longitude)
                    .catchErrorJustReturn(API.Weather.empty)
            }.shareReplay(1)
        
        weather.map { $0.temp != 0 }.bind(to: noNetworkLabel.rx.isHidden).addDisposableTo(rx_disposeBag)
        weather.map { "\($0.temp)°" }.bind(to: currentTempLabel.rx.text).addDisposableTo(rx_disposeBag)
        weather.map { "\($0.temp_min)°" }.bind(to: lowTempLabel.rx.text).addDisposableTo(rx_disposeBag)
        weather.map { "\($0.temp_max)°" }.bind(to: highTempLabel.rx.text).addDisposableTo(rx_disposeBag)
        weather.map { UIImage(named:$0.weatherDesc) ?? UIImage(named:"Clear") }.bind(to:bgImgView.rx.image).addDisposableTo(rx_disposeBag)
        
        
    }
    func showAlert(_ message:String, title:String, okHandler: @escaping ((UIAlertAction)->Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: okHandler)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }

}
