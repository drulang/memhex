//
//  Answer+create.m
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "Answer+create.h"
#import "AnswerType.h"

@implementation Answer (create)

+ (Answer *) createAnswerWithText:(NSString *)text
                 AndAnswerTypeCode: (AnswerType *)answertypcd
                     onContext:(NSManagedObjectContext *)context {
    
    Answer *answer = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Answer"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text = %@", text];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error || [results count] > 1) {
        NSLog(@"Unable to create answer");
    } else if ([results count] == 1) {
        answer = [results firstObject];
    } else {
        answer = [NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:context];
        answer.text = text;
        answer.answertypcd = answertypcd;
    }
    
    return answer;
}

+ (NSArray *)chooseRandomAnswersByType:(AnswerType *)type
                         limitToNumber:(NSUInteger)count
                            skipAnswer:(Answer *)answer
                             onContext:(NSManagedObjectContext *)context {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSArray *allAnswersWithType = [type.answersWithType allObjects];
    if (!allAnswersWithType) {
        NSLog(@"No answers with type");
    } else {
        //Choose randomly from allAnswersWithType
        NSMutableArray *choosenIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i < count; i++) {
            while (true) {
                NSUInteger idx = arc4random() % [allAnswersWithType count];
                NSNumber *idxNumber = [NSNumber numberWithInteger:idx];
                if ([choosenIndex containsObject:idxNumber]) {
                    continue;
                } else if (allAnswersWithType[idx] == answer) {
                    NSLog(@"Skipping matching answer");
                    continue;
                } else {
                    [results addObject:allAnswersWithType[idx]];
                    [choosenIndex addObject:idxNumber];
                    break;
                }
            }
        }//end for
    }
    return results;
}

@end
