//
//  HomeView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/10.
//

import SwiftUI
import ComposableArchitecture

struct HomeReducer: Reducer {
    struct State: Equatable {
        // 当前选中状态
        var item: Item = .drink
        enum Item: String, Equatable {
            case drink, charts, reminder
            var icon: Image {
                return Image("home_" + self.rawValue)
            }
        }
        var isDrink: Bool {
            item == .drink
        }
        var isCharts: Bool {
            item == .charts
        }
        var isReminder: Bool {
            item == .reminder
        }
        // 子页->主页状态
        var drink: DrinkReducer.State = .init()
        var charts: ChartsReducer.State = .init()
        var reminder: ReminderReducer.State = .init()
    }
    
    enum Action: Equatable {
        case item(State.Item)
        
        case drink(DrinkReducer.Action)
        case charts(ChartsReducer.Action)
        case reminder(ReminderReducer.Action)
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .item(item):
                if item == state.item {
                    return .none
                }
                state.item = item
            default:
                break
            }
            return .none
        }
        
        Scope(state: \.drink, action: /Action.drink) {
            DrinkReducer()
        }
        Scope(state: \.charts, action: /Action.charts) {
            ChartsReducer()
        }
        Scope(state: \.reminder, action: /Action.reminder) {
            ReminderReducer()
        }
    }
    
    func isNeedLoadNativeAD(_ state: State) -> Bool {
        switch state.item {
        case .drink:
            return state.drink.isAllowImpression
        case .charts:
            return state.charts.isAllowImpression
        case .reminder:
            return state.reminder.isAllowImpression
        }
    }
}

struct HomeView: View {
    let store: StoreOf<HomeReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ZStack {
                contentView(with: viewStore.item)
                VStack{
                    HStack{Spacer()}
                    Spacer()
                    HStack{
                        HStack{
                            TabbarItem(store: store, item: .drink)
                            Spacer()
                            TabbarItem(store: store, item: .charts)
                            Spacer()
                            TabbarItem(store: store, item: .reminder)
                        }.padding(.horizontal, 20).background(Image("tabbar_bg").resizable().scaledToFill())
                    }.frame(height: 60).padding(.horizontal, 24).padding(.bottom, 20)
                }
            }.onAppear {
                viewStore.send(.item(viewStore.item))
//                viewStore.send(.preLoadAD)
            }
        }
    }
    
    struct TabbarItem: View {
        let store: StoreOf<HomeReducer>
        let item: HomeReducer.State.Item
        var body: some View {
            WithViewStore(store, observe: {$0}) { viewStore in
                Button {
                    if viewStore.item != item {
                        viewStore.send(.item(item))
//                        viewStore.send(.preLoadAD)
                    }
                } label: {
                    Image(viewStore.item == item ? "home_\(item.rawValue)_1" : "home_\(item.rawValue)")
                }.frame(width: 70)
            }
        }
    }
    
    func contentView(with item: HomeReducer.State.Item) -> some View {
        VStack {
            switch item {
            case .drink:
                DrinkView(store: store.scope(state: \.drink, action: HomeReducer.Action.drink))
            case .charts:
                ChartsView(store: store.scope(state: \.charts, action: HomeReducer.Action.charts))
            case .reminder:
                ReminderView(store: store.scope(state: \.reminder, action: HomeReducer.Action.reminder))
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Store(initialState: HomeReducer.State(), reducer: {
            HomeReducer()
        }))
    }
}
