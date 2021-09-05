//
//  FNFMDBManager.m
//  NotOnlyNovel
//
//  Created by JohnnyZhang on 11/21/20.
//  Copyright © 2020 JohnnyZhang. All rights reserved.
//

#import "LNFMDBManager.h"
#import <FMDB/FMDB.h>


@interface LNFMDBManager()

@property (nonatomic, strong) FMDatabaseQueue *db;
@property (nonatomic, strong) NSString *dbpath;

@end

@implementation LNFMDBManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        _dbpath = [documents stringByAppendingPathComponent:@"com.telabytes.lucknovel.db"];
        _db = [FMDatabaseQueue databaseQueueWithPath:_dbpath];
    }
    return self;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static LNFMDBManager *_fmdbManager = nil;
    dispatch_once(&onceToken, ^{
        _fmdbManager = [[LNFMDBManager alloc] init];
        [_fmdbManager createTables];
    });
    return _fmdbManager;
}

- (void)createTables {
    // 最后阅读章节
    NSString *sqlLastReadingChapter = @"create table IF NOT EXISTS LNLastReadingChapter(bookId integer, chapterId integer, pageIndex integer, createtime timestamp);";
    // 已经阅读过的章节
    NSString *sqlHaveReadChapter = @"create table IF NOT EXISTS LNHaveReadChapter(bookId integer, chapterId integer, createtime timestamp);";
    // 添加到书架
    NSString *sqlAddedToBookrack = @"create table IF NOT EXISTS LNBookrackBooks(bookId integer, chapterCount integer, bookCover text, bookName text, authorName text, labels text, lastChapterId integer, progress integer, updatetime timestamp);";
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeStatements:[NSString stringWithFormat:@"%@%@%@", sqlLastReadingChapter, sqlHaveReadChapter, sqlAddedToBookrack]];
        if (success) {
            NSLog(@"数据表创建成功！");
        }
    }];
}

- (NSString *)isEmpty:(NSString * __nullable)value {
    if (value) {
        return value;
    }
    return @"";
}


//-------------------------------------- table = LNLastReadingChapter 最后一次阅读的章节 -------------------------------------- begin
 
// 添加最后阅读的章节
- (void)addToLastReadingChapterTableWithBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId pageIndex:(NSInteger)pageIndex  {
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId FROM LNLastReadingChapter WHERE bookId=?;", @(bookId)];
        [resultSet next];
        NSInteger _bookId = [resultSet intForColumn:@"bookId"];
        [resultSet close];
        if (_bookId > 0) {
            // 此本书已经存在
            BOOL success = [db executeUpdate:@"UPDATE LNLastReadingChapter SET chapterId=?, pageIndex=?, createtime=datetime('now') where bookId=?;",
                       @(chapterId), @(pageIndex), @(bookId)];
            if (success) {
                NSLog(@"更新成功 chapterId=%ld", (long)chapterId);
            }
        } else {
            // 此本书不存在
            NSString *sql = @"INSERT INTO LNLastReadingChapter(bookId, chapterId, pageIndex, createtime) VALUES(?,?,?,datetime('now'));";
            BOOL success = [db executeUpdate:sql, @(bookId), @(chapterId), @(pageIndex)];
            if (success) {
                NSLog(@"插入成功 chapterId=%ld", (long)chapterId);
            }
        }
    }];
    [self.db close];
}

// 查询最后阅读的章节
- (NSArray<NSNumber *> *)getLastReadingChapterFromBookId:(NSInteger)bookId {
    __block NSInteger chapterId = 0;
    __block NSInteger pageIndex = 0;
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId, chapterId, pageIndex, createtime FROM LNLastReadingChapter WHERE bookId=?;", @(bookId)];
        [resultSet next];
        chapterId = [resultSet intForColumn:@"chapterId"];
        pageIndex = [resultSet intForColumn:@"pageIndex"];
        //NSString *createtime = [resultSet stringForColumn:@"createtime"];
        [resultSet close];
    }];
    [self.db close];
    return @[@(chapterId), @(pageIndex)];
}

//-------------------------------------- table = FNLastReadingChapter -------------------------------------- end


 


//-------------------------------------- table = FNHaveReadChapter  已经阅读过的章节 -------------------------------------- begin

- (void)addingHaveReadChapterIntoTableWithBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId {
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId FROM LNHaveReadChapter WHERE bookId=? AND chapterId=?;", @(bookId), @(chapterId)];
        [resultSet next];
        NSInteger _bookId = [resultSet intForColumn:@"bookId"];
        [resultSet close];
        if (_bookId > 0) {
            // 此本书此章节已经存在
        } else {
            // 此本书此章节已经存在
            NSString *sql = @"INSERT INTO LNHaveReadChapter(bookId, chapterId, createtime) VALUES(?,?,datetime('now'));";
            BOOL success = [db executeUpdate:sql, @(bookId), @(chapterId)];
            if (success) {
                NSLog(@"插入成功 bookId=%ld, chapterId=%ld", (long)bookId, (long)chapterId);
            }
        }
    }];
    [self.db close];
}

- (NSArray<NSNumber *> *)getHaveReadChapterIdsBookId:(NSInteger)bookId {
    __block NSMutableArray<NSNumber *> *chapterIds = [[NSMutableArray<NSNumber *> alloc] init];
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId, chapterId, createtime FROM LNHaveReadChapter WHERE bookId=?;", @(bookId)];
        while ([resultSet next]) {
            NSInteger chapterId = [resultSet intForColumn:@"chapterId"];
            [chapterIds addObject:@(chapterId)];
        }
        [resultSet close];
    }];
    [self.db close];
    return chapterIds;
}

//-------------------------------------- table = FNHaveReadChapter -------------------------------------- end










//-------------------------------------- table = LNBookrackBooks  添加到书架 -------------------------------------- begin
- (void)addBookToBookrackWithBookId:(NSInteger)bookId
                       chapterCount:(NSInteger)chapterCount
                          bookCover:(NSString *)bookCover
                           bookName:(NSString *)bookName
                         authorName:(NSString *)authorName
                             labels:(NSString *)labels
                      lastChapterId:(NSInteger)lastChapterId
                           progress:(NSInteger)progress
{
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId FROM LNBookrackBooks WHERE bookId=?;", @(bookId)];
        [resultSet next];
        NSInteger _bookId = [resultSet intForColumn:@"bookId"];
        [resultSet close];
        if (_bookId > 0) {
            // 此本书此章节已经存在，更新
            BOOL success = [db executeUpdate:@"UPDATE LNBookrackBooks SET lastChapterId=?, progress=?, updatetime=datetime('now') where bookId=?;",
                       @(lastChapterId), @(progress), @(bookId)];
            if (success) {
                NSLog(@"更新成功 bookId=%ld", (long)bookId);
            }
        } else {
            // 此本书此章节已经存在，插入
            NSString *sql = @"INSERT INTO LNBookrackBooks(bookId, chapterCount, bookCover, bookName, authorName, labels, lastChapterId, progress, updatetime) VALUES(?,?,?,?,?,?,?,?,datetime('now'));";
            BOOL success = [db executeUpdate:sql, @(bookId), @(chapterCount), bookCover, bookName, authorName, labels, @(lastChapterId), @(progress)];
            if (success) {
                NSLog(@"插入成功 bookId=%ld", (long)bookId);
            }
        }
    }];
    [self.db close];
}

- (NSArray<NSDictionary *> *)getAllBooksOfHaveRead {
    __block NSMutableArray<NSDictionary *> *models = [[NSMutableArray<NSDictionary *> alloc] init];
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId, chapterCount, bookCover, bookName, authorName, labels, lastChapterId, progress, updatetime FROM LNBookrackBooks ORDER BY updatetime DESC;"];
        while ([resultSet next]) {
            [models addObject:@{
                @"bookId" : @([resultSet intForColumn:@"bookId"]),
                @"chapterCount" : @([resultSet intForColumn:@"chapterCount"]),
                @"bookCover" : [resultSet stringForColumn:@"bookCover"],
                @"bookName" : [resultSet stringForColumn:@"bookName"],
                @"authorName" : [resultSet stringForColumn:@"authorName"],
                @"labels" : [resultSet stringForColumn:@"labels"],
                @"lastChapterId" : @([resultSet intForColumn:@"lastChapterId"]),
                @"progress" : @([resultSet intForColumn:@"progress"]),
                @"updatetime" : [resultSet stringForColumn:@"updatetime"]
            }];
        }
        [resultSet close];
    }];
    [self.db close];
    return models;
}

- (NSDictionary * _Nullable)getOneBookThatHasReadWithBookId:(NSInteger)bookId {
    __block NSDictionary *model = nil;
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT bookId, chapterCount, bookCover, bookName, authorName, labels, lastChapterId, progress, updatetime FROM LNBookrackBooks WHERE bookId=?;", @(bookId)];
        [resultSet next];
        NSInteger retBookId = [resultSet intForColumn:@"bookId"];
        if (retBookId > 0) {
            model = @{
                @"bookId" : @([resultSet intForColumn:@"bookId"]),
                @"chapterCount" : @([resultSet intForColumn:@"chapterCount"]),
                @"bookCover" : [resultSet stringForColumn:@"bookCover"],
                @"bookName" : [resultSet stringForColumn:@"bookName"],
                @"authorName" : [resultSet stringForColumn:@"authorName"],
                @"labels" : [resultSet stringForColumn:@"labels"],
                @"lastChapterId" : @([resultSet intForColumn:@"lastChapterId"]),
                @"progress" : @([resultSet intForColumn:@"progress"]),
                @"updatetime" : [resultSet stringForColumn:@"updatetime"]
            };
        }
        [resultSet close];
    }];
    [self.db close];
    return model;
}

- (BOOL)deleteBookFromBookrackListWithBookId:(NSInteger)bookId {
    __block BOOL isSuccess = NO;
    [self.db inDatabase:^(FMDatabase * _Nonnull db) {
        isSuccess = [db executeUpdate:@"DELETE FROM LNBookrackBooks WHERE bookId=?;", @(bookId)];
    }];
    [self.db close];
    return isSuccess;
}

//-------------------------------------- table = LNBookrackBooks  添加到书架 -------------------------------------- end


@end



