//
//  LocationManager+rx.swift
//  Weath
//
//  Created by Vale on 06/06/2017.
//  Copyright © 2017 tuchangwei.github.io. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

class LocationManagerDelegateProxy: DelegateProxy, DelegateProxyType, CLLocationManagerDelegate {
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let locationManager = object as! CLLocationManager
        locationManager.delegate = delegate as? CLLocationManagerDelegate
    }
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let locationManager = object as! CLLocationManager
        return locationManager.delegate
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy {
        return LocationManagerDelegateProxy.proxyForObject(base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
        .map({ parameters in
            return parameters[1] as! [CLLocation]
        })
        
    }
    
    var didChangeAuthorization: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map({ parameters in
                let raw = parameters[1] as! Int32
                return CLAuthorizationStatus(rawValue: raw)!
            })
    }
}
