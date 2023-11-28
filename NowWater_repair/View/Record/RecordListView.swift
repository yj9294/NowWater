//
//  RecordListView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/13.
//

import SwiftUI
import ComposableArchitecture

struct RecordListReducer: Reducer {
    struct State: Equatable {
        static func == (lhs: RecordListReducer.State, rhs: RecordListReducer.State) -> Bool {
            lhs.items == rhs.items
        }
        
        // 记录
        @UserDefault(key: "record.list")
        var recordList: [RecordModel]?
        
        var items: [[RecordModel]] = []
        
        func getItems() -> [[RecordModel]] {
            let recordList = recordList ?? []
            return recordList.reduce([]) { (result, item) -> [[RecordModel]] in
                var result = result
                if result.count == 0 {
                    result.append([item])
                } else {
                    if var arr = result.last, let lasItem = arr.last, lasItem.day == item.day  {
                        arr.append(item)
                        result[result.count - 1] = arr
                    } else {
                        result.append([item])
                    }
                }
               return result
            }
        }
    }
    
    enum Action: Equatable {
        case pop
        case onAppear
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .onAppear:
                state.items = state.getItems()
            default:
                break
            }
            return .none
        }
    }
}

struct RecordListView: View {
    let store: StoreOf<RecordListReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing:  16) {
                        ForEach(viewStore.items, id: \.self) { items in
                            getCellView(items)
                        }
                    }
                    Spacer()
                }.padding(.horizontal, 24).padding(.top, 20)
            }.background(Image("bg").resizable().scaledToFill().ignoresSafeArea()).navigationBarBackButtonHidden().navigationTitle("History Record").navigationBack {
                viewStore.send(.pop)
            }.onAppear{
                viewStore.send(.onAppear)
            }
        }
    }
    
    func getCellView(_ items: [RecordModel]) -> some View {
        return VStack(alignment: .leading){
            Text(items.first?.day ?? "").font(.system(size: 12)).foregroundColor(.black)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(items, id: \.self) { item in
                    VStack(spacing: 2){
                        item.item.icon.resizable().scaledToFit().frame(width: 40, height: 40)
                        Text(item.description).font(.system(size: 11))
                    }.padding(.vertical, 8).padding(.horizontal, 14).background(RoundedRectangle(cornerRadius: 20).strokeBorder().background(Color.white.cornerRadius(20)))
                }
            }
        }.padding(.all, 14).background(RoundedRectangle(cornerRadius: 20).strokeBorder().background(Color("#C2EEFF").cornerRadius(20)))
    }
}

struct RecordListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordListView(store: Store(initialState: RecordListReducer.State(), reducer: {
            RecordListReducer()
        }))
    }
}
