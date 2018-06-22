//
//  UISearchController.swift
//  Table
//
//  Created by Bradley Hilton on 3/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

private class SearchResultsUpdating : NSObject, UISearchResultsUpdating {
    
    var lastSearchResult: String?
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchResult = searchController.searchBar.text.flatMap { !$0.isEmpty ? $0 : nil }
        if searchResult != lastSearchResult {
            lastSearchResult = searchResult
            searchController.didSearch?(searchResult)
        }
    }
    
}

extension UISearchController {
    
    public var didSearch: ((String?) -> ())? {
        get {
            return storage[\.didSearch]
        }
        set {
            storage[\.didSearch] = newValue
            searchResultsUpdater = defaultSearchResultsUpdater
        }
    }
    
    private var defaultSearchResultsUpdater: UISearchResultsUpdating {
        return storage[\.defaultSearchResultsUpdater, default: SearchResultsUpdating()]
    }
    
}
