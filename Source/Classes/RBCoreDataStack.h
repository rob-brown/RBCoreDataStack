//
//  RBCoreDataStack.h
//
//  RBCoreDataStack
//
//  Copyright (c) 2012-2014 Robert Brown
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface RBCoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel * managedObjectModel;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (nonatomic, strong, readonly) NSManagedObjectContext * rootContext;

@property (nonatomic, strong, readonly) NSManagedObjectContext * defaultContext;

@property (nonatomic, copy) NSString * storeName;

@property (nonatomic, copy) NSString * modelName;

@property (nonatomic, copy) NSString * seedName;

@property (nonatomic, copy) NSString * persistentStoreType;

@property (nonatomic, copy) NSString * storeDirectory;

@property (nonatomic, assign) BOOL useAutomaticLightweightMigration;

@property (nonatomic, assign) BOOL useJournaling;

@property (nonatomic, strong) NSBundle * bundle;

+ (RBCoreDataStack *)defaultStack;

- (NSManagedObjectContext *)createMainContext;

- (NSManagedObjectContext *)createMainContextWithParentContext:(NSManagedObjectContext *)parentContext;

- (NSManagedObjectContext *)createPrivateContext;

- (NSManagedObjectContext *)createPrivateContextWithParentContext:(NSManagedObjectContext *)parentContext;

- (void)saveDefaultContextAsync:(dispatch_block_t)completion;

- (void)saveDefaultContextSync;

- (NSURL *)storeURL;

@end
