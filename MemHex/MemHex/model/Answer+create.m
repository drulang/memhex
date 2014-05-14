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

@end
