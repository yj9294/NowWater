//
//  KeyboardHelper.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func keyboardDone() -> some View {
        return self.toolbar(content: {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hiddenKeyboard()
                } label: {
                    Text("Done")
                }
            }
        })
    }
}

extension View {
    /// 关闭键盘事件
    func hiddenKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
