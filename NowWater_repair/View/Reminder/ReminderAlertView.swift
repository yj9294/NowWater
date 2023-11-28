//
//  ReminderAlertView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/13.
//

import SwiftUI
import ComposableArchitecture

struct ReminderAlertReducer: Reducer {
    struct State: Equatable {
        @BindingState var date: String = "00:00"
        var alpha = 0.0
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case cancelButtonTapped
        case doneButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce{ state, action in
            if action == .onAppear {
                withAnimation {
                    state.alpha = 0.5
                }
            }
            return .none
        }
    }
}

struct ReminderAlertView: View {
    let store: StoreOf<ReminderAlertReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                Spacer()
                VStack{
                    HStack{
                        Text("Set Reminder").padding(.top, 20).padding(.leading, 20).font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    DatePickerView(date: viewStore.$date).background(Color("#ECEDEE").cornerRadius(18))
                    HStack{
                        Spacer()
                        Button {
                            viewStore.send(.cancelButtonTapped)
                        } label: {
                            Text("Cancel").font(.system(size: 16)).foregroundColor(Color("#D1D1D1")).padding(.vertical, 13).padding(.horizontal, 36)
                        }.background(RoundedRectangle(cornerRadius: 8).stroke(Color("#D1D1D1")))
                        Spacer()
                        Button {
                            viewStore.send(.doneButtonTapped)
                        } label: {
                            Text("Done").font(.system(size: 16)).foregroundColor(.black).padding(.vertical, 13).padding(.horizontal, 40)
                        }.background(RoundedRectangle(cornerRadius: 8).stroke().background(Color("#4ECCFC").cornerRadius(8)))
                        Spacer()
                    }.padding(.vertical, 32).padding(.horizontal, 20)
                }.background(Color.white.cornerRadius(20)).padding(.horizontal, 20)
                Spacer()
            }.background(Color.black.opacity(viewStore.alpha)).onAppear{
                viewStore.send(.onAppear)
            }
        }
    }
}

struct ReminderAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderAlertView(store: Store(initialState: ReminderAlertReducer.State(), reducer: {
            ReminderAlertReducer()
        }))
    }
}
