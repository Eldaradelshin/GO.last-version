import Foundation
import MapKit

private let UDRouteKey = "route"

/// Реализация хранилища данных на основе UserDefaults
final class RepositoryService {
    
    static let shared = RepositoryService()
    
    private init() {}
    
    // MARK: - Fields
    
    private lazy var elements: [MKMapItem] = {
        
        guard let data = UserDefaults.standard.data(forKey: UDRouteKey) else {
            return [MKMapItem]()
        }
        
        // swiftlint:disable next force_cast
        do {
            let array = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [MKMapItem.self], from: data)
            return array as! [MKMapItem]
        } catch {
            print(error)
            return [MKMapItem]()
        }
        
    }()
    
    
    // MARK: - Functions
    
    func read() -> [MKMapItem] {
        return elements
    }
    
    func create(element: MKMapItem) {
        
        if !elements.contains(element) {
            elements.append(element)
        }
        
        save()
    }
    
    func update(element: MKMapItem) -> Bool {
    
        return true
    }
    
    func delete(element: MKMapItem) -> Bool {
        
        if let index = elements.firstIndex(where: { $0 == element }) {
            
            elements.remove(at: index)
            save()
            
            return true
        }
        
        return false
    }
    
    fileprivate func save() {
        
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: elements,
                                                              requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UDRouteKey)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
