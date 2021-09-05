//
//  FNCoinPurchaseProductModel.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2020/11/11.
//

import HandyJSON


class LNCoinPurchaseProductModel: HandyJSON {

    var productId: String?
    var productName: String?
    var save: String?
    var bonus: String?
    var price: String?
    
    var coins: Int = 0
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.productId <-- "product_id"
        mapper <<< self.productName <-- "product_name"
    }
    
    required init() { }
    
}






enum LNCoinTransactionType : Int, HandyJSONEnum {
    case none = 0
    case topUp = 1
    case purchaseChapters = 2
    case earnCoinsByPlayingVideo = 3
}

class LNCoinTransactionModel: HandyJSON {
    
    var transactionType: LNCoinTransactionType = .none
    
    var coins: Int = 0
    var userId: Int = 0
    var createTime: String?
    
    var productId: String?
    var appstoreTransactionId: String?
    var purchaseDate: String?
    
    var chapterId: Int = 0
    var bookName: String?
    var chapterName: String?
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.transactionType <-- "transaction_type"
        
        mapper <<< self.userId <-- "user_id"
        mapper <<< self.createTime <-- "create_time"
        
        mapper <<< self.productId <-- "product_id"
        mapper <<< self.appstoreTransactionId <-- "appstore_transaction_id"
        mapper <<< self.purchaseDate <-- "purchase_date"
        
        mapper <<< self.chapterId <-- "chapter_id"
        mapper <<< self.bookName <-- "book_name"
        mapper <<< self.chapterName <-- "chapter_name"
    }
    
    required init() { }
    
}
