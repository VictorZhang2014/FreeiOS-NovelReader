//
//  FNBookrackDataModel.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2020/10/7.
//

import UIKit
import HandyJSON


enum LNBannerActionType: Int, HandyJSONEnum {
    case none = -1
    case book = 0
    case web = 1
    case earnCoins = 2
}

// 商城首页 -> 顶部banner
class LNBookStoreBannerModel: HandyJSON {
    
    var bookId: Int?
    var name: String?
    var actionType : LNBannerActionType = .none
    var bannerImageUrl: String?
    var introduction: String?
    var link: String?
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.bookId <-- "book_id"
        mapper <<< self.actionType <-- "action_type"
        mapper <<< self.bannerImageUrl <-- "banner_image_url"
    }
    
}


// 商城首页 -> 通用书籍介绍
// 例如：top级的，best级的书籍模型
class LNBookStoreItemIntroModel: HandyJSON {

    var categoryName: String?
    var bookCover: String?
    var bookName: String?
    var authorName: String?
    var viewCount: String?
    var tags: String?
    var bookId: Int = 0
    
    var tmpBookCoverImage: UIImage? // 临时存储书籍封面图
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.categoryName <-- "category_name"
        mapper <<< self.bookCover <-- "book_cover"
        mapper <<< self.bookName <-- "book_name"
        mapper <<< self.authorName <-- "author_name"
        mapper <<< self.viewCount <-- "view_count"
        mapper <<< self.bookId <-- "book_id"
    }
    
}


// 商城首页 -> 书籍多分类
// 例如：不管有多少个分类书籍都可以自动解析
class LNBookStoreCategoryItemIntroModel: HandyJSON {

    var categoryName: String?
    var books: [LNBookStoreItemIntroModel] = []
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.categoryName <-- "category_name"
    }
    
}


// 小说介绍model
class LNBookItemIntroModel: HandyJSON {

    var bookId: Int = 0
    var bookName: String?
    var author: String?
    var introduction: String?
    var ratings: Float = 0
    var bookCover: String?
    var labels: [String] = []
    var primaryLabel: String?
    var chapterCount: Int = 0
    var viewCount: Int = 0
    var totalWords: Int = 0
    var writeStatus: String?
    var firstChapterId: Int = 0
    
    var introductionHeight: CGFloat = 0 // 书介绍的高度
    var introductionCollapse: Bool = true // 是否缩起介绍
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.bookId <-- "book_id"
        mapper <<< self.bookName <-- "book_name"
        mapper <<< self.bookCover <-- "book_cover"
        mapper <<< self.primaryLabel <-- "primary_label"
        mapper <<< self.chapterCount <-- "chapter_count"
        mapper <<< self.viewCount <-- "view_count"
        mapper <<< self.totalWords <-- "total_words"
        mapper <<< self.writeStatus <-- "write_status"
        mapper <<< self.firstChapterId <-- "first_chapter_id"
    }
    
    public func totalCountDisPlay() -> String {
        if self.totalWords > 10000 {
            let total : Float = Float(self.totalWords) / 10000
            return String(format: "%.1fK", total)
        }
        return String(format: "%d", self.totalWords)
    }
    
}


// 书的章节
class LNBookChapterModel: HandyJSON {

    public var id: Int = 0
    public var chapterName: String?
    public var isLock: Bool = false
    
    public var isReading: Bool = false // 当前正在阅读的章节
    
    public var haveRead: Bool = false // 已经阅读了此章节
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.chapterName <-- "chapter_name"
        mapper <<< self.isLock <-- "is_lock"
    }
    
}


// 书的每章节详情
class LNBookChapterDetailModel: HandyJSON {

    var chapterId: Int = 0
    var bookId: Int = 0
    var chapterName: String?
    var content: String?
    var prevChapterId: Int = 0
    var nextChapterId: Int = 0
    var coins: Int = 0
    var wordNum: Int = 0
    var isPaid: Bool = false
    var maxChapterId: Int = 0
    var minChapterId: Int = 0
    
    var isCurrentReading: Bool = false // 是否当前正在读的章节
    
    var headerTitleDesc: String?
    var footerTitleDesc: String?
    
    // 文本长度 : 文本内容的数组
    //var charLengthAndPageTextArray: [[Int:String]] = [] // 弃用
    // 每章节平均占用百分比进度
    //var everyPagePercentile: Float = 0.0 // 弃用
    
    
    required public init() { }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.chapterId <-- "chapter_id"
        mapper <<< self.bookId <-- "book_id"
        mapper <<< self.chapterName <-- "chapter_name"
        mapper <<< self.prevChapterId <-- "prev_chapter_id"
        mapper <<< self.nextChapterId <-- "next_chapter_id"
        mapper <<< self.wordNum <-- "word_num"
        mapper <<< self.isPaid <-- "is_paid"
        mapper <<< self.maxChapterId <-- "max_chapter_id"
        mapper <<< self.minChapterId <-- "min_chapter_id"
    }
    
}





// 小说书架 model
class LNBookrackItemModel: HandyJSON {

    var bookId: Int = 0
    var chapterCount: Int = 0
    var bookCover: String?
    var bookName: String?
    var authorName: String?
    var labels: String?
    var lastChapterId: Int = 0
    var progress: Int = 0
    var updatetime: String?
    
    required public init() { }
    
}
