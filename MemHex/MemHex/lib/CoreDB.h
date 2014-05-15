//
//  CoreDB.h
//  MemHex
//
//  Created by Dru Lang on 5/13/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDB : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

- (instancetype) initCoreDB;  //designated initializer
- (void) createDefaultData;


@end
