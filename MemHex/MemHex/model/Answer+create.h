//
//  Answer+create.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "Answer.h"
#import "AnswerType.h"

@interface Answer (create)

+ (Answer *) createAnswerWithText:(NSString *)text
              AndAnswerTypeCode: (AnswerType *)answertypcd
                    onContext: (NSManagedObjectContext *)context;

+ (NSArray *) chooseRandomAnswersByType:(AnswerType *)type
                          limitToNumber:(NSUInteger)count
                             skipAnswer:(Answer *)answer
                              onContext:(NSManagedObjectContext *)context;
@end
