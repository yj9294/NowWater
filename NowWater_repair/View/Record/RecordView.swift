//
//  RecordView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import SwiftUI
import ComposableArchitecture

struct RecordModel: Codable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var day: String // yyyy-MM-dd
    var time: String // HH:mm
    var item: RecordReduce.State.Item // 列别
    var name: String
    var ml: Int // 毫升
    
    var description: String {
        return item.title + " \(ml)ml"
    }
}

struct RecordReduce: Reducer {
    struct State: Equatable {
        static func == (lhs: RecordReduce.State, rhs: RecordReduce.State) -> Bool {
            lhs.item == rhs.item &&
            lhs.customName == rhs.customName &&
            lhs.total == rhs.total
        }
        
        // 选中/展示的类型
        var item: Item = .water
        @BindingState var total: String = "200"
        @BindingState var customName: String = Item.customization.title
        var items: [Item] = Item.allCases
        
        // 记录
        @UserDefault(key: "record.list")
        var recordList: [RecordModel]?
        
        // 是否是custom
        var isCustom: Bool {
            item == .customization
        }
        // 展示名称
        var titleStr: String {
            switch self.item {
            case .customization:
                return customName
            default:
                return item.title
            }
        }
        
        enum Item: String, Equatable, CaseIterable, Codable {
            case water, drinks, milk, coffee, tea, customization
            var icon: Image{
                return Image(self.rawValue)
            }
            var title: String{
                return self.rawValue.capitalized
            }
        }
        
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case saveButtonTapped
        case itemButtonTapped(State.Item)
        case pop
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce{ state, action in
            switch action {
            case let .itemButtonTapped(item):
                state.item = item
            case .saveButtonTapped:
                let model = RecordModel(id: UUID().uuidString,day: Date().day, time: Date().time, item: state.item, name: state.titleStr, ml: Int(state.total) ?? 200)
                var array = (state.recordList ?? [])
                array.insert(model, at: 0)
                state.recordList = array
                return .run { send in
                    await send(.pop)
                }
            default:
                break
            }
            return .none
        }
    }

}

struct RecordView: View {
    let store: StoreOf<RecordReduce>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ScrollView {
                VStack{
                    VStack{
                        HStack{
                            viewStore.item.icon.padding(.leading, 24)
                            Spacer()
                            VStack(spacing: 15){
                                ItemTextView {
                                    if viewStore.isCustom {
                                        TextField("", text: viewStore.$customName).multilineTextAlignment(.center)
                                    } else {
                                        Text(viewStore.item.title)
                                    }
                                }
                                ItemTextView{
                                    HStack {
                                        TextField("", text: viewStore.$total).keyboardDone().keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 46)
                                        Text("ml")
                                    }
                                }
                            }.padding(.vertical, 25)
                            Spacer()
                        }
                    }.background(Color("#C2EEFF").cornerRadius(20).background(RoundedRectangle(cornerRadius: 20).stroke())).padding(.horizontal, 24).padding(.top, 20)
                    VStack{
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                            ForEach(viewStore.items, id: \.self) { item in
                                HStack {
                                    Button {
                                        viewStore.send(.itemButtonTapped(item))
                                    } label: {
                                        VStack{
                                            item.icon.padding(.top, 12)
                                            Text(item.title + " 200ml").font(.system(size: 14.0)).foregroundColor(.black)
                                            Divider()
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }
                    }.background(Color.white.cornerRadius(20).background(RoundedRectangle(cornerRadius: 20).stroke())).padding(.top, 20).padding(.horizontal, 24)
                    Spacer()
                }.navigationTitle("Record").navigationBarBackButtonHidden().navigationBarRight({
                    Button(action: {
                        viewStore.send(.saveButtonTapped)
                    }, label: {
                        ZStack{
                            Image("record_button")
                            Text("Save").font(.system(size: 14)).foregroundColor(.black)
                        }
                    })
                }).navigationBack {
                    viewStore.send(.pop)
                }
            }
        }
    }
    
    struct ItemTextView<Content: View>: View {
        let content: Content
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            HStack {
                Spacer()
                content
                Spacer()
            }.padding(.vertical, 15).background(Color.white.cornerRadius(8).background(RoundedRectangle(cornerRadius: 8).stroke())).padding(.horizontal, 30)
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(store: Store(initialState: RecordReduce.State(), reducer: {
            RecordReduce()
        }))
    }
}
