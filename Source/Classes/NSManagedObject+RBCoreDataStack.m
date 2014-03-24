//
//  NSManagedObject+RBCoreDataStack.m
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

#import "NSManagedObject+RBCoreDataStack.h"
#import "NSManagedObjectContext+RBCoreDataStack.h"

@implementation NSManagedObject (RBCoreDataStack)

+ (NSEntityDescription *)entityForContext:(NSManagedObjectContext *)context {

    NSParameterAssert(context);

    return [NSEntityDescription entityForName:NSStringFromClass(self)
                       inManagedObjectContext:context];
}

- (id)initWithContext:(NSManagedObjectContext *)context {

    NSParameterAssert(context);

    return [self initWithEntity:[[self class] entityForContext:context] insertIntoManagedObjectContext:context];
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context {
    return [[self alloc] initWithContext:context];
}

- (instancetype)loadIntoContext:(NSManagedObjectContext *)context {

    NSParameterAssert(context);

    return [context existingObjectWithID:self.objectID error:NULL];
}

+ (NSFetchRequest *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self)];
}

+ (NSArray *)fetchWithRequest:(NSFetchRequest *)requset inContext:(NSManagedObjectContext *)context {

    NSParameterAssert(requset && context);

    return [context performBlockAndWaitForReturn:^id{

        NSError * error = nil;
        NSArray * results = [context executeFetchRequest:requset error:&error];

        if (!results)
            NSLog(@"Error with fetch request: %@", error);

        return results;
    }];
}

+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context {
    return [self fetchWithRequest:[self fetchRequest] inContext:context];
}

+ (NSArray *)fetchAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    return [self fetchAllWithPredicate:predicate sortDescriptors:nil inContext:context];
}

+ (NSArray *)fetchAllWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context {

    NSFetchRequest * request = [self fetchRequest];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;

    return [self fetchWithRequest:request inContext:context];
}

@end
