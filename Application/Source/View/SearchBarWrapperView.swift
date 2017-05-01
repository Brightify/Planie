//
//  SearchBarWrapperView.swift
//  TravelPlanner
//
//  Created by Tadeáš Kříž on 08/09/16.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import Lipstick

/**
 This view is needed because of a bug in UIKit's UISearchBar. When using with scopes, its behavior was wrong:
 1) When activated, the tableView's content was hidden behind the scope bar.
 2) When deactivated, the UISearchBar disappeared completely from the UITableView.

 Also, this view cannot use constraints, because the UISearchBar is being manipulated by the UISearchController and
 constraints break this. That's is why this view extends UIView and not ViewBase.
 */
final class SearchBarWrapperView: UIView {
    
    var scopeSelected: Observable<TripFilterScope> {
        return scope.rx.value.map {
            TripFilterScope.allScopes.indices.contains($0) ? TripFilterScope.allScopes[$0] : .all
        }
    }

    var searchBarTop: CGFloat {
        return searchBar.frame.origin.y
    }

    var searchBarCenterVertical: CGFloat {
        return searchBarTop + searchBar.frame.height / 2
    }

    var searchBarBottom: CGFloat {
        return searchBarTop + searchBar.frame.height
    }

    var scopeBarCenterVertical: CGFloat {
        return scope.frame.origin.y + scope.frame.height / 2
    }

    var scopeBarBottom: CGFloat {
        return bounds.height
    }

    private let searchBar: UISearchBar
    private let scope = UISegmentedControl(items: TripFilterScope.allScopes.map { $0.localizedDescription })
    private let scopePadding: CGFloat = 8


    init(searchBar: UISearchBar) {
        self.searchBar = searchBar

        super.init(frame: CGRect(size: CGSize(width: 0, height: 0)))

        loadView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadView() {
        addSubview(searchBar)
        addSubview(scope)

        backgroundColor = Colors.accent
        scope.tintColor = .white
        scope.selectedSegmentIndex = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bounds.size.width = searchBar.bounds.width
        bounds.size.height = searchBar.bounds.height + scope.bounds.height + 2 * scopePadding

        scope.frame.size.width = bounds.width - 2 * scopePadding

        searchBar.frame.origin = CGPoint(x: 0, y: 0)
        scope.frame.origin = CGPoint(x: scopePadding, y: searchBar.frame.height + scopePadding)
    }
}
