//
//  StationRow.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct StationRow: View {
    let station: Station?
    
    var body: some View {
        let name = station?.name ?? ""
        let countryName = station?.country ?? ""
        let code = station?.code ?? ""

        HStack {
            VStack(alignment: .leading) {
                
                Text(name)
                    .font(.title)
                    .foregroundStyle(.indigo)
                Text(countryName)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text(code)
                .font(.callout)
        }
    }
}
