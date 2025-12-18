//
//  DatePickerView.swift
//  FlightSearch
//
//  Created by Gowtham on 18/12/2024.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let title: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }
}
