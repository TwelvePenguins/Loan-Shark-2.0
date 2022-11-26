//
//  NotificationManager.swift
//  Loan Shark
//
//  Created by Ethan Lim on 26/11/22.
//

import Foundation
import UserNotifications

var manager = TransactionManager()
let allTransactions = manager.allTransactions
let allPeople = manager.contactsList
var overdueTransactions: [Transaction] = manager.allTransactions.filter {$0.transactionStatus == .overdue}

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
        var notificationFrequency = 0.0
        
        var notificationTitle = "OMG HI"
        var notificationSubtitle = "OMG BYE"
        //        var dateComponents = DateComponents()
        //        var whenToRemind = 0
        
        if overdueTransactions.count > 1 {
            notificationTitle = "Overdue transactions"
            notificationSubtitle = "You have \(String(overdueTransactions.count)) overdue transactions"
            notificationFrequency = 60.0//86400.0
            return
        }
        else if overdueTransactions.count == 1 && transaction.transactionType == .billSplitSync {
            notificationTitle = "Overdue loans"
            notificationSubtitle = "Remind \(unpaidPeople.map { $0.name! }.joined(separator: ", ")) to return you $\(amountOfMoneyUnpaid)0"
            notificationFrequency = 60.0//86400.0
            return
        }
        else if overdueTransactions.count == 1 && transaction.transactionType == .billSplitNoSync {
            for i in unpaidPeople {
                notificationTitle = "Overdue loan"
                notificationSubtitle = "Remind \(i.name!) to return you $\(i.money ?? 0)0"
                notificationFrequency = 60.0//86400.0
                return
            }
        }
        else if overdueTransactions.count == 1 && transaction.transactionType == .loan {
            notificationTitle = "Overdue loan"
            notificationSubtitle = "Remind \(overdueTransactions[0].people[0].name ?? "") to return you $\(String(overdueTransactions[0].people[0].money!))0"
            notificationFrequency = 60.0//86400.0
            return
        }
        else {
            return
        }
        content.title = notificationTitle
        content.body = notificationSubtitle
        content.sound = UNNotificationSound.default
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        
        //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents , repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationFrequency, repeats: true)
        
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


