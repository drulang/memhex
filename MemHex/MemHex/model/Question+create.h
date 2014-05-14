//
//  Question+create.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "Question.h"

@interface Question (create)

+ (Question *) createQuestionWithID: (NSNumber *)questionID
                            andText: (NSString *)text
                          onContext: (NSManagedObjectContext *)context;

@end
