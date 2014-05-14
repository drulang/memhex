//
//  AnswerType+create.h
//  MemHex
//
//  Created by Dru Lang on 5/12/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "AnswerType.h"

@interface AnswerType (create)

+ (AnswerType *) answerTypeWithCode:(NSString *)answertypcd
                          onContext:(NSManagedObjectContext *)context;

@end
