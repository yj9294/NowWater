//
//  ReminderView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

struct ReminderReducer: Reducer {
    struct State: Equatable {
        static func == (lhs: ReminderReducer.State, rhs: ReminderReducer.State) -> Bool {
            lhs.items == rhs.items
        }
        
        var items: [String] {
            (list ?? ["08:00", "10:00", "12:00", "14:00", "16:00", "18:00", "20:00"]).sorted { l1, l2 in
                l1 < l2
            }
        }
        
        @UserDefault(key: "reminder.list")
        var list: [String]?
        
        var adModel: GADNativeViewModel = .None
        
        var isNoAD: Bool {
            adModel == .None
        }
        
        var isAllowImpression: Bool {
            if Date().timeIntervalSince(impresssDate) <= 10 {
                debugPrint("[ad] reminder native ad 间隔小于10秒 ")
                return false
            } else {
                return true
            }
        }
        
        var impresssDate: Date = Date(timeIntervalSinceNow: -110)
        
        @PresentationState var alert: ReminderAlertReducer.State?
    }
    enum Action: Equatable {
        case onAppear
        case addButtonTapped
        case removeButtonTapped(String)
        case alert(PresentationAction<ReminderAlertReducer.Action>)
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .onAppear:
                state.items.forEach { item in
                    NotificationHelper.shared.appendReminder(item)
                }
            case .addButtonTapped:
                state.alert = ReminderAlertReducer.State()
            case .removeButtonTapped(let item):
                state.list = state.items.filter { $0 != item}
                NotificationHelper.shared.deleteNotifications(item)
            case let .alert(.presented(action)):
                switch action {
                case .cancelButtonTapped:
                    state.alert = nil
                case .doneButtonTapped:
                    if let date = state.alert?.date {
                        var array = state.items
                        array.append(date)
                        state.list = array
                        NotificationHelper.shared.appendReminder(date)
                    }
                    state.alert = nil
                default:
                    break
                }
            default:
                break
            }
            return .none
        }.ifLet(\.$alert, action: /Action.alert) {
            ReminderAlertReducer()
        }
    }
}

struct ReminderView: View {
    let store: StoreOf<ReminderReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                ScrollView{
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(viewStore.items, id:\.self) { item in
                            HStack{
                                Text(item).font(.system(size: 18))
                                Spacer()
                                Button {
                                    viewStore.send(.removeButtonTapped(item))
                                } label: {
                                    Image("reminder_delete").padding()
                                }
                            }.padding(.horizontal, 16).background(RoundedRectangle(cornerRadius: 8).strokeBorder())
                        }
                    }
                }.padding(.all, 20)
                HStack{
                    NativeView(model: viewStore.adModel)
                }.frame(height: viewStore.isNoAD ? 0 : 116).padding(.horizontal, 20).padding(.bottom, 100)
            }.navigationTitle("Reminder List").navigationBarRight {
                Button {
                    viewStore.send(.addButtonTapped)
                } label: {
                    Image("add")
                }
            }.onAppear{
                viewStore.send(.onAppear)
                debugPrint("[ad] reminder出现")
            }
        }.fullScreenCover(store: store.scope(state: \.$alert, action: {.alert($0)})) { store in
            ReminderAlertView(store: store).background(PresentationView(.clear))
        }
    }
    
    struct PresentationView: UIViewRepresentable {
        init(_ style: Style = .clear) {
            self.style = style
        }
        let style: Style
        func makeUIView(context: Context) -> UIView {
            if style == .blur {
                let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                DispatchQueue.main.async {
                    view.superview?.superview?.backgroundColor = .clear
                }
                return view
            } else {
                let view = UIView()
                DispatchQueue.main.async {
                    view.superview?.superview?.backgroundColor = .clear
                }
                return view
            }
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
        enum Style {
            case clear, blur
        }
    }
}

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView(store: Store(initialState: ReminderReducer.State(), reducer: {
            ReminderReducer()
        }))
    }
}
