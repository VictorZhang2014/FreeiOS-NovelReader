//
//  LNReaderDetailWaterFallCollectionViewFlowLayout.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/4.
//

import UIKit

/*
class LNReaderDetailWaterFallCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var currentIndex: Int = 0
    
    override init() {
        super.init()
         scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        self.itemSize = UIScreen.main.bounds.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
*/

class LNReadingDetailCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var currentIndex: Int = 0
    
    override init() {
        super.init() 
        scrollDirection = .vertical
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        self.itemSize = UIScreen.main.bounds.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
