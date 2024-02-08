//
//  ContentUnAvailableCustomView.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct ContentUnAvailableCustomView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ContentUnavailableView(label: {
            Label("Oops!", systemImage: "tray.fill")
        }, description: {
            Text("There are no destination Station. \n Choose a different Country to Visit.")
        }, actions: {
            Button {
                isPresented.toggle()
            } label: {
                Text("Go back")
                    .customBoarderStyle()
            }
        })
        .navigationBarBackButtonHidden(true)
    }
}
