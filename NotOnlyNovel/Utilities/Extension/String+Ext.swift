//
//  String.swift
//  YoouliOS
//
//  Created by victor on 1/10/20.
//  Copyright © 2020 victor. All rights reserved.
//

import UIKit

extension String {
    
    var getStringWithoutHTML: String {
        //guard let data = self.data(using: .unicode, allowLossyConversion: true) else {
        //    return self
        //}
        guard let data = self.data(using: .utf8) else {
            return self
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
    
    func encodeUrl() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    // 删除字符串前缀
    // 比如字符串 "\n\n\n123" 那么调用是 "\n\n\n123".removePrefixString(by: "\n") 就能一下子把三个\n都能移除掉
    static func removePrefixString(by prefixChars: String, originalString: String) -> String {
        var _originalString = originalString
        if _originalString.hasPrefix(prefixChars) {
            _originalString = String(_originalString.dropFirst(prefixChars.count))
            return String.removePrefixString(by: prefixChars, originalString: _originalString)
        }
        return _originalString
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

}



extension StringProtocol {
    
    subscript(bounds: CountableClosedRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }

    subscript(bounds: CountableRange<Int>) -> SubSequence {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(start, offsetBy: bounds.count)
        return self[start..<end]
    }
    
}

