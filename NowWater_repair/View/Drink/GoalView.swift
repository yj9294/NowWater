//
//  GoalView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

struct GoalReducer: Reducer {
    
    struct State: Equatable {
        static func == (lhs: GoalReducer.State, rhs: GoalReducer.State) -> Bool {
            lhs.total == rhs.total
        }
        
        @UserDefault(key: "drink.total")
        var total: Int?
        
        var totalML: Int {
            total ?? 2000
        }
    }
    enum Action: Equatable {
        case reduceButtonTapped
        case decreaseButtonTapped
        case pop
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .reduceButtonTapped:
                state.total = state.totalML + 100
                if state.total! > 4000 {
                    state.total = 4000
                }
            case .decreaseButtonTapped:
                state.total = state.totalML - 100
                if state.total! < 100 {
                    state.total = 100
                }
            default:break
            }
            return .none
        }
    }
}

struct GoalView: View {
    let store: StoreOf<GoalReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                HStack{
                    Image("total_bottle")
                    Spacer()
                    Spacer()
                    VStack(spacing: 40){
                        Button {
                            viewStore.send(.reduceButtonTapped)
                        } label: {
                            Image("total_reduce").padding(.horizontal, 30).padding(.vertical, 35)
                        }.background(Color.black.cornerRadius(12))
                        Text("\(viewStore.totalML)ml").font(.system(size: 30, weight: .medium))
                        Button {
                            viewStore.send(.decreaseButtonTapped)
                        } label: {
                            Image("total_decrease").padding(.horizontal, 30).padding(.vertical, 42)
                        }.background(Color("#E3E3E3").cornerRadius(12))
                    }
                    Spacer()
                }.padding(.top, 47).padding(.horizontal, 50)
                Text("Your daily water goal：\(viewStore.totalML)ml").foregroundColor(.black).font(.system(size: 17, weight: .medium)).padding(.top, 55)
                Spacer()
            }.navigationTitle("Water Intake").navigationBack({
                viewStore.send(.pop)
            }).navigationBarBackButtonHidden()
        }
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(store: Store(initialState: GoalReducer.State(), reducer: {
            GoalReducer()
        }))
    }
}
