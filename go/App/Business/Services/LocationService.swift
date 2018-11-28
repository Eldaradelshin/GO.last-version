import Foundation
import MapKit

final class LocationService {
    
    func searchLocationforQuery(query: String,
                                region: MKCoordinateRegion,
                                completion: @escaping ([MKMapItem]) -> Void) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { response, error in
            
            if let results = response {
                if let err = error {
                    print("Error in search: \(err.localizedDescription)")
                } else if results.mapItems.count == 0 {
                    print("No matches found.")
                } else {
                    print("Matches found.")
                    let items = results.mapItems
                    completion(items)
                }
            }
        })
    }
    
    func searchLocationforAddress(address: String,
                                  region: MKCoordinateRegion,
                                  completion: @escaping ([MKMapItem]) -> Void) {
        
        self.searchLocationforQuery(query: address,
                                    region: region,
                                    completion: { resultLocations  in
                                        
            completion(resultLocations)
        })
    }
}
