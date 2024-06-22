//
//  HLocationViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/22.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HLocationPoint: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}

class HLocationViewController: HBaseViewController {
    
    let locationPoint: HLocationPoint
    init(locationPoint: HLocationPoint) {
        self.locationPoint = locationPoint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarBackgroundView.image = nil
        
        view.insertSubview(mapView, belowSubview: navBar)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadData()
    }
    
    func loadData() {
        var theRegion = MKCoordinateRegion()
        theRegion.center = locationPoint.coordinate
        theRegion.span.longitudeDelta = 0.01
        theRegion.span.latitudeDelta = 0.01
        mapView.addAnnotation(locationPoint)
        mapView.setRegion(theRegion, animated: true)
    }
}
