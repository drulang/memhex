//
//  CoreDB.m
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "CoreDB.h"
#import "AnswerType+create.h"
#import "Question+create.h"
#import "Answer+create.h"

@implementation CoreDB

- (instancetype) initCoreDB {
    self = [super init];
    NSLog(@"Initializing CoreDB");
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:@"MemHexDB"];
        
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
        
        if (fileExists) {
            [document openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    self.context = document.managedObjectContext;
                    [self createDefaultData];
                } else {
                    NSLog(@"Unable to open database");
                }
            }];
        } else {
            //Create it
            [document saveToURL:url
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  if (success) {
                      self.context = document.managedObjectContext;
                      [self createDefaultData];
                  } else {
                      NSLog(@"Unable to create database");
                  }
              }];
        }
    }
    return self;
}


- (void)createDefaultData{
    
    NSLog(@"Creating default data in database");
    
    NSDictionary *values = @{@"A": @{
                                        @"bin": @"1010",
                                        @"dec": @"10"
                                    },
                             @"B": @{
                                        @"bin": @"1011",
                                        @"dec": @"11"
                                    }
                             };
    
    //Create answer types
    AnswerType *binAnswerType = [AnswerType answerTypeWithCode:@"bin" onContext:self.context];
    AnswerType *hexAnswerType = [AnswerType answerTypeWithCode:@"hex" onContext:self.context];
    AnswerType *decAnswerType = [AnswerType answerTypeWithCode:@"dec" onContext:self.context];
    NSArray *answerTypes = @[binAnswerType, decAnswerType];
    
    NSInteger questionID = 1;
    for (NSString *key in values) {
        NSLog(@"Creating questions for key: %@", key);
        NSDictionary *hexDict = [values objectForKey:key];
        
        //Create BIN Questions
        for (AnswerType *answerType in answerTypes) {
            //Question of something -> Hex
            NSString *questionText = [NSString stringWithFormat:@"What is %@ in %@?", key, answerType.answertypcd];
            NSLog(@"Question: %@", questionText);
            Question *hexToBin = [Question createQuestionWithID:[NSNumber numberWithInt:questionID]
                                                        andText:questionText onContext:self.context];
            hexToBin.answer = [Answer createAnswerWithText:hexDict[answerType.answertypcd]
                                         AndAnswerTypeCode:binAnswerType onContext:self.context];
            
            //Question hex ->
            questionText = [NSString stringWithFormat:@"What is %@(%@) in hex?", hexDict[answerType.answertypcd], answerType.answertypcd];
            NSLog(@"Question: %@", questionText);
            Question *binToHex = [Question createQuestionWithID:[NSNumber numberWithInt:questionID]
                                                        andText:questionText onContext:self.context];
            binToHex.answer = [Answer createAnswerWithText:key
                                         AndAnswerTypeCode:hexAnswerType onContext:self.context];
            
            questionID += 1;
        }
    }
    
}

@end
