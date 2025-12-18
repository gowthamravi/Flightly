//
//  PassengersModel.swift
//  FlightSearch
//
//  Created by Gowtham on 18/12/2024.
//

import Foundation

struct Passengers {
    var adult: Int = 1
    var teen: Int = 0
    var children: Int = 0
    var infants: Int = 0
    
    var totalCount: Int {
        adult + teen + children + infants
    }
    
    var description: String {
        var parts: [String] = []
        
        if adult > 0 {
            parts.append("\(adult) Adult\(adult == 1 ? "" : "s")")
        }
        if teen > 0 {
            parts.append("\(teen) Teen\(teen == 1 ? "" : "s")")
        }
        if children > 0 {
            parts.append("\(children) Child\(children == 1 ? "" : "ren")")
        }
        if infants > 0 {
            parts.append("\(infants) Infant\(infants == 1 ? "" : "s")")
        }
        
        return parts.joined(separator: ", ")
    }
    
    var asTuple: (adult: Int, teen: Int, childrens: Int, infants: Int) {
        (adult: adult, teen: teen, childrens: children, infants: infants)
    }
    
    init(adult: Int = 1, teen: Int = 0, children: Int = 0, infants: Int = 0) {
        self.adult = adult
        self.teen = teen
        self.children = children
        self.infants = infants
    }
    
    init(from tuple: (adult: Int, teen: Int, childrens: Int, infants: Int)) {
        self.adult = tuple.adult
        self.teen = tuple.teen
        self.children = tuple.childrens
        self.infants = tuple.infants
    }
}
