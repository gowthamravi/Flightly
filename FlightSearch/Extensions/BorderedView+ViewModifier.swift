//
//  BorderedView+ViewModifier.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import Foundation
import SwiftUI

struct BorderedView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
            .foregroundStyle(.blue)
            .border(.blue)
    }
}

extension View {
    func customBoarderStyle() -> some View {
        modifier(BorderedView())
    }
}
