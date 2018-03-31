//
//  UISearchController.swift
//  Table
//
//  Created by Bradley Hilton on 3/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

private class SearchControllerDelegate : NSObject, UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.isBeingPresentedOrDismissed = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.isBeingPresentedOrDismissed = false
        searchController.activityDidChange?(searchController.isActive)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.isBeingPresentedOrDismissed = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.isBeingPresentedOrDismissed = false
        searchController.activityDidChange?(searchController.isActive)
    }
    
}

private class SearchResultsUpdating : NSObject, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.didSearch?(searchController.searchBar.text.flatMap { !$0.isEmpty ? $0 : nil })
    }
    
}

extension UISearchController {
    
    public fileprivate(set) var isBeingPresentedOrDismissed: Bool {
        get {
            delegate = defaultDelegate
            return storage[\.isBeingPresentedOrDismissed, default: false]
        }
        set {
            storage[\.isBeingPresentedOrDismissed] = newValue
        }
    }
    
    public var activityDidChange: ((_ isActive: Bool) -> ())? {
        get {
            return storage[\.activityDidChange]
        }
        set {
            storage[\.activityDidChange] = newValue
            delegate = defaultDelegate
        }
    }
    
    public var didSearch: ((String?) -> ())? {
        get {
            return storage[\.didSearch]
        }
        set {
            storage[\.didSearch] = newValue
            searchResultsUpdater = defaultSearchResultsUpdater
            delegate = defaultDelegate
        }
    }
    
    private var defaultDelegate: SearchControllerDelegate {
        return storage[\.defaultDelegate, default: SearchControllerDelegate()]
    }
    
    private var defaultSearchResultsUpdater: UISearchResultsUpdating {
        return storage[\.defaultSearchResultsUpdater, default: SearchResultsUpdating()]
    }
    
}
