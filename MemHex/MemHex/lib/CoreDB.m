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
                                        @"dec": @"10",
                                        @"hex": @"A",
                                    },
                             @"B": @{
                                        @"bin": @"1011",
                                        @"dec": @"11",
                                        @"hex": @"B",
                                    }
                             };
    
    //Create answer types
    AnswerType *binAnswerType = [AnswerType answerTypeWithCode:@"bin" onContext:self.context];
    AnswerType *hexAnswerType = [AnswerType answerTypeWithCode:@"hex" onContext:self.context];
    AnswerType *decAnswerType = [AnswerType answerTypeWithCode:@"dec" onContext:self.context];
    
    NSDictionary *binToHex = @{binAnswerType.answertypcd: hexAnswerType.answertypcd};
    NSDictionary *hexToBin = @{hexAnswerType.answertypcd: binAnswerType.answertypcd};
    NSDictionary *decToHex = @{decAnswerType.answertypcd: hexAnswerType.answertypcd};
    NSDictionary *hexToDec = @{hexAnswerType.answertypcd: decAnswerType.answertypcd};
    NSDictionary *binToDec = @{binAnswerType.answertypcd: decAnswerType.answertypcd};
    NSDictionary *decToBin = @{decAnswerType.answertypcd: binAnswerType.answertypcd};
    
    NSArray *questions = @[binToHex, hexToBin, decToHex, hexToDec, binToDec, decToBin];
    
 
    NSInteger questionID = 1;
    for (NSString *key in values) {
        NSDictionary *hexDict = [values objectForKey:key];
        for (NSDictionary *questionType in questions) {
            NSString *fromAnswerType = [[questionType allKeys] firstObject];
            NSString *toAnswerType = questionType[fromAnswerType];
            
            NSString *fromValue = hexDict[fromAnswerType];
            NSString *toValue = hexDict[toAnswerType];
            
            NSString *questionText = [NSString stringWithFormat:@"What is %@(%@) in %@?", fromValue, fromAnswerType, toAnswerType];
            NSString *answerText = toValue;
            
            NSLog(@"Question: %@", questionText);
            NSLog(@"  Answer: %@", answerText);
            
            Question *newQuestion = [Question createQuestionWithID:[NSNumber numberWithInt:questionID]
                                                           andText:questionText onContext:self.context];
            AnswerType *answerAnswerType = [AnswerType answerTypeWithCode:toAnswerType onContext:self.context];
            Answer *newAnswer = [Answer createAnswerWithText:answerText
                                           AndAnswerTypeCode:answerAnswerType onContext:self.context];
            newQuestion.answer = newAnswer;
        }
        
        questionID++;
    }
    
    /*
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
    }*/
    
}

@end
