//
//  FNFMDBManager.h
//  NotOnlyNovel
//
//  Created by JohnnyZhang on 11/21/20.
//  Copyright © 2020 JohnnyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
 
@interface LNFMDBManager : NSObject

+ (instancetype)shared;


//-------------------------------------- table = FNLastReadingChapter -------------------------------------- begin
// 添加最后阅读的章节
- (void)addToLastReadingChapterTableWithBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId pageIndex:(NSInteger)pageIndex;
// 查询最后阅读的章节
- (NSArray<NSNumber *> *)getLastReadingChapterFromBookId:(NSInteger)bookId;
//-------------------------------------- table = FNLastReadingChapter -------------------------------------- end



//-------------------------------------- table = FNHaveReadChapter  已经阅读过的章节 -------------------------------------- begin
- (void)addingHaveReadChapterIntoTableWithBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId;
- (NSArray<NSNumber *> *)getHaveReadChapterIdsBookId:(NSInteger)bookId;
//-------------------------------------- table = FNHaveReadChapter -------------------------------------- end



//-------------------------------------- table = LNBookrackBooks  添加到书架 -------------------------------------- begin
- (void)addBookToBookrackWithBookId:(NSInteger)bookId
                       chapterCount:(NSInteger)chapterCount
                          bookCover:(NSString *)bookCover
                           bookName:(NSString *)bookName
                         authorName:(NSString *)authorName
                             labels:(NSString *)labels
                      lastChapterId:(NSInteger)lastChapterId
                           progress:(NSInteger)progress;
- (NSArray<NSDictionary *> *)getAllBooksOfHaveRead;
- (NSDictionary * _Nullable)getOneBookThatHasReadWithBookId:(NSInteger)bookId;
- (BOOL)deleteBookFromBookrackListWithBookId:(NSInteger)bookId;
//-------------------------------------- table = LNBookrackBooks  添加到书架 -------------------------------------- end


@end

NS_ASSUME_NONNULL_END
