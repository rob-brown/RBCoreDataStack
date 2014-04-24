//
//  NSManagedObject+RBCoreDataStack.h
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

@interface NSManagedObject (RBCoreDataStack)

+ (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context;

- (id)initWithContext:(NSManagedObjectContext *)context;

+ (instancetype)createInContext:(NSManagedObjectContext *)context;

- (instancetype)loadIntoContext:(NSManagedObjectContext *)context;

- (void)deleteFromContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)fetchRequest;

+ (NSArray *)fetchWithRequest:(NSFetchRequest *)requset inContext:(NSManagedObjectContext *)context;

+ (instancetype)fetchFirstInContext:(NSManagedObjectContext *)context;

+ (instancetype)fetchFirstWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchWithRequest:(NSFetchRequest *)requset inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing*)outError;

+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing*)outError;

+ (NSArray *)fetchObjectIDsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing*)outError;

@end
