//
//  TopBarView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct TopBarReducer: Reducer {
    struct State: Equatable {
        var item: Item = .day
        let items:[Item] = Item.allCases
        enum Item: String, CaseIterable {
            case day, week, month, year
            var title: String {
                self.rawValue.capitalized
            }
            var unit: [String] {
                switch self {
                case .day:
                    return ["0-6", "6-12", "12-18", "18-24"]
                case .week:
                    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                case .month:
                    var days: [String] = []
                    for index in 0..<30 {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd"
                        let date = Date(timeIntervalSinceNow: TimeInterval(index * 24 * 60 * 60 * -1))
                        let day = formatter.string(from: date)
                        days.insert(day, at: 0)
                    }
                    return days
                case .year:
                    var months: [String] = []
                    for index in 0..<12 {
                        let d = Calendar.current.date(byAdding: .month, value: -index, to: Date()) ?? Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM"
                        let day = formatter.string(from: d)
                        months.insert(day, at: 0)
                    }
                    return months
                }
            }
        }
        func isItemSelected(_ item: Item) -> Bool {
            item == self.item
        }
    }
    enum Action: Equatable {
        case itemSelected(State.Item)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .itemSelected(let item):
                state.item = item
            }
            return .none
        }
    }
}

struct TopBarView: View {
    let store: StoreOf<TopBarReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            HStack{
                LazyHGrid(rows: [GridItem(.flexible())]) {
                    ForEach(viewStore.items, id: \.self) { item in
                        VStack(alignment: .leading){
                            Button {
                                viewStore.send(.itemSelected(item))
                            } label: {
                                ItemView(item == viewStore.item) {
                                    Text(item.title).font(.system(size:14)).padding(.vertical, 8).padding(.horizontal, 18)
                                }
                            }
                        }
                    }
                }.padding(.top, 8)
            }
        }.padding(.horizontal, 8).frame(height: 60)
    }
}

struct ItemView<Content: View>: View {
    let isSelected: Bool
    let content: Content
    init(_ isSelected: Bool, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSelected = isSelected
    }
    var body: some View {
        if isSelected {
            content.foregroundColor(Color.black).background(Color("#4ECCFC").cornerRadius(18).background(RoundedRectangle(cornerRadius: 18).stroke()))
        } else {
            content.foregroundColor(Color("#D1D1D1")).background(Color.white.cornerRadius(18).background(RoundedRectangle(cornerRadius: 18).stroke(Color("#D1D1D1"))))
        }
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(store: Store(initialState: TopBarReducer.State(), reducer: {
            TopBarReducer()
        }))
    }
}
