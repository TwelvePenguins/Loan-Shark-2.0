//
//  TransactionRowView.swift
//  Loan Shark
//
//  Created by Yuhan Du on 20/11/22.
//

import SwiftUI

struct TransactionRowView: View {
    
    @ObservedObject var manager: TransactionManager
    @Binding var transaction: Transaction
    @State var reload = false
    
    var body: some View {
        NavigationLink {
            TransactionDetailView(manager: manager, transaction: $transaction)
        } label: {
            HStack {
                VStack (alignment: .leading) {
                    Text(transaction.name)
                        .foregroundColor(transaction.transactionStatus == .paidOff ? .gray : Color("PrimaryTextColor"))
                    Text(findPeopleWhoNeverPay())
                        .font(.caption)
                        .foregroundColor(transaction.transactionStatus == .paidOff ? .gray : Color("SecondaryTextColor"))
                }
                Spacer()
                Text("$" + String(format: "%.2f", moneyCalculator()))
                    .foregroundColor(transaction.transactionStatus == .overdue ? Color("RadRed") : Color("PrimaryTextColor"))
                    .bold()
            }
        }
    }
    func findPeopleWhoNeverPay() -> String {
        let s = transaction.people.filter { !$0.hasPaid }
        let t = String(s.map { $0.name! }.joined(separator: ", "))
        let r = String(transaction.people.map {$0.name!}.joined(separator: ", "))
        if !s.isEmpty {
            return t
        } else {
            return r
        }
    }
    func moneyCalculator() -> Double {
        let s = transaction.people.filter{ !$0.hasPaid }
        let t = s.map {$0.money}
        let r = transaction.people.map {$0.money}
        var u = 0.0
        
        if !t.isEmpty {
            u = t.reduce(into: 0.00) { partialResult, person in
                partialResult += (person ?? 0)
            }
        }
        else {
            u = r.reduce(into: 0.00) { partialResult, person in
                partialResult += (person ?? 0)
            }
        }
        return u
    }
}
