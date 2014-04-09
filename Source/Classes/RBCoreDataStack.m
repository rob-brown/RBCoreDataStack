//
//  RBCoreDataStack.m
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

#import "RBCoreDataStack.h"
#import "NSManagedObjectContext+RBCoreDataStack.h"


NSString * const RBCoreDataStackDefaultModelName = @"Model.momd";
NSString * const RBCoreDataStackDefaultStoreName = @"Model.sqlite";
NSString * const RBCoreDataStackDefaultSeedName  = nil;


@interface RBCoreDataStack ()

@property (nonatomic, strong, readwrite) NSManagedObjectModel * managedObjectModel;

@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (nonatomic, strong, readwrite) NSManagedObjectContext * rootContext;

@property (nonatomic, strong, readwrite) NSManagedObjectContext * defaultContext;

@end


@implementation RBCoreDataStack


#pragma mark - Public methods

- (NSManagedObjectContext *)createMainContext {
    return [self createContextWithConcurrencyPolicy:NSMainQueueConcurrencyType
                                      parentContext:nil];
}

- (NSManagedObjectContext *)createMainContextWithParentContext:(NSManagedObjectContext *)parentContext {
    return [self createContextWithConcurrencyPolicy:NSMainQueueConcurrencyType
                                      parentContext:parentContext];
}

- (NSManagedObjectContext *)createPrivateContext {
    return [self createContextWithConcurrencyPolicy:NSPrivateQueueConcurrencyType
                                      parentContext:nil];
}

- (NSManagedObjectContext *)createPrivateContextWithParentContext:(NSManagedObjectContext *)parentContext {
    return [self createContextWithConcurrencyPolicy:NSPrivateQueueConcurrencyType
                                      parentContext:parentContext];
}

- (NSManagedObjectContext *)createContextWithConcurrencyPolicy:(NSManagedObjectContextConcurrencyType)policy parentContext:(NSManagedObjectContext *)parentContext {

    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:policy];

    if (parentContext)
        [context setParentContext:parentContext];
    else
        [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    return context;
}


#pragma mark - Default instance method

+ (RBCoreDataStack *)defaultStack {

    static RBCoreDataStack * _defaultStack = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStack = [self new];
    });

    return _defaultStack;
}

- (id)init {

    if ((self = [super init])) {

        // Sets up default values.
        self.modelName = RBCoreDataStackDefaultModelName;
        self.storeName = RBCoreDataStackDefaultStoreName;
        self.seedName = RBCoreDataStackDefaultSeedName;
        self.useAutomaticLightweightMigration = NO;
        self.useJournaling = YES;
        self.persistentStoreType = NSSQLiteStoreType;
        self.storeDirectory = [[self applicationLibraryDirectory] absoluteString];
    }

    return self;
}

#pragma mark - Core Data stack

- (void)saveDefaultContextAsync:(dispatch_block_t)completion {

    // Starts a background task to ensure the save goes through.
    UIApplication * app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier taskID = 0u;

    dispatch_block_t taskCompletion = ^{

        if (taskID != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:taskID];
            taskID = UIBackgroundTaskInvalid;
        }
    };

    taskID = [app beginBackgroundTaskWithExpirationHandler:taskCompletion];

    // Performs the actual save.
    [self.defaultContext performBlock:^{

        [self.defaultContext saveAndLogError];

        [self.rootContext performBlock:^{

            [self.rootContext saveAndLogError];

            if (completion)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), completion);

            taskCompletion();
        }];
    }];
}

- (void)saveDefaultContextSync {

    [self.defaultContext performBlockAndWait:^{
        [self.defaultContext saveAndLogError];
    }];

    [self.rootContext performBlockAndWait:^{
        [self.rootContext saveAndLogError];
    }];
}

/**
 * This context is responsible for buffering saves to the database. Data changes
 * from the UI can use `defaultContext`, which will make quick saves.
 * `rootContext` can then be saved in the background avoiding disk IO on the
 * main thread.
 */
- (NSManagedObjectContext *)rootContext {

    if (!_rootContext) {
        @synchronized(self) {
            if (!_rootContext) {
                _rootContext = [self createContextWithConcurrencyPolicy:NSPrivateQueueConcurrencyType
                                                          parentContext:nil];
            }
        }
    }

    return _rootContext;
}

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the
 * persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)defaultContext {

    if (!_defaultContext) {
        @synchronized(self) {
            if (!_defaultContext) {
                _defaultContext = [self createContextWithConcurrencyPolicy:NSMainQueueConcurrencyType
                                                             parentContext:self.rootContext];
            }
        }
    }

    return _defaultContext;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {

    if (!_managedObjectModel) {
        @synchronized(self) {
            if (!_managedObjectModel) {

                NSString * modelName = [self modelName];
                NSURL * modelURL = [[NSBundle mainBundle] URLForResource:modelName
                                                           withExtension:nil];
                if (!modelURL)
                    NSAssert1(NO,
                              @"No MOM file found named: %@ in the main bundle. "
                              "Did you specify the right filename in -modelName and -modelExtension? "
                              "If you are using a custom delegate, be aware that XIBs and UIStoryboards "
                              "are inflated before -application:didFinishLaunchingWithOptions: is called. ",
                              modelName);

                _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

                if (!_managedObjectModel) {
                    NSAssert1(NO,
                              @"MOM file could not be read from file at path: %@. "
                              "Did change your model without migrating? "
                              "Try deleting your app and cleaning your build. "
                              "You may need to restart Xcode if it is in an inconsistent state. ",
                              modelURL);
                }
            }
        }
    }

    return _managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's
 * store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    if (!_persistentStoreCoordinator) {
        @synchronized(self) {
            if (!_persistentStoreCoordinator) {

                NSURL * storeURL = [NSURL URLWithString:[self.storeDirectory stringByAppendingPathComponent:self.storeName]];

                NSError * error = nil;
                NSFileManager * fileManager = [NSFileManager new];

                // !!!: Be sure to create a new default database if the MOM file is ever changed.

                // If there is no previous database, then a default one is used (if any).
                if (![fileManager fileExistsAtPath:[storeURL path]] && [self seedName]) {

                    NSURL * defaultStoreURL = [[NSBundle mainBundle] URLForResource:[self seedName]
                                                                      withExtension:nil];

                    // Copies the default database from the main bundle to the Documents directory.
                    [fileManager copyItemAtURL:defaultStoreURL
                                         toURL:storeURL
                                         error:&error];
                    if (error) {
                        // !!!: Handle the error here.
                        NSLog(@"Error copying seed database: %@", [error localizedDescription]);

                        // Resets the error.
                        error = nil;
                    }
                }

                _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

                NSMutableDictionary * options = [NSMutableDictionary new];

                if ([self useJournaling]) {
                    [options addEntriesFromDictionary:@{NSSQLitePragmasOption : @{@"journal_mode": @"WAL"}}];
                }
                else {
                    [options addEntriesFromDictionary:@{NSSQLitePragmasOption : @{@"journal_mode": @"DELETE"}}];
                }

                if ([self useAutomaticLightweightMigration]) {
                    // Automatically migrates the model when there are small changes.
                    [options addEntriesFromDictionary:@{
                                                        NSMigratePersistentStoresAutomaticallyOption : @YES,
                                                        NSInferMappingModelAutomaticallyOption       : @YES,
                                                        }];
                }

                NSPersistentStore * store = [_persistentStoreCoordinator addPersistentStoreWithType:[self persistentStoreType]
                                                                                      configuration:nil
                                                                                                URL:storeURL
                                                                                            options:options
                                                                                              error:&error];
                if (!store) {
                    // !!!: Handle this error better for your application.
                    NSLog(@"Unable to create persistent store. "
                          "If you are in development, you probably just need to delete your app and clean your build. "
                          "If you are in production, you need to handle migration properly. ");
                    abort();
                }
            }
        }
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/// Returns the URL to the application's Library directory.
- (NSURL *)applicationLibraryDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
