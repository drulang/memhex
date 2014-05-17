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
#import "notifications.h"

@interface MemHexViewController ()

@property (nonatomic, strong) CoreDB *db;
@property (nonatomic, strong) Question *currentQuestion;
@property (nonatomic, strong) NSMutableArray *answers;
@property (nonatomic) NSInteger userScore;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *answerButtons;
@property (weak, nonatomic) IBOutlet UIImageView *answerCorrectImage;
@property (weak, nonatomic) IBOutlet UILabel *userScoreLabel;
@property (nonatomic) BOOL currentQuestionCorrect;
@property (weak, nonatomic) IBOutlet UIButton *resetScoreButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MemHexViewController

- (NSMutableArray *)answers {
    if (!_answers) {
        _answers = [[NSMutableArray alloc] init];
    }
    return _answers;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    NSLog(@"Adding notification listener");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:CoreDBAvailiabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"Received notification that DB is ready");
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        [self updateData];
        [self updateUI];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    
    self.db = [[CoreDB alloc] initCoreDB];
    
    self.userScore = 0;
    self.currentQuestionCorrect = NO;
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(contextChanged:)
                   name:NSManagedObjectContextDidSaveNotification object:self.db.context];
}

- (void) contextChanged:(NSNotification *)notification
{
    NSLog(@"RECEIVED NOTIFICATION, %@", notification.userInfo);
}

- (void) updateData{
    self.currentQuestion = [Question randomQuestionOnContext:self.db.context];
    Answer *correctAnswer = self.currentQuestion.answer;
    
    NSLog(@"Current Question: %@", self.currentQuestion.text);
    NSLog(@"      Question ID: %@", self.currentQuestion.id);
    NSLog(@"          Answer: %@", correctAnswer.text);
    
    //Random Answers
    NSArray *randomAnswers = [Answer chooseRandomAnswersByType:correctAnswer.answertypcd limitToNumber:3
                                                    skipAnswer:correctAnswer onContext:self.db.context];
    self.answers = [[NSMutableArray alloc] initWithArray:randomAnswers];
    //[self.answers addObjectsFromArray:randomAnswers];
    [self.answers addObject:correctAnswer];
    self.currentQuestionCorrect = NO;
}

- (IBAction)nextQuestion:(UIButton *)sender {
    [self.db.context performBlock:^{
        if (!self.currentQuestionCorrect) {
            self.userScore -= 5;
        }
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
        self.userScore += 2;
        self.currentQuestionCorrect = YES;
        
        self.userScoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.userScore];
        [self.answerCorrectImage setImage: [UIImage imageNamed:@"check"]];
    } else {
        NSLog(@"Question is wrong");
        sender.alpha = 0.2f;
        sender.tintColor = [UIColor blackColor];
        self.userScore--;
        [self.answerCorrectImage setImage:[UIImage imageNamed:@"wrong"]];
        self.answerCorrectImage.hidden = NO;
    }
    sender.enabled = NO;
    
    //If this was the last correct answer, then disable the correct answer
    NSUInteger numberWrongAnswers = 0;
    for (UIButton *button in self.answerButtons) {
        if (!button.enabled) {
            numberWrongAnswers++;
        }
    }
    NSLog(@"Number of wrong answers: %d", numberWrongAnswers);
    
    if (numberWrongAnswers >= 3) {
        //Disable last question
        for (UIButton *button in self.answerButtons) {
            if (button.enabled) {
                //This is the correct answer
                button.alpha = 0.8f;
                button.enabled = NO;
                
            }
        }
    }
    
   
    //See if user score is so low it needs to be reset
    if (self.userScore < -20) {
        NSLog(@"User Score: %d", self.userScore);
        self.resetScoreButton.hidden = NO;
    }
    
    self.userScoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.userScore];
}
- (IBAction)resetUserScore:(UIButton *)sender {
    NSLog(@"Resetting user score");
    self.userScore = 0;
    sender.hidden = YES;
}

@end
