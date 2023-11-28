//
//  DrinkView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

struct DrinkReducer: Reducer {
    struct State: Equatable {
        static func == (lhs: DrinkReducer.State, rhs: DrinkReducer.State) -> Bool {
            lhs.totalML == rhs.totalML &&
            lhs.todayML == rhs.todayML &&
            lhs.adModel == rhs.adModel
        }
        
        var adModel: GADNativeViewModel = .None
        var isNoAD: Bool {
            adModel == .None
        }
        var isAllowImpression: Bool {
            if Date().timeIntervalSince(impresssDate) <= 10 {
                debugPrint("[ad] drink native ad 间隔小于10秒 ")
                return false
            } else {
                return true
            }
        }
        
        var impresssDate: Date = Date(timeIntervalSinceNow: -11)
        
        @UserDefault(key: "drink.total")
        var total: Int?

        @UserDefault(key: "record.list")
        var recordList: [RecordModel]?
        
        var totalML: Int {
            return total ?? 2000
        }
        var todayML: Int {
            (recordList ?? []).filter { model in
                model.day == Date().day
            }.map({
                $0.ml
            }).reduce(0, +)
        }
        var progress: Double {
            Double(todayML) / Double(totalML)
        }
        var progressString: String{
            "\(Int(progress * 100))"
        }
    }
    
    enum Action: Equatable {
        case recordButtonTapped
        case dailyButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}


struct DrinkView: View {
    let store: StoreOf<DrinkReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ScrollView {
                VStack(spacing: 0){
                    HStack{
                        NativeView(model: viewStore.adModel)
                    }.frame(height: viewStore.isNoAD ? 0 : 116).padding(.horizontal, 20).padding(.top, 15)
                    VStack{
                        ZStack{
                            Image("home_content")
                            VStack(spacing: 15){
                                Button {
                                    viewStore.send(.dailyButtonTapped)
                                } label: {
                                    HStack{
                                        Image("home_edit")
                                        Text("Daily Goal \(viewStore.totalML)ml")
                                    }.padding(.vertical, 16).padding(.horizontal, 22).background(Color("#FFF5B6").cornerRadius(8).background(RoundedRectangle(cornerRadius: 8).stroke()
                                    ))
                                }.padding(.horizontal, 70).font(.system(size: 16, weight: .semibold)).foregroundColor(Color.black)
                                ZStack{
                                    Image("home_circle")
                                    CircleView(progress: viewStore.progress).frame(width: 200, height: 200)
                                    Image("home_circle_1")
                                    VStack{
                                        Text(viewStore.progressString + "%").font(.system(size: 31, weight: .semibold))
                                        Text("\(viewStore.todayML)ml").foregroundColor(Color("#CFCED5"))
                                    }
                                }
                                Button {
                                    viewStore.send(.recordButtonTapped)
                                } label: {
                                    HStack{
                                        Spacer()
                                        Image("home_add")
                                        Text("Record").font(.system(size: 20, weight: .medium))
                                        Spacer()
                                    }.padding(.vertical, 15).background(Color("#4ECCFC").cornerRadius(30).background(RoundedRectangle(cornerRadius: 30).stroke()))
                                }.padding(.horizontal, 56).foregroundColor(Color.black)
                            }
                        }
                    }.padding(.top, 14).padding(.horizontal, 10)
                    VStack{
                        HStack{Spacer()}
                    }.frame(height: 104)
                }
            }.background(Image("home_bg").resizable().scaledToFill().ignoresSafeArea()).navigationTitle("Drink").onAppear{
                debugPrint("[ad] drink出现")
            }
        }
    }
}

struct DrinkView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkView(store: Store(initialState: DrinkReducer.State(), reducer: {
            DrinkReducer()
        }))
    }
}
