//
//  Button+Extension.swift
//  FlightSearch
//
//  Created by Gowtham R on 29/02/24.
//

import Foundation
import SwiftUI

struct FlightlyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color(red: 238/255, green: 119/255, blue: 70/255))
            .clipShape(Capsule())
            .font(.custom("Avenir-HeavyOblique", size: 20))
            .padding()
        
    }
}
