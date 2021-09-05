//
//  LNLocalNotification.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/3/16.
//

import UIKit

@objc
class LNLocalNotification: NSObject {
    // 每天定点提醒用户，打开app，去读小说

        
    @objc func registerNotification() {
        let titles = ["📞 One Missed Call",
                      "🥰 First Kiss just like a drug",
                      "Can't Miss Out the book",
                      "CEO love me, you go away!",
                      "Just Updated"]
        
        var books: [[String:Any]] = []
        if let dataDict = LNCacheUtil().getDictValue(forKey: kBookStoreFirstPageDataKey) as? [String:Any] {
            if let _bannerArr = dataDict["banner"] as? [[String:Any]] {
                for dict in _bannerArr {
                    if let bookId = dict["book_id"], let bookName = dict["name"] {
                        books.append(["book_id": bookId, "name": bookName])
                    }
                }
            }
            // 解析top novel
            if let _topArr = dataDict["top"] as? [[String:Any]] {
                for dict in _topArr {
                    if let bookId = dict["book_id"], let bookName = dict["book_name"] {
                        books.append(["book_id": bookId, "name": bookName])
                    }
                }
            }
            // 解析best novel
            if let _bestArr = dataDict["best"] as? [[String:Any]] {
                for dict in _bestArr {
                    if let bookId = dict["book_id"], let bookName = dict["book_name"] {
                        books.append(["book_id": bookId, "name": bookName])
                    }
                }
            }
            // 解析category
            if let _categoryArr = dataDict["category"] as? [[String:Any]] {
                for dict in _categoryArr {
                    if let booksArr = dict["books"] as? [[String:Any]] {
                        for dict1 in booksArr {
                            if  let bookId = dict1["book_id"], let bookName = dict1["book_name"] {
                                books.append(["book_id": bookId, "name": bookName])
                            }
                        }
                    }
                }
            }
        }
        
        if books.count == 0 {
            return
        }
        
        // 先清空历史设置的
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = titles[Int.random(in: 0..<titles.count)]
        let bookDict = books[Int.random(in: 0..<books.count)]
        content.body = (bookDict["name"] as? String) ?? ""
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = ["type": 1, "bookId":(bookDict["book_id"] as? Int) ?? 0]
        
        // 每6个小时通知一次
        let fireDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireDate.timeIntervalSinceNow, repeats: true)
        
        let request = UNNotificationRequest(identifier: "LocalNovelsID", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let _error = error {
                print("设置本地通知失败 \(_error.localizedDescription)")
            }
        }
    }
    
    
}
