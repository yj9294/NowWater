//
//  ChartsView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

struct ChartsModel: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var displayProgerss: CGFloat = 0.0
    var progress: CGFloat
    var totalML: Int
    var unit: String // 描述 类似 9:00 或者 Mon  或者03/01 或者 Jan
}

struct ChartsReducer: Reducer {
    struct State: Equatable {
        
        static func == (lhs: ChartsReducer.State, rhs: ChartsReducer.State) -> Bool {
            lhs.recordList == rhs.recordList &&
            lhs.top == rhs.top &&
            lhs.ml == rhs.ml &&
            lhs.content == rhs.content
        }
        
        // 记录
        @UserDefault(key: "record.list")
        var recordList: [RecordModel]?
        
        var top: TopBarReducer.State = .init()
        var ml: MLReducer.State = .init()
        var content: ChartsContentReducer.State = .init()
        var adModel: GADNativeViewModel = .None
        var isNoAD: Bool {
            adModel == .None
        }
        var isAllowImpression: Bool {
            if Date().timeIntervalSince(impresssDate) <= 10 {
                debugPrint("[ad] charts native ad 间隔小于10秒 ")
                return false
            } else {
                return true
            }
        }
        var impresssDate: Date = Date(timeIntervalSinceNow: -11)
    }
    
    enum Action: Equatable {
        case historyButtonTapped
        case onAppear
        case top(TopBarReducer.Action)
        case ml(MLReducer.Action)
        case content(ChartsContentReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case let .top(action):
                switch action {
                case let .itemSelected(item):
                    state.ml = .init(items: getMLBarData(with: item))
                    state.content = .init(items: getContentData(item, with: state))
                    break
                }
            case .onAppear:
                return .run{ send in
                    await send(.top(.itemSelected(.day)))
                }
            default:
                break
            }
            return .none
        }
        Scope(state: \.ml, action: /Action.ml) {
            MLReducer()
        }
        Scope(state: \.top, action: /Action.top) {
            TopBarReducer()
        }
        Scope(state: \.content, action: /Action.content) {
            ChartsContentReducer()
        }
    }
    
    
    func getMLBarData(with item: TopBarReducer.State.Item) -> [String] {
        let source: [Int] = Array(0..<7).reversed()
        var target: [String] = []
        switch item {
        case .day:
             target = source.map({
                "\($0 * 100)"
            })
        case .week, .month:
            target = source.map({
               "\($0 * 500)"
           })
        case .year:
            target = source.map({
               "\($0 * 500 * 30 / 1000)L"
           })
        }
        return target
    }
    
    func getContentData(_ item: TopBarReducer.State.Item, with state: State) -> [ChartsModel] {
        var max = 1
        // 用于计算最大值
        let mlList = getMLBarData(with: item)
        // 数据源
        let recordList: [RecordModel] = state.recordList ?? []
        // 用于计算进度
        if item != .year {
            max = mlList.map({Int($0) ?? 0}).max { l1, l2 in
                l1 < l2
            } ?? 1
        } else {
            max = mlList.compactMap { str in
                var stg = str
                stg.removeLast()
                return Int(stg) ?? 0
            }.max { l1, l2 in
                l1 < l2
            } ?? 1
        }

        switch item {
        case .day:
            let array = item.unit.map({ time in
                let total = recordList.filter { model in
                    let modelTime = model.time.components(separatedBy: ":").first ?? "00"
                    let nowTime = time.components(separatedBy: "-").first ?? "00"
                    return Date().day == model.day && (Int(modelTime)! >= Int(nowTime)!) && (Int(modelTime)! < Int(nowTime)! + 6)
                }.map({
                    $0.ml
                }).reduce(0, +)
                return ChartsModel(progress: Double(total)  / Double(max) , totalML: total, unit: time)
            })
            return array
        case .week:
            return item.unit.map { weeks in
                // 当前搜索目的周几 需要从周日开始作为下标0开始的 所以 unit数组必须是7123456
                let week = TopBarReducer.State.Item.allCases.filter {
                    $0 == .week
                }.first?.unit.firstIndex(of: weeks) ?? 0
                
                // 当前日期 用于确定当前周
                let weekDay = Calendar.current.component(.weekday, from: Date())
                let firstCalendar = Calendar.current.date(byAdding: .day, value: 1-weekDay, to: Date()) ?? Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                // 目标日期
                let target = Calendar.current.date(byAdding: .day, value: week, to: firstCalendar) ?? Date()
                let targetString = dateFormatter.string(from: target)
                
                let total = recordList.filter { model in
                    model.day == targetString
                }.map({
                    $0.ml
                }).reduce(0, +)
                return ChartsModel(progress: Double(total)  / Double(max), totalML: total, unit: weeks)
            }
        case .month:
            return item.unit.reversed().map { date in
                let year = Calendar.current.component(.year, from: Date())
                
                let month = date.components(separatedBy: "/").first ?? "01"
                let day = date.components(separatedBy: "/").last ?? "01"
                
                let total = recordList.filter { model in
                    return model.day == "\(year)-\(month)-\(day)"
                }.map({
                    $0.ml
                }).reduce(0, +)
                
                return ChartsModel(progress: Double(total)  / Double(max), totalML: total, unit: date)

            }
        case .year:
            return  item.unit.reversed().map { month in
                let total = recordList.filter { model in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let date = formatter.date(from: model.day)
                    formatter.dateFormat = "MMM"
                    let m = formatter.string(from: date!)
                    return m == month
                }.map({
                    $0.ml
                }).reduce(0, +)
                return ChartsModel(progress: Double(total)  / Double(max * 1000), totalML: total, unit: month)

            }
        }
    }
}

struct ChartsView: View {
    let store: StoreOf<ChartsReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                ScrollView{
                    VStack{
                        HStack{Spacer()}
                        TopBarView(store: store.scope(state: \.top, action: ChartsReducer.Action.top))
                        VStack(spacing: 0) {
                            ZStack(alignment: .bottom) {
                                HStack(alignment: .top,spacing: 0){
                                    MLView(store: store.scope(state: \.ml, action: ChartsReducer.Action.ml))
                                    Image("divider_hor").resizable().scaledToFill().frame(width: 1).padding(.bottom, 35)
                                    ChartsContentView(store: store.scope(state: \.content, action: ChartsReducer.Action.content))
                                    Spacer()
                                }.frame(height: 46*7 + 35)
                                VStack {
                                    Image("divider_ver").resizable().scaledToFill().frame(height: 1)
                                }.padding(.leading, 60).padding(.trailing, 10).padding(.bottom, 35)
                            }.padding(.vertical, 10)
                            
                        }.padding(.bottom, 24)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 20).stroke()).padding(.horizontal, 16).padding(.top, 20)
                Spacer()
                HStack{
                    NativeView(model: viewStore.adModel)
                }.frame(height: viewStore.isNoAD ? 0 : 116).padding(.horizontal, 20).padding(.vertical, 15).padding(.bottom, 100)
            }.navigationTitle("Statistics").navigationBarRight {
                Button {
                    viewStore.send(.historyButtonTapped)
                } label: {
                    Image("charts_history")
                }
            }.onAppear{
                viewStore.send(.onAppear)
                debugPrint("[ad] charts出现")
            }
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(store: Store(initialState: ChartsReducer.State(), reducer: {
            ChartsReducer()
        }))
        .previewDevice("iPhone 14 Pro Max")
    }
}
