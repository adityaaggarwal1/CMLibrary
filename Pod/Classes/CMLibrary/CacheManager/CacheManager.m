//
//  CacheManager.m
//  VideoTag
//
//  Created by Aditya Aggarwal on 08/04/14.
//
//

#import "CacheManager.h"
#import "CacheModel.h"
#import "CMLibraryUtility.h"
#import <sqlite3.h>

#define CacheManagerSqliteName @"Cache.sqlite"

@interface CacheManager (){
    sqlite3 *dataBaseConnection;
}

@end

@implementation CacheManager

+ (id)sharedInstance {
    
    static CacheManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init {
    
    if (self = [super init]) {
        [self createCopyOfDatabaseInDocumentDirectory:NO];
    }
    return self;
}

#pragma mark - Create copy of database in Documents Directory
-(void)createCopyOfDatabaseInDocumentDirectory:(BOOL)isReplaceOlderDB
{
	BOOL success;
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:CacheManagerSqliteName];
	success = [fileManager fileExistsAtPath:writableDBPath];
    
	if (success) {
        
//        NSLog(@"Database Already Exists!!");
        
        if(isReplaceOlderDB)
        {
            [fileManager removeItemAtPath:writableDBPath error:&error];
            NSLog(@"%@",[error localizedDescription]);
        }
        else
            return;
	}
    
    NSString *sqlitePath = [NSString stringWithFormat:@"Frameworks/CMLibrary.framework/%@",CacheManagerSqliteName];
    
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:sqlitePath ofType:nil];
	// The writable database does not exist, so copy the default to the appropriate location.
    
    if([CMLibraryUtility checkIfStringContainsText:defaultDBPath]){
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    }
    else{
        NSLog(@"Wrong sqlite path");
    }
    
	if (!success) {
        NSLog(@"Failed to create writable database file. Reason :- '%@'.",[error localizedDescription]);
	}
}

#pragma mark - Open Database Connection

- (BOOL) openDatabaseConnection {
    
    [self closeDatabaseConnection];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:CacheManagerSqliteName];
    
	// Open the database. The database was prepared outside the application.
	if (sqlite3_open([path UTF8String], &dataBaseConnection) != SQLITE_OK) {
        NSLog(@"Error in opening database.");
        [self closeDatabaseConnection];
        return NO;
	}

    return YES;
}

#pragma mark - Close Database Connection

- (void) closeDatabaseConnection {
    
    sqlite3_close(dataBaseConnection);
}

#pragma mark - Caching in database

-(CacheModel *)dataInCacheForKey:(NSString *)key
{
    if(![CMLibraryUtility checkIfStringContainsText:key])
        return nil;
    
    CacheModel *cache = nil;
    int colIndex = -1;
    const char *errMsg = nil;
    const char *sqlQuery = nil;
    sqlite3_stmt *statement = nil;
    
    if(![self openDatabaseConnection])
        return nil;
    
    NSString *query = [NSString stringWithFormat: @"Select * from tblCache where cacheKey='%@'",key];

    sqlQuery = [query UTF8String];
    
    /*if no successful result*/
    if (sqlite3_prepare_v2(dataBaseConnection, sqlQuery, -1, &statement, &errMsg)!= SQLITE_OK)
    {
        if(errMsg && [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]] && errMsg != [@"(null)" UTF8String])
            sqlite3_free(&errMsg);
    }
    else
    {
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            cache = [CacheModel new];
            [cache setCacheId:sqlite3_column_int(statement, ++colIndex)];
            [cache setCacheKey:[CMLibraryUtility getStringFromChar:(char *) sqlite3_column_text(statement, ++colIndex)]];
            
            const void *blobBytes = sqlite3_column_blob(statement, ++colIndex);
            int blobBytesLength = sqlite3_column_bytes(statement, colIndex); // Count the number of bytes in the BLOB.
            
            [cache setCacheValue:[NSData dataWithBytes:blobBytes length:blobBytesLength]];
            [cache setCreatedDate:[self getDateObjectFromString:[CMLibraryUtility getStringFromChar:(char *) sqlite3_column_text(statement, ++colIndex)]]];
            [cache setModifiedDate:[self getDateObjectFromString:[CMLibraryUtility getStringFromChar:(char *) sqlite3_column_text(statement, ++colIndex)]]];
        }
    }
    sqlite3_finalize(statement);
    [self closeDatabaseConnection];
    
    return cache;
}

-(NSDate *)getDateObjectFromString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    return [formatter dateFromString:dateString];
}

-(BOOL)cacheData:(id)data forKey:(NSString *)key
{
    BOOL success=NO;

    if(![CMLibraryUtility checkIfStringContainsText:key])
        return success;
    
    const char *errMsg=nil;
    const char *sqlQuery = nil;
    sqlite3_stmt *statement;
    int colIndex = 0;
    
    if(![self openDatabaseConnection])
        return NO;
    
    sqlQuery = "Insert into tblCache(cacheKey,cacheValue,createdDate,ModifiedDate) VALUES (?, ?, ?, ?)" ;
    
    if(sqlite3_prepare_v2(dataBaseConnection, sqlQuery, -1, &statement, &errMsg) != SQLITE_OK)
    {
        //handle error
        NSLog(@"Error processing Query. Reason :- %s",errMsg);
        if(errMsg && [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]] && errMsg != [@"(null)" UTF8String])
            sqlite3_free(&errMsg);
        success=NO;
    }
    else
    {
        NSString *currentDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        sqlite3_bind_text(statement, ++colIndex, [key UTF8String], (int)[key length], SQLITE_STATIC);
        if([data isKindOfClass:[NSData class]])
            sqlite3_bind_blob(statement, ++colIndex, [data bytes], (int)[data length], SQLITE_STATIC);
        else
            sqlite3_bind_text(statement, ++colIndex, [data UTF8String], (int)[data length], SQLITE_STATIC);
        sqlite3_bind_text(statement, ++colIndex, [currentDate UTF8String], (int)[currentDate length], SQLITE_STATIC);
        sqlite3_bind_text(statement, ++colIndex, [currentDate UTF8String], (int)[currentDate length], SQLITE_STATIC);
        success=YES;
    }
    
    // Execute the statement.
    if (sqlite3_step(statement) != SQLITE_DONE) {
        // error handling...
        NSLog(@"%@",[CMLibraryUtility getStringFromChar:sqlite3_errmsg(dataBaseConnection)]);
    }
    else
        NSLog(@"Saved successfully!!");
    
    // Clean up and delete the resources used by the prepared statement.
    sqlite3_finalize(statement);
    
    [self closeDatabaseConnection];
    
    return success;
}

-(BOOL)updateData:(NSData *)data forKey:(NSString *)key
{
    BOOL success=NO;
    
    if(![CMLibraryUtility checkIfStringContainsText:key])
        return success;
    
    const char *errMsg=nil;
    const char *sqlQuery = nil;
    sqlite3_stmt *statement;
    int index = 0;
    
    if(![self openDatabaseConnection])
        return NO;
    
    sqlQuery = "Update tblCache set cacheValue=?, ModifiedDate=? where cacheKey=?" ;
    
    if(sqlite3_prepare_v2(dataBaseConnection, sqlQuery, -1, &statement, &errMsg) != SQLITE_OK)
    {
        //handle error
        NSLog(@"Error processing Query. Reason :- %s",errMsg);
        if(errMsg && [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]] && errMsg != [@"(null)" UTF8String])
            sqlite3_free(&errMsg);
        success=NO;
    }
    else
    {
        NSString *currentDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        sqlite3_bind_blob(statement, ++index, [data bytes], (int)[data length], SQLITE_STATIC);
        sqlite3_bind_text(statement, ++index, [currentDate UTF8String], (int)[currentDate length], SQLITE_STATIC);
        sqlite3_bind_text(statement, ++index, [key UTF8String], (int)[key length], SQLITE_STATIC);
        success=YES;
    }
    
    // Execute the statement.
    if (sqlite3_step(statement) != SQLITE_DONE) {
        // error handling...
        NSLog(@"%@",[CMLibraryUtility getStringFromChar:sqlite3_errmsg(dataBaseConnection)]);
    }
    else
        NSLog(@"Saved successfully!!");
    
    // Clean up and delete the resources used by the prepared statement.
    sqlite3_finalize(statement);
    
    [self closeDatabaseConnection];
    
    return success;
}

-(BOOL)clearDataForKey:(NSString *)key
{
    BOOL success=NO;

    if(![CMLibraryUtility checkIfStringContainsText:key])
        return success;
    
    char *errMsg=nil;
    const char *sqlQuery = nil;
    
    if(![self openDatabaseConnection])
        return NO;
    
    NSString *query = [NSString stringWithFormat:@"Update tblCache set cacheValue = '' where cacheKey = %@",key];

    sqlQuery = [query UTF8String];
    
    if(sqlite3_exec(dataBaseConnection, sqlQuery, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Error processing Query. Reason :- %s",errMsg);
        if(!errMsg || [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]])
            sqlite3_free(&errMsg);
        success=NO;
    } else {
        NSLog(@"Client updated successfully!!");
        success=YES;
    }
    
    [self closeDatabaseConnection];
    
    return success;
}

-(BOOL)isDataAvailableForKey:(NSString *)key
{
    BOOL success=NO;
    
    if(![CMLibraryUtility checkIfStringContainsText:key])
        return success;
    
    const char *errMsg = nil;
    const char *sqlQuery = nil;
    sqlite3_stmt *statement = nil;
    
    if(![self openDatabaseConnection])
        return NO;
    
    NSString *query = [NSString stringWithFormat: @"Select * from tblCache where cacheKey='%@'",key];
    
    sqlQuery = [query UTF8String];
    
    /*if no successful result*/
    if (sqlite3_prepare_v2(dataBaseConnection, sqlQuery, -1, &statement, &errMsg)!= SQLITE_OK)
    {
        if(errMsg && [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]] && errMsg != [@"(null)" UTF8String] && [key rangeOfString:@"'"].location == NSNotFound && [key rangeOfString:@"\""].location == NSNotFound)
            sqlite3_free(&errMsg);
        success = NO;
    }
    else
    {
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            success = YES;
        }
    }
    sqlite3_finalize(statement);
    [self closeDatabaseConnection];
    
    return success;
}

#pragma mark - Clear cache data

-(BOOL)clearCachedData
{
    if(![self openDatabaseConnection])
        return NO;
    
    BOOL success;
    
    char *errMsg = nil;
    NSString *query = [NSString stringWithFormat: @"delete from tblCache"];
    const char *sqlQuery = [query UTF8String];
    
    if(sqlite3_exec(dataBaseConnection, sqlQuery, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Error processing Query. Reason :- %s",errMsg);
        if(!errMsg || [CMLibraryUtility checkIfStringContainsText:[NSString stringWithUTF8String:errMsg]])
            sqlite3_free(&errMsg);
        success=NO;
    } else {
        NSLog(@"Database cleared");
        success=YES;
    }
    
    [self closeDatabaseConnection];
    
    return success;
}

#pragma mark - Cache files

-(BOOL)cacheFile:(NSData *)data forKey:(NSString *)key withFileExtension:(NSString *)extension
{
//    BOOL success=NO;
    
    if(!data || ![CMLibraryUtility checkIfStringContainsText:key] || ![CMLibraryUtility checkIfStringContainsText:extension])
        return NO;
    
    return NO;
}

- (void)dealloc
{
    [self closeDatabaseConnection];
    dataBaseConnection = nil;
}

-(void)releaseInstanceVarialbles
{
    [self closeDatabaseConnection];
    dataBaseConnection = nil;
}

@end
