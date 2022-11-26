//
//  TransactionDetailView.swift
//  Loan Shark
//
//  Created by Ethan Lim on 15/11/22.
// ...

import SwiftUI
import UIKit

struct TransactionDetailView: View {
    
    @ObservedObject var manager: TransactionManager
    @Binding var transaction: Transaction
    @State var presentEditTransactionSheet = false
    @State var showDeleteAlert = false
    @State var reload = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if transaction.transactionType == .loan {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Loan")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                } else if transaction.transactionType == .billSplitSync {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Bill split, synchronised")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                } else if transaction.transactionType == .billSplitNoSync {
                    HStack {
                        Button {
                            transaction.isNotificationEnabled.toggle()
                            reload.toggle()
                            transaction.isNotificationEnabled ? removeNotification(for: transaction) : addNotification(for: transaction)
                        } label: {
                            Image(systemName: transaction.isNotificationEnabled ? "bell.fill" : "bell.slash")
                                .foregroundColor(transaction.isNotificationEnabled ? Color("AccentColor")  :Color("AccentColor2"))
                        }
                        Text("Bill split, unsynchronised")
                        Spacer()
                        Text("$" + String(format: "%.2f", transaction.totalMoney))
                    }
                    .padding(.horizontal)
                }
            }
            
            List {
                Section("UNPAID") {
                    ForEach($transaction.people) { $person in
                        if !person.hasPaid {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(person.name ?? "No one Selected")
                                            .bold()
                                            .foregroundColor(Color("PrimaryTextColor"))
                                            .font(.title3)
                                        HStack(alignment: .center, spacing: 0) {
                                            Text(transaction.transactionStatus == .overdue ? "Due " : "Due in ")
                                                .foregroundColor(Color("SecondaryTextColor"))
                                            Text(person.dueDate!, style: .relative)
                                                .foregroundColor(Color("SecondaryTextColor"))
                                            if transaction.transactionStatus == .overdue {
                                                Text(" ago")
                                                    .foregroundColor(Color("SecondaryTextColor"))
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("$ \(String(format: "%.2f", person.money!))")
                                        .foregroundColor(transaction.transactionStatus == .overdue ? Color("RadRed") : Color("PrimaryTextColor"))
                                        .font(.title2)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                }
                                .padding(.top, 5)
                                HStack(alignment: .top){
                                    SendMessageButton(transaction: transaction, person: person)
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            person.hasPaid.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "banknote")
                                            Text("Mark as paid")
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(Color("AccentColor"))
                                .padding(5)
                            }
                        }
                    }
                }
                Section("PAID") {
                    ForEach($transaction.people) { $person in
                        if person.hasPaid {
                            VStack{
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(person.name ?? "No one Selected")
                                            .bold()
                                            .foregroundColor(Color("PrimaryTextColor"))
                                            .font(.title3)
                                    }
                                    Spacer()
                                    Text("$ \(String(format: "%.2f", person.money!))")
                                        .foregroundStyle(.secondary)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                        .font(.title2)
                                }
                                .padding(.top, 5)
                                HStack(alignment: .top){
                                    Button {
                                        withAnimation {
                                            person.hasPaid.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "banknote")
                                            Text("Mark as unpaid")
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(Color("AccentColor"))
                                    .padding(5)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(transaction.name)
            .toolbar {
                Button {
                    presentEditTransactionSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                    }
                }
                .foregroundColor(Color("AccentColor"))
                .sheet(isPresented: $presentEditTransactionSheet) {
                    EditTransactionView(transaction: $transaction)
                }
                Button {
                    showDeleteAlert = true
                } label: {
                    HStack{
                        Image(systemName: "trash.fill")
                    }
                    .foregroundColor(Color("RadRed"))
                    .alert("Are you sure you want to delete this transaction?", isPresented: $showDeleteAlert, actions: {
                        Button(role: .cancel) {
                            
                        } label: {
                            Text("Cancel")
                        }
                        
                        Button(role: .destructive) {
                            if let transactionIndex = manager.allTransactions.firstIndex(where: {
                                $0.id == transaction.id
                            }) {
                                manager.allTransactions.remove(at: transactionIndex)
                            }
                        } label: {
                            Text("Delete")
                        }
                    }, message: {
                        Text("This action cannot be undone.")
                    })
                }
            }
        }
    }
    func removeNotification(for transaction: Transaction) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [transaction.id.uuidString])
        print("HV: Notification is" + String(transaction.isNotificationEnabled))
    }
    
    func addNotification(for transaction: Transaction) {
        let center = UNUserNotificationCenter.current()
        let sendNotification = transaction.isNotificationEnabled
        let addRequest = {
            let content = UNMutableNotificationContent()
            var unpaidPeople: [Person]
            var peopleWhoPaid: [Person]
            var amountOfMoneyUnpaid: Double
            var overdueTransactions: [Transaction]
            if !transaction.isNotificationEnabled || transaction.transactionStatus != .overdue {
                return
            } else {
                unpaidPeople = transaction.people.filter { $0.hasPaid == false }
                peopleWhoPaid = transaction.people.filter{$0.hasPaid}
                
                func amountOfMoneyPaid() -> Double {
                    var u = 0.0
                    for i in peopleWhoPaid {
                        u += i.money!
                    }
                    return u
                }
                amountOfMoneyUnpaid = transaction.totalMoney - amountOfMoneyPaid()
                overdueTransactions = manager.allTransactions.filter {$0.transactionStatus == .overdue && $0.isNotificationEnabled}
            }
            if overdueTransactions.count == 0 {
                return
            }
            else if overdueTransactions.count > 1 {
                content.title = "Overdue transactions"
                content.subtitle = "You have \(overdueTransactions.count) overdue transactions"
            }
            else if overdueTransactions.count == 1 && transaction.transactionType == .billSplitNoSync || transaction.transactionType == .billSplitSync {
                content.title = "Overdue loans"
                content.subtitle = "Remind \(unpaidPeople.map { $0.name! }.joined(separator: ", ")) to return you \(amountOfMoneyUnpaid)"
            }
            else if overdueTransactions.count == 1 && transaction.transactionType == .loan {
                content.title = "Overdue loan"
                content.subtitle = "Remind \(overdueTransactions[0].people[0].name ?? "") to return you $\(String(format: ".%2f", overdueTransactions[0].people[0].money!))"
            }
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 7
            
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents , repeats: true)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
            
            let request = UNNotificationRequest(identifier: transaction.id.uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        center.getNotificationSettings{ settings in
            if settings.authorizationStatus == .authorized && sendNotification {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                        print("HV: Notification is" + String(transaction.isNotificationEnabled))
                    } else {
                        print("Skill issue")
                    }
                }
            }
        }
    }
}
