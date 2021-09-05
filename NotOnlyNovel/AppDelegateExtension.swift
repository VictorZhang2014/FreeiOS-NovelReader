//
//  AppDelegateExtension.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/20.
//

import SwiftyStoreKit


extension AppDelegate {
    
    @objc public func handlePendingTransactionsInStoreKit() {
        _handleTransactionsStoreKit()
    }
    
    private func _handleTransactionsStoreKit() {
        // https://github.com/bizz84/SwiftyStoreKit
        // Apple建议在app启动时注册一个transaction observer
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    print("SwiftyStoreKit.completeTransactions Error while App Launching!")
                }
            }
        }
    }
    
}
