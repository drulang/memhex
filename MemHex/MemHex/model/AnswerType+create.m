//
//  AnswerType+create.m
//  MemHex
//
//  Created by Dru Lang on 5/12/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "AnswerType+create.h"

@implementation AnswerType (create)

+ (AnswerType *)answerTypeWithCode:(NSString *)answertypcd
                         onContext:(NSManagedObjectContext *)context {
    
    AnswerType *anstyp = nil;
    
    if ([answertypcd length]) {
        //Check to see if one already exists
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"AnswerType"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"answertypcd = %@", answertypcd];
        request.predicate = predicate;
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        if (!results || [results count] > 1) {
            //Handle error
            NSLog(@"Error creating answertype");
        } else if ([results count] == 1) {
            anstyp = [results firstObject];
        } else {
            //Create a new one
            anstyp = [NSEntityDescription insertNewObjectForEntityForName:@"AnswerType" inManagedObjectContext:context];
            anstyp.answertypcd = answertypcd;
        }
    }
    
    return anstyp;
}
@end
