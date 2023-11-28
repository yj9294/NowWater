//
//  LaunchView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/10.
//

import SwiftUI
import ComposableArchitecture

struct LaunchReducer: Reducer {
    @Dependency(\.continuousClock) var launchClock
    @Dependency(\.continuousClock) var adClock
    private enum CancelID {
        case progressView
        case loadingAD
    }
    
    struct State: Equatable {
        var progress = 0.0 {
            didSet {
                if progress >= 1.0 {
                    progress = 1.0
                }
            }
        }
        
        var duration = 2.5
    }
    
    enum Action: Equatable {
        case onAppear
        case onDisAppear
        case startProgress
        case stopProgress
        case update
        case launched
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.progress >= 1.0 {
                    return .none
                }
                return .run { send in
                    await send(.startProgress)
                }
            case .onDisAppear:
                return .run { send in
                    await send(.stopProgress)
                }
            case .update:
                state.progress += (0.01 / state.duration)
                if state.progress >= 1.0 {
                    return .run { send in
                        await send(.stopProgress)
                        await send(.launched)
                    }
                }
                return .none
            case .stopProgress:
                return .cancel(id: CancelID.progressView)
            case .startProgress:
                return .run { send in
                    for await _ in self.launchClock.timer(interval: .milliseconds(10)) {
                        await send(.update)
                    }
                }.cancellable(id: CancelID.progressView)
            case .launched:
                return .none
            }
        }
    }
    
}

struct LaunchView: View {
    let store: StoreOf<LaunchReducer>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack{
                Image("icon").padding(.top, 120)
                Spacer()
                VStack(spacing: 30){
                    Image("Now Water")
                    HStack{
                        ZStack(alignment: .leading){
                            Color.black
                            ProgressView(value: viewStore.progress).frame(height: 4).cornerRadius(3.5).padding(.horizontal, 2)
                        }.frame(height: 8).cornerRadius(4)
                    }.padding(.horizontal, 80).padding(.bottom, 50)
                }
            }.background(Image("bg").ignoresSafeArea()).onAppear{
                viewStore.send(.onAppear)
            }.onDisappear {
                viewStore.send(.onDisAppear)
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(store: Store(initialState: LaunchReducer.State()) {
            LaunchReducer()
        })
    }
}
