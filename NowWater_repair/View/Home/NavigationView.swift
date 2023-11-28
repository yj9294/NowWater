//
//  NavigationView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/11.
//

import ComposableArchitecture
import SwiftUI

struct NavigationReducer: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
        var home: HomeReducer.State = .init()
    }

    indirect enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
        case home(HomeReducer.Action)
        
        case loadAndShowAD(Action)
        
        case toGoalView
        case backDrinkView

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .home(action):
                switch action{
                case let .drink(drinkAction):
                    if drinkAction == DrinkReducer.Action.dailyButtonTapped {
                        return .run { send in
                            await send(.loadAndShowAD(.toGoalView))
                        }
                    }
                    if drinkAction == DrinkReducer.Action.recordButtonTapped {
                        state.path.append(.record())
                    }
                case let .charts(chartsAction):
                    if chartsAction == ChartsReducer.Action.historyButtonTapped {
                        state.path.append(.recordList())
                    }
                default:
                    break
                }
            case let .path(action):
                switch action {
                case .element(id: _, action: .goal(.pop)):
                    state.path.removeAll()
                case .element(id: _, action: .record(.pop)):
                    state.path.removeAll()
                case .element(id: _, action: .recordList(.pop)):
                    state.path.removeAll()
                case let  .element(id: id, action: .record(.saveButtonTapped)):
                    switch state.path[id: id] {
                    case .record(let recordState):
                        state.home.charts.recordList = recordState.recordList
                        state.home.drink.recordList = recordState.recordList
                    default:
                        break
                    }
                    return .run { send in
                        await send(.loadAndShowAD(.backDrinkView))
                    }
                    
                case let .element(id: id, action: .goal(_)):
                    switch state.path[id: id] {
                    case .goal(let goalState):
                        state.home.drink.total = goalState.total
                    default:
                        break
                    }
                default:
                    break
                }
            case let .loadAndShowAD(action):
                switch action {
                case .toGoalView, .backDrinkView:
                    return .run { send in
                        await GADUtil.share.load(.interstitial)
                        let model = await GADUtil.share.show(.interstitial)
                        if model == nil {
                            await send(action)
                        }
                    }
                default:
                    break
                }
                
            case .toGoalView:
                state.path.append(.goal())
            case .backDrinkView:
                state.path.removeAll()
            }
            return .none
        }.forEach(\.path, action: /Action.path) {
            Path()
        }
        
        Scope(state: \.home, action: /Action.home) {
            HomeReducer()
        }
    }

    struct Path: Reducer {
        enum State: Equatable {
            case goal(GoalReducer.State = .init())
            case record(RecordReduce.State = .init())
            case recordList(RecordListReducer.State = .init())
        }
        enum Action: Equatable {
            case goal(GoalReducer.Action)
            case record(RecordReduce.Action)
            case recordList(RecordListReducer.Action)
        }
        var body: some Reducer<State, Action> {
            Scope(state: /State.goal, action: /Action.goal) {
                GoalReducer()
            }
            Scope(state: /State.record, action: /Action.record) {
                RecordReduce()
            }
            Scope(state: /State.recordList, action: /Action.recordList) {
                RecordListReducer()
            }
        }
    }
}

struct NavigationControllerView: View {
    let store: StoreOf<NavigationReducer>
    var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            HomeView(store: store.scope(state: \.home, action: NavigationReducer.Action.home))
        } destination: {
            switch $0 {
            case .goal:
                CaseLet(/NavigationReducer.Path.State.goal, action: NavigationReducer.Path.Action.goal, then: GoalView.init(store:))
            case .record:
                CaseLet(/NavigationReducer.Path.State.record, action: NavigationReducer.Path.Action.record, then: RecordView.init(store:))
            case .recordList:
                CaseLet(/NavigationReducer.Path.State.recordList, action: NavigationReducer.Path.Action.recordList, then: RecordListView.init(store:))
            }
            
        }.navigationBarColor(Color("#97FFFB"))
    }
}


// MARK: - Previews

struct NavigationStack_Previews: PreviewProvider {
    static var previews: some View {
        NavigationControllerView(store: Store(initialState: NavigationReducer.State(), reducer: {
            NavigationReducer()
        }))
    }
}
