//
//  StepperView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI

struct StepperView<Label: View>: View {
    @Binding var value: Int
    @ViewBuilder var label: Label
        
    private let maxPassenger = 6
    
    var body: some View {
        HStack {
            label
            Spacer()
            HStack {
                Button("-") { value -= 1 }
                .padding()
                .font(.title)
                .disabled(value == 0)
                .foregroundStyle(value == 0 ? .gray : .black)

                Text(value.formatted())
                    .font(.system(size: 18, weight: .regular, design: .monospaced))
                
                Button("+") { value += 1 }
                .padding()
                .font(.title)
                .disabled(value == maxPassenger)
                .foregroundStyle(value == maxPassenger ? .gray : .black)
            }
            .foregroundColor(.black)
        }
    }
}
