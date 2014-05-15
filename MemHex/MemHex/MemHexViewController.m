//
//  MemHexViewController.m
//  MemHex
//
//  Created by Dru Lang on 5/11/14.
//  Copyright (c) 2014 Dru Lang. All rights reserved.
//

#import "MemHexViewController.h"
#import "Question+create.h"
#import "Answer+create.h"
#import "AnswerType+create.h"
#import "CoreDB.h"

@interface MemHexViewController ()

@property (nonatomic, strong) CoreDB *db;
@property (nonatomic, strong) Question *currentQuestion;
@property (nonatomic, strong) NSMutableArray *answers;
@property (nonatomic) NSUInteger userScore;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *answerButtons;

@end

@implementation MemHexViewController

- (NSMutableArray *)answers {
    if (!_answers) {
        _answers = [[NSMutableArray alloc] init];
    }
    return _answers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.db = [[CoreDB alloc] initCoreDB];
    [self nextQuestion:nil];
    
     self.userScore = 0;
}

- (IBAction)nextQuestion:(UIButton *)sender {
    
    [self.db.context performBlock:^{
        self.currentQuestion = [Question randomQuestionOnContext:self.db.context];
        Answer *correctAnswer = self.currentQuestion.answer;
       
        NSLog(@"Current Question: %@", self.currentQuestion.text);
        NSLog(@"          Answer: %@", correctAnswer.text);
        
        //Random Answers
        NSArray *randomAnswers = [Answer chooseRandomAnswersByType:correctAnswer.answertypcd limitToNumber:3
                                                    skipAnswer:correctAnswer onContext:self.db.context];
        self.answers = [[NSMutableArray alloc] initWithArray:randomAnswers];
        //[self.answers addObjectsFromArray:randomAnswers];
        [self.answers addObject:correctAnswer];
        
        [self updateUI];
    }];
}

- (void)updateUI {
    self.questionLabel.text = self.currentQuestion.text;
 
    NSMutableArray *choosenIndex = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.answerButtons) {
        while (true) {
            NSUInteger idx = arc4random() % [self.answers count];
            NSNumber *idxNumber = [NSNumber numberWithInt:idx];
            
            if ([choosenIndex containsObject:idxNumber]) {
                continue;
            } else {
                Answer *answer = self.answers[idx];
                [button setTitle:answer.text forState:UIControlStateNormal];
                [choosenIndex addObject:idxNumber];
                break;
            }
            
        }
    }
}

@end
