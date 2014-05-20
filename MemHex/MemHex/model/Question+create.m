//
//  Question+create.m
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "Question+create.h"

@implementation Question (create)

+ (Question *) createQuestionWithID:(NSNumber *)questionID
                            andText:(NSString *)text
                          onContext:(NSManagedObjectContext *)context {
    Question *question;
    
    //Check if question already exists
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", questionID];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error || [results count] > 1) {
        //Handle error
    } else if ([results count] == 1) {
        question = [results firstObject];
    } else {
        question = [NSEntityDescription insertNewObjectForEntityForName:@"Question"
                                                 inManagedObjectContext:context];
        question.id = questionID;
        question.text  = text;
    }
    
    return question;
}

+ (Question *)randomQuestionOnContext:(NSManagedObjectContext *)context {
    Question *question = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Question"];
    NSError *error = nil;
    NSUInteger numberOfQuestions = [context countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error getting number of questions");
    } else {
        NSString *questionID = [NSString stringWithFormat: @"%u", (arc4random() % numberOfQuestions) + 1]; //Incr by one because IDs start at 1
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", questionID];
        request.predicate = predicate;
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        question = [results firstObject];
        
        if (!question) {
            NSLog(@"ERROR: question is nil. QuestionID: %@", questionID);
        }
    }
    
    
    return question;
}

@end
