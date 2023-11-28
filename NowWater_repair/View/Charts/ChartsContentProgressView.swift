//
//  ChartContentProgressView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/13.
//

import Foundation
import SwiftUI

struct ChartsContentProgressView: View {
    init(_ progress: Double, h: CGFloat) {
        self.progress = progress
        self.h = h
    }
    var h: CGFloat = 0.0
    var progress: Double = 0.0 {
        didSet {
            if progress > 1.0 {
                progress = 1.0
            }
            if progress <= 0 {
                progress = 0
            }
            if progress.isNaN {
                progress = 0
            }
        }
    }
    var body: some View {
        VStack{
            let floatCount = h * progress / 12.0
            let count = Int(ceil(floatCount))
            Spacer()
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0)], spacing: 0) {
                ForEach(0..<count, id: \.self) { index in
                    VStack(spacing: 0){
                        Color.white.frame(height: 8)
                        Color("#24B6BF").frame(height: 4).cornerRadius(2)
                    }.frame(height: 12).opacity( 0.4 + 0.6 / Double(count) * Double(index))
                }
            }.frame(height: 12 * CGFloat(count))
        }.frame(width: 20)
    }
}

struct ChartsContentProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsContentProgressView(0.5, h: 250)
    }
}

