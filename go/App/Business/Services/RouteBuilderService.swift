//
//  RouteBuilderService.swift
//  MapKitTestAPP
//
//  Created by rushan adelshin on 20.11.2018.
//  Copyright © 2018 Eldar Adelshin. All rights reserved.
//

import Foundation
import MapKit

class RouteBuilderService {
    
    
    var orderedRouteArray = [MKRoute: MKMapItem]()
    
    func buildRouteSegment(sourceItem: MKMapItem, destinationItem: MKMapItem) -> MKRoute {
        var quickestRoute = MKRoute()
        let request:MKDirections.Request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {(response: MKDirections.Response?, error: Error?) -> Void in
            if let routeResponse = response?.routes {
                let quickestRouteForSegment: MKRoute = routeResponse.sorted(by: {$0.expectedTravelTime < $1.expectedTravelTime})[0]
                quickestRoute = quickestRouteForSegment
            } else if let _ = error {
                print(error?.localizedDescription ?? "UNKNOWN ERROR")
            }
        })
        return quickestRoute
    }
    
    func buildRouteFromSeqments(startLocation:MKMapItem, routeLocations: [MKMapItem]) -> [MKRoute] {
        
        let nonorderedRouteItems: [MKMapItem] = routeLocations
        
        //массив стартовых точек
        var startItems = [MKMapItem]()
        startItems.append(startLocation)
        //массив конечных точек
        var endItems = [MKMapItem]()
        for item in nonorderedRouteItems { endItems.append(item) }
        //массив участков маршрута
        var orderedRoute = [MKRoute]()
        
        while endItems.count != 0 {
            
            for startItem in startItems {
                print("calculating routes for start position: \(startItem.name ?? "нет имени")...")
                var routes = [MKRoute]()
                var routesDict = [MKRoute:  MKMapItem]()
                for endItem in endItems {
                    routes.append(buildRouteSegment(sourceItem: startItem, destinationItem: endItem))
                    routesDict[buildRouteSegment(sourceItem: startItem, destinationItem: endItem)] = endItem
                    print("route option: \(startItem.name ?? "нет имени") -> \(endItem.name ?? "нет имени") was built")
                }
                let fastestRoute = routes.sorted(by: {$0.distance < $1.distance})[0]
                print("fastest route option is: \(fastestRoute.name)")
                //Находим в нашем словаре MapItem и добавляем его в начальные точки.
                if routesDict[fastestRoute] != nil { startItems.append(routesDict[fastestRoute]!)}
                //И удаляем его из конечных точек маршрута
                endItems = endItems.filter{ $0 != routesDict[fastestRoute] }
                orderedRoute.append(fastestRoute)
                print("----------------------------------------------------------------")
            }
        }
        return orderedRoute
    }
}
