//
//  ChartContentView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/13.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ChartsContentReducer: Reducer {
    struct State: Equatable {
        var items: [ChartsModel] = []
    }
    enum Action: Equatable {
        case onAppear
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
    
}

struct ChartsContentView: View {
    let store: StoreOf<ChartsContentReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible(), spacing: 0)], alignment: .bottom, spacing: 0) {
                        ForEach(viewStore.items) { item in
                            VStack(spacing: 0) {
                                ChartsContentProgressView(item.progress, h: proxy.size.height - 35 - 23).padding(.horizontal, 16).padding(.bottom, 23)
                                Text(item.unit).font(.system(size: 12)).frame(height: 35)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ChartsContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsContentView(store: Store(initialState: ChartsContentReducer.State(items: [
            ChartsModel(progress: 0.3, totalML: 2000, unit: "0:00~6:00"),

        ]), reducer: {
            ChartsContentReducer()
        }))
    }
}
