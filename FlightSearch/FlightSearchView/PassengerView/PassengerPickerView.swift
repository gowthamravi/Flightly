//
//  PassengerPickerView.swift
//  FlightSearch
//
//  Created by Gowtham on 18/12/2024.
//

import SwiftUI

struct PassengerPickerView: View {
    @Binding var passengers: Passengers
    @Binding var isPresented: Bool
    
    @State private var adults: Int
    @State private var teens: Int
    @State private var children: Int
    @State private var infants: Int
    
    init(passengers: Binding<Passengers>, isPresented: Binding<Bool>) {
        self._passengers = passengers
        self._isPresented = isPresented
        self._adults = State(initialValue: passengers.wrappedValue.adult)
        self._teens = State(initialValue: passengers.wrappedValue.teen)
        self._children = State(initialValue: passengers.wrappedValue.children)
        self._infants = State(initialValue: passengers.wrappedValue.infants)
    }
    
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
                    
                    Text("Passengers")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Done") {
                        passengers = Passengers(
                            adult: adults,
                            teen: teens,
                            children: children,
                            infants: infants
                        )
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 0) {
                        passengerRow(
                            title: "Adults",
                            subtitle: "16+ years",
                            count: $adults,
                            minValue: 1
                        )
                        
                        Divider()
                            .padding(.leading, 20)
                        
                        passengerRow(
                            title: "Teens",
                            subtitle: "12-15 years",
                            count: $teens
                        )
                        
                        Divider()
                            .padding(.leading, 20)
                        
                        passengerRow(
                            title: "Children",
                            subtitle: "2-11 years",
                            count: $children
                        )
                        
                        Divider()
                            .padding(.leading, 20)
                        
                        passengerRow(
                            title: "Infants",
                            subtitle: "Under 2",
                            count: $infants
                        )
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }
    
    private func passengerRow(
        title: String,
        subtitle: String,
        count: Binding<Int>,
        minValue: Int = 0
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    if count.wrappedValue > minValue {
                        count.wrappedValue -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(count.wrappedValue > minValue ? .blue : .gray.opacity(0.3))
                }
                .disabled(count.wrappedValue <= minValue)
                
                Text("\(count.wrappedValue)")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(minWidth: 30)
                
                Button(action: {
                    if count.wrappedValue < 9 {
                        count.wrappedValue += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(count.wrappedValue < 9 ? .blue : .gray.opacity(0.3))
                }
                .disabled(count.wrappedValue >= 9)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
