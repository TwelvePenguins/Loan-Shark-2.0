//
//  PersonTransactionRow.swift
//  Loan Shark
//
//  Created by Yuhan Du on 20/11/22.
//

import SwiftUI

struct PersonTransactionRow: View {
    
    @ObservedObject var manager: TransactionManager
    var transaction: Transaction
    var transactionIndex: Int {
        manager.allTransactions.firstIndex(where: {
            $0.id == transaction.id
        })!
    }
    var person: Contact
    
    @State var showTransactionDetailSheet = false
    
    var body: some View {
        let transactionPerson: Person = transaction.people.first(where: { $0.contact!.id == person.id })!
        
        Button {
            showTransactionDetailSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    if transaction.transactionStatus == .paidOff {
                        Text("Paid off")
                            .font(.caption)
                            .foregroundColor(Color("SecondaryTextColor"))
                    } else {
                        Text(getTransactionDueDate(for: transaction))
                            .font(.caption)
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                }
                Spacer()
                
                Text("$\(decimalNumberFormat.string(for: transactionPerson.money ?? 0)!)")
                    .foregroundColor(Color("PrimaryTextColor"))
                    .font(.title2)
            }
        }
        .sheet(isPresented: $showTransactionDetailSheet) {
            NavigationView {
                TransactionDetailView(manager: manager, transaction: $manager.allTransactions[transactionIndex])
            }
        }
    }
    
    func getTransactionDueDate(for transaction: Transaction) -> String {
        let dateDiff = Date.now.timeIntervalSince1970 - transaction.dueDate.timeIntervalSince1970
        let daysAgo = abs(Int(dateDiff / (60*60*24)))
        
        if transaction.isPaid == true {
            return "Paid \(daysAgo) days ago"
        } else if daysAgo == 0 && transaction.isPaid == false {
            return "Due today"
        } else if dateDiff > 0 && transaction.isPaid == false {
            return "Due in \(daysAgo) days"
        } else if dateDiff < 0 && transaction.isPaid == false {
            return "Due \(daysAgo) days ago"
        } else {
            return "No"
        }
    }
}
