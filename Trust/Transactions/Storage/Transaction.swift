// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var owner: String = ""
    @objc dynamic var chainID: Int = 1
    @objc dynamic var blockNumber: Int = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gas = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasUsed = ""
    @objc dynamic var nonce: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var isError: Bool = false

    convenience init(
        id: String,
        owner: String,
        chainID: Int,
        blockNumber: Int,
        from: String,
        to: String,
        value: String,
        gas: String,
        gasPrice: String,
        gasUsed: String,
        nonce: String,
        date: Date,
        isError: Bool
    ) {
        self.init()
        self.id = id
        self.owner = owner
        self.chainID = chainID
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.value = value
        self.gas = gas
        self.gasPrice = gasPrice
        self.gasUsed = gasUsed
        self.nonce = nonce
        self.date = date
        self.isError = isError
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Transaction {
    var direction: TransactionDirection {
        if owner == from { return .outgoing }
        return .incoming
    }
}
