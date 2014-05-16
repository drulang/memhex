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
@property (weak, nonatomic) IBOutlet UIImageView *answerCorrectImage;

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
    //Need to use notification so that we know DB is done loading and we can update the UI
    [self.db.context performBlock:^{
        [self updateData];
        [self updateUI];
    }];
    
     self.userScore = 0;
}

- (void) updateData{
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
}

- (IBAction)nextQuestion:(UIButton *)sender {
    
    [self.db.context performBlock:^{
        [self updateData];
        [self updateUI];
    }];
}

- (void)updateUI {
    self.questionLabel.text = self.currentQuestion.text;
    self.answerCorrectImage.hidden = YES;
    
    NSMutableArray *choosenIndex = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.answerButtons) {
        button.enabled = YES;
        button.alpha = 1.0f;
        [button setImage:nil forState:UIControlStateNormal];
        
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
- (IBAction)answerClicked:(UIButton *)sender {
    NSString *submittedAnswer = sender.titleLabel.text;
    NSLog(@"Checking answer, %@ ", submittedAnswer);
    
    if (submittedAnswer == self.currentQuestion.answer.text) {
        NSLog(@"Question is correct");
        sender.alpha = 0.8f;
        sender.tintColor = [UIColor greenColor];
        self.answerCorrectImage.hidden = NO;
        
        //Disable rest of answers
        for (UIButton *button in self.answerButtons) {
            if (button != sender) {
                button.enabled = NO;
                button.alpha = 0.2f;
            }
        }
    } else {
        NSLog(@"Question is wrong");
        sender.alpha = 0.2f;
        sender.tintColor = [UIColor blackColor];
    }
    sender.enabled = NO;
}

@end
