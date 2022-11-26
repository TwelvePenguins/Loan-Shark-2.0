//
//  DecimalTextField.swift
//  Loan Shark
//
//  Created by Yuhan Du on 26/11/22.
//
import SwiftUI

struct DecimalTextField: View {

    @Binding var amount: Double?

    var hint: String

    @State var text = ""
    @State var previousValue = ""

    var body: some View {
        TextField(hint, text: $text) {
            let number = decimalNumberFormat.string(for: amount ?? 0)!
            text = number
        }
        .keyboardType(.decimalPad)
        .onAppear {
            let number = decimalNumberFormat.string(for: amount ?? 0)!
            text = number
            previousValue = text
        }
        .onChange(of: text) { newValue in
            if newValue.isEmpty {
                amount = 0
                previousValue = newValue
            } else if let newNumber = Double(newValue) {
                amount = newNumber
                previousValue = newValue
            } else {
                text = previousValue
            }
        }
    }
}
