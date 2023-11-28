//
//  ChartMLView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import SwiftUI
import ComposableArchitecture

struct MLReducer: Reducer {
    struct State: Equatable {
        var items: [String] = ["0", "500", "10000", "2000", "4000"]
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

struct MLView: View {
    let store: StoreOf<MLReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 0)], alignment: .trailing, spacing: 0) {
                    ForEach(viewStore.items, id: \.self) { item in
                        Text(item).multilineTextAlignment(.trailing).font(.system(size: 12)).foregroundColor(Color("#888996")).padding(.horizontal, 14).lineLimit(1)
                            .frame(height: 46)
                    }
                }.frame(width: 60)
            }.onAppear{
                viewStore.send(.onAppear)
            }
        }
    }
}

struct MLView_Previews: PreviewProvider {
    static var previews: some View {
        MLView(store: Store(initialState: MLReducer.State(), reducer: {
            MLReducer()
        }))
    }
}
