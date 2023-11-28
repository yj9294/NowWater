//
//  NavigationBar.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import Foundation
import SwiftUI
import UIKit

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
    var titleColor: UIColor?

    init(backgroundColor: Color?, titleColor: Color?) {
        self.backgroundColor = UIColor(backgroundColor ?? .black)
        self.titleColor = UIColor(color: titleColor ?? .clear)
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = self.backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: self.titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: self.titleColor ?? .white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIToolbar.appearance().barTintColor = self.backgroundColor
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(uiColor: self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

struct NavigationTitleModifiler: ViewModifier {
    let title: String
    func body(content: Content) -> some View {
        content.navigationBarTitleDisplayMode(.inline).toolbar {
            ToolbarItem(placement: .principal) {
                Text(title).font(.system(size: 25, weight: .bold))
            }
        }
    }
}

struct NavigationBarLeftModifiler: ViewModifier {
    let action: ()->Void
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    action()
                } label: {
                    Image("back")
                }
            }
        }
    }
}

struct NavigationBarRigtModifier<V: View>: ViewModifier {
    let rightView: V
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                rightView
            }
        }
    }
}

extension View {

    func navigationBarColor(_ backgroundColor: Color? = .clear, titleColor: Color? = .black) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }

    func navigationTitle(_ title: String) -> some View {
        self.modifier(NavigationTitleModifiler(title: title))
    }
    
    func navigationBack(_ action: @escaping ()->Void) -> some View {
        self.modifier(NavigationBarLeftModifiler(action: action))
    }
    
    func navigationBarRight<V: View>(_ view: ()->V) -> some View {
        self.modifier(NavigationBarRigtModifier(rightView: view()))
    }
}
