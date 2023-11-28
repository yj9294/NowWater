//
//  DataPickerView.swift
//  NowWater
//
//  Created by yangjian on 2023/10/13.
//


import SwiftUI

struct DatePickerView: UIViewRepresentable {
    @Binding var date: String
    func makeUIView(context: Context) -> some UIView {
        let view = UIPickerView()
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinatior {
        Coordinatior(self)
    }
    
    class Coordinatior: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let presentView: DatePickerView
        var hours: [String] = []
        var minutes: [String] = []
        var selectHour: String = "00"
        var selectMin: String = "00"
        
        init(_ view: DatePickerView) {
            presentView = view
            for index in 0..<24 {
                hours.append(String(format: "%02d", index))
            }
            
            for index in 0..<60 {
                minutes.append(String(format: "%02d", index))
            }
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return hours.count
            } else {
                return minutes.count
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return ((pickerView.bounds.width  - 40 - 48 ) / 2.0 )
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return hours[row]
            } else {
                return minutes[row]
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 56.0
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            var text: String = ""
            if component == 0 {
                text = hours[row]
            } else {
                text = minutes[row]
            }
            let string  = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36, weight: .bold)])
            
            let label = UILabel()
            label.textAlignment = .center
            label.attributedText = string
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                selectHour = hours[row]
            } else {
                selectMin = minutes[row]
            }
            presentView.date = "\(selectHour):\(selectMin)"
        }
    }
}
