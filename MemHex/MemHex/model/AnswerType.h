//
//  AnswerType.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer;

@interface AnswerType : NSManagedObject

@property (nonatomic, retain) NSString * answertypcd;
@property (nonatomic, retain) NSSet *answersWithType;
@end

@interface AnswerType (CoreDataGeneratedAccessors)

- (void)addAnswersWithTypeObject:(Answer *)value;
- (void)removeAnswersWithTypeObject:(Answer *)value;
- (void)addAnswersWithType:(NSSet *)values;
- (void)removeAnswersWithType:(NSSet *)values;

@end
