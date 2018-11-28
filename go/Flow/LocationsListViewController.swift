import MapKit
import UIKit

/// Класс котроллера списка точек
class LocationsListViewController: UIViewController {
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationService = LocationService()
    let repositoryService = RepositoryService.shared
    let placesSearchController = UISearchController(searchResultsController: nil)
    var matchingItems = [MKMapItem]()
    var routeItems: [MKMapItem] {
        return repositoryService.read()
    }
    
    func searchBarIsEmpty() -> Bool {
        //returns true if the text is empty or nil
        return placesSearchController.searchBar.text?.isEmpty ?? true
    }
    func isFiltering() -> Bool {
        return placesSearchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension LocationsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() { return matchingItems.count } else { return routeItems.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var selectedItem = MKMapItem().placemark
        if isFiltering() {
            selectedItem = matchingItems[indexPath.row].placemark
        } else {
            selectedItem = routeItems[indexPath.row].placemark
        }
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = (selectedItem.subThoroughfare ?? "") + " " + (selectedItem.thoroughfare ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = matchingItems[indexPath.row]
        
        let alert = UIAlertController(title: "Добавить?",
                                      message: location.name,
                                      preferredStyle: .alert)
        let save = UIAlertAction(title: "Да", style: .default) { _ in
            self.repositoryService.create(element: location)
        }
        let cancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension LocationsListViewController: UISearchResultsUpdating {
    
    private func setupSearchBar() {
        
        placesSearchController.searchResultsUpdater = self
        placesSearchController.hidesNavigationBarDuringPresentation = false
        placesSearchController.dimsBackgroundDuringPresentation = false
        
        let searchBar = placesSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Insert address here:"
        definesPresentationContext = true
        
        
        searchBarView.addSubview(searchBar)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchBarText = searchController.searchBar.text else { return }
        
        locationService.searchLocationforAddress(address: searchBarText,
                                                 region: MapViewController.globalRegion,
                                                 completion: {[weak self] resultItems in
            if resultItems.count != 0 {
                
                self!.matchingItems = resultItems
                print("Найдено: \(self!.matchingItems.count)")
                
                self!.tableView.reloadData()
            }
        })
        self.tableView.reloadData()
    }
}
