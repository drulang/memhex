//
//  Answer+create.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "Answer.h"

@interface Answer (create)

+ (Answer *) createAnswerWithText:(NSString *)text
              AndAnswerTypeCode: (AnswerType *)answertypcd
                    onContext: (NSManagedObjectContext *)context;

@end
