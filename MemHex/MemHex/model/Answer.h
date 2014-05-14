//
//  Answer.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnswerType, Question;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) AnswerType *answertypcd;
@property (nonatomic, retain) NSSet *questions;
@end

@interface Answer (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
