////
////  ActivityIndicator.swift
////  FlightSearch
////
////  Created by Gowtham R on 12/02/24.
////
//
//import SwiftUI
//
//struct ActivityIndicator: View {
//    
//    @State private var isAnimating: Bool = false
//    
//    var body: some View {
//        GeometryReader { (geometry: GeometryProxy) in
//            ForEach(0..<5) { index in
//                Group {
//                    Circle()
//                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
//                        .scaleEffect(calcScale(index: index))
//                        .offset(y: calcYOffset(geometry))
//                }.frame(width: geometry.size.width, height: geometry.size.height)
//                    .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
//                    .animation(Animation
//                        .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
//                        .repeatForever(autoreverses: false))
//            }
//        }
//        .aspectRatio(1, contentMode: .fit)
//        .onAppear {
//            self.isAnimating = true
//        }
//    }
//    
//    func calcScale(index: Int) -> CGFloat {
//        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
//    }
//    
//    func calcYOffset(_ geometry: GeometryProxy) -> CGFloat {
//        return geometry.size.width / 10 - geometry.size.height / 2
//    }
//    
//}
//
//#Preview {
//    Blinking(isAnimating: true, count: 20, size: 100)
//}
//
//
//struct Blinking: View {
//    @Binding var isAnimating: Bool
//    let count: UInt
//    let size: CGFloat
//
//    var body: some View {
//        GeometryReader { geometry in
//            ForEach(0..<Int(count)) { index in
//                item(forIndex: index, in: geometry.size)
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//
//            }
//        }
//        .aspectRatio(contentMode: .fit)
//    }
//
//    private func item(forIndex index: Int, in geometrySize: CGSize) -> some View {
//        let angle = 2 * CGFloat.pi / CGFloat(count) * CGFloat(index)
//        let x = (geometrySize.width/2 - size/2) * cos(angle)
//        let y = (geometrySize.height/2 - size/2) * sin(angle)
//        return Circle()
//            .frame(width: size, height: size)
//            .scaleEffect(isAnimating ? 0.5 : 1)
//            .opacity(isAnimating ? 0.25 : 1)
//            .animation(
//                Animation
//                    .default
//                    .repeatCount(isAnimating ? .max : 1, autoreverses: true)
//                    .delay(Double(index) / Double(count) / 2)
//            )
//            .offset(x: x, y: y)
//    }
//}
