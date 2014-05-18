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
@property (weak, nonatomic) IBOutlet UIButton *resetScoreButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation MemHexViewController

static const float VIEW_HIDE_ALPHA = 0.5f;
static const float VIEW_VISIBLE_ALPHA = 1.0f;
static const float ANSWER_CORRECT_ALPHA = 0.8f;
static const float ANSWER_INCORRECT_ALPHA = 0.2f;
static const float BUTTON_DISABLED_ALPHA = 0.3f;

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
        [self updateData];
        [self enableUI];
        [self updateUI];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self disableUI];
    self.db = [[CoreDB alloc] initCoreDB];
    self.userScore = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification
                 object:self.db.context];
}

- (void) contextChanged:(NSNotification *)notification {
    NSLog(@"Db has been saved: %@", notification.userInfo);
}

- (void)disableUI {
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    for (UIButton *button in self.answerButtons) {
        button.enabled = NO;
        button.alpha = VIEW_HIDE_ALPHA;
    }
    self.nextButton.enabled = NO;
    self.nextButton.alpha = VIEW_HIDE_ALPHA;

}

- (void)enableUI {
    for (UIButton *button in self.answerButtons) {
        button.enabled = YES;
        button.alpha = VIEW_VISIBLE_ALPHA;
    }
    
    self.nextButton.enabled = YES;
    self.nextButton.alpha = VIEW_VISIBLE_ALPHA;
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
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
        button.alpha = VIEW_VISIBLE_ALPHA;
        [button setImage:nil forState:UIControlStateNormal];
        
        while (true) {
            NSUInteger idx = arc4random() % [self.answers count];
            NSNumber *idxNumber = [NSNumber numberWithInteger:idx];
            
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
    
    self.nextButton.enabled = NO;
    self.nextButton.alpha = BUTTON_DISABLED_ALPHA;
}

- (IBAction)answerClicked:(UIButton *)sender {
    NSString *submittedAnswer = sender.titleLabel.text;
    NSLog(@"Checking answer, %@ ", submittedAnswer);
    
    if (submittedAnswer == self.currentQuestion.answer.text) {
        NSLog(@"Question is correct");
        sender.alpha = ANSWER_CORRECT_ALPHA;
        sender.tintColor = [UIColor greenColor];
        self.answerCorrectImage.hidden = NO;
        
        //Disable rest of answers
        for (UIButton *button in self.answerButtons) {
            if (button != sender) {
                button.enabled = NO;
                button.alpha = ANSWER_INCORRECT_ALPHA;
            }
        }
        self.userScore += 2;
        
        self.userScoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.userScore];
        [self.answerCorrectImage setImage: [UIImage imageNamed:@"check"]];
        
        self.nextButton.enabled = YES;
        self.nextButton.alpha = VIEW_VISIBLE_ALPHA;
    } else {
        NSLog(@"Question is wrong");
        sender.alpha = ANSWER_INCORRECT_ALPHA;
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
    NSLog(@"Number of wrong answers: %lu", (unsigned long)numberWrongAnswers);
    
    if (numberWrongAnswers >= 3) {
        //Disable last question
        for (UIButton *button in self.answerButtons) {
            if (button.enabled) {
                //This is the correct answer
                button.alpha = ANSWER_CORRECT_ALPHA;
                button.enabled = NO;
                
            }
        }
        self.nextButton.enabled = YES;
        self.nextButton.alpha = VIEW_VISIBLE_ALPHA;
    }
    
   
    //See if user score is so low it needs to be reset
    if (self.userScore < -10) {
        NSLog(@"User Score: %ld", (long)self.userScore);
        self.resetScoreButton.hidden = NO;
    }
    
    self.userScoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.userScore];
}
- (IBAction)resetUserScore:(UIButton *)sender {
    NSLog(@"Resetting user score");
    self.userScore = 0;
    sender.hidden = YES;
    self.userScoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.userScore];
}

@end
