//
//  ContentView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/10.
//

import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
    
    struct State: Equatable {
        var launch: LaunchReducer.State = .init()
        var home: NavigationReducer.State = .init()
        
        var item: Item = .launch
        
        enum Item: Equatable {
            case launch, root
        }
        
        var isLaunching: Bool {
            return item == .launch
        }
    }

    enum Action: Equatable {
        case item(State.Item)
        
        case launch(LaunchReducer.Action)
        case home(NavigationReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.launch, action: /Action.launch) {
            LaunchReducer()
        }
        Scope(state: \.home, action: /Action.home) {
            NavigationReducer()
        }
        Reduce { state, action in
            switch action {
            case let .item(item):
                state.item = item
                switch state.item {
                case .launch:
                    state.launch.progress = 0.0
                    state.launch.duration = 14.0
                default:
                    break
                }
            case let .launch(action):
                if action == .launched, state.launch.progress >= 1.0 {
                    return .run { send in
                        await send(.item(.root))
                    }
                }
            default:break
            }
            return .none
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppReducer>
    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            VStack{
                if viewStore.isLaunching {
                    LaunchView(store: store.scope(state: \.launch, action: AppReducer.Action.launch))
                } else {
                    NavigationControllerView(store: store.scope(state: \.home, action: AppReducer.Action.home))
                }
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewStore.send(.item(.launch))
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            }
        }
    }
}

