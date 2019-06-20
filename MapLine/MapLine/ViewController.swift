//
//  ViewController.swift
//  MapLine
//
//  Created by 藤治仁 on 2019/06/20.
//  Copyright © 2019 FromF.github.com. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.global(qos: .default).async {
            if let viewPos = self.searchPostion(searchKey: "皇居") ,
                let pos1 = self.searchPostion(searchKey: "東京駅") ,
                let pos2 =  self.searchPostion(searchKey: "水道橋駅") ,
                let pos3 = self.searchPostion(searchKey: "市ケ谷駅") ,
                let pos4 = self.searchPostion(searchKey: "国会議事堂") {
                // 東京駅→水道橋駅→市ヶ谷駅→国会議事堂を結ぶ線を引く
                let coordinates = [pos1 , pos2 , pos3 , pos4 , pos1]
                let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
                DispatchQueue.main.async {
                    // 皇居を中心にして半径500mの範囲を表示
                    self.mapView.region = MKCoordinateRegion(center: viewPos, latitudinalMeters: 5000.0, longitudinalMeters: 5000.0)
                    // mapViewに線を置く
                    self.mapView.addOverlay(polyLine)
                }
            }
        }
    }
    
    /// キーワードに基づいた緯度経度を検索する
    private func searchPostion(searchKey:String) -> CLLocationCoordinate2D? {
        var result:CLLocationCoordinate2D?
        let semaphore = DispatchSemaphore(value: 0)
        print(searchKey)
        
        // CLGeocoderインスタンを取得
        let geocoder = CLGeocoder()
        
        // 入力された文字から位置情報を取得(
        geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
            
            // 位置情報が存在する場合はunwrapPlacemarksに取り出す(7)
            if let unwrapPlacemarks = placemarks {
                
                // 1件目の情報を取り出す
                if let firstPlacemark = unwrapPlacemarks.first {
                    
                    // 位置情報を取り出す
                    if let location = firstPlacemark.location {
                        
                        // 位置情報から緯度経度をtargetCoordinateに取り出す(10)
                        result = location.coordinate
                        
                        // 緯度経度をデバッグエリアに表示
                        if let result = result {
                            print(result)
                        }
                    }
                }
            }
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 2.0
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}

