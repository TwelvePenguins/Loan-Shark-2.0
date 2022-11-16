//
//  Loan Shark.swift
//  Loan Shark
//
//  Created by Ethan Lim on 6/11/22.
//

import Foundation
import SwiftUI


enum TransactionTypes: Codable {
    case unselected
    case billSplitSync
    case billSplitNoSync
    case loan
}

enum TransactionStatus: Int, Codable {
    case overdue
    case dueInOneWeek
    case unpaid
    case paidOff
}

struct Contact: Codable, Identifiable {
    var id = UUID()
    var name: String
}
class Person: Identifiable, Codable {
    var id = UUID()
    var name: String
    var money: Double
    var dueDate: Date
    var hasPaid = false
    var selected = false
    
    init(id: UUID = UUID(), name: String, money: Double, dueDate: String, hasPaid: Bool = false, selected: Bool = false) {
        self.id = id
        self.name = name
        self.money = money
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"

        self.dueDate = dateFormatter.date(from: dueDate)!
        self.hasPaid = hasPaid
        self.selected = selected
    }
}

class Transaction: Identifiable, Codable {
    var id = UUID()
    var name: String
    var people: [Person]
    var dueDate: Date {
        if people.count == 1{
            return people[0].dueDate
        } else { return Date.now }
    }
    var isPaid: Bool {
        if people.count == 1 {
            return people[0].hasPaid
        } else { return false }
    }
    
    var transactionStatus: TransactionStatus {
        if isPaid {
            return .paidOff
        }
        else if Date.now > dueDate && !isPaid {
            return .overdue
        }
        else if abs(dueDate.timeIntervalSinceNow) <= 604800 && !isPaid{
            return .dueInOneWeek
        }
        else {
            return .unpaid
        }
    }
    var transactionType: TransactionTypes
    
    var totalMoney: Double {
        if people.count == 1{
            return people[0].money
        } else { return 0}
    }
    
    init(id: UUID = UUID(), name: String, people: [Person], transactionType: TransactionTypes) {
        self.id = id
        self.name = name
        self.people = people
        self.transactionType = transactionType
    }
}

