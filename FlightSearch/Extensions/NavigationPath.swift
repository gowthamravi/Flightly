//
//  NavigationPath.swift
//  FlightSearch
//
//  Created by Gowtham R on 28/02/24.
//

import Foundation
import SwiftUI

class Router: ObservableObject {
    @Published var path = NavigationPath()
    static let shared: Router = Router()

    func show<V>(_ viewType: V.Type) where V: View {
        path.append(String(describing: viewType.self))
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

