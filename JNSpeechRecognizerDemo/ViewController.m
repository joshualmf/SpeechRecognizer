//
//  ViewController.m
//  JNSpeechRecognizer
//
//  Created by Joshua on 16/8/11.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    JNSpeechRecognizer *speechRecognizer;
}

@end

@implementation ViewController

- (void)initSpeechRecognizer
{
    speechRecognizer = [[JNSpeechRecognizer alloc] initWithLocaleIdentifier:@"zh-CN"];
    speechRecognizer.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSpeechRecognizer];
    
    [self.recordButton setBackgroundColor:[UIColor grayColor]];
    [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(recordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.resultView setUserInteractionEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [speechRecognizer checkSpeechAuthorization:^(BOOL authorized, SFSpeechRecognizerAuthorizationStatus status) {
        // TODO
    }];
}

- (void)recordButtonTapped:(id)sender
{
    if ([speechRecognizer isRunning]) {
        [self stopRecord];
    } else {
        [self startRecord];
    }
}

- (void)startRecord
{
    [speechRecognizer startRecording];
}

- (void)stopRecord
{
    [speechRecognizer stopRecording];
}

- (void)recognitionDidStart:(NSError *)error
{
    [self.recordButton setTitle:@"停止录音" forState:UIControlStateNormal];
    [self.resultView setText:@""];
}

- (void)recognitionDidStop
{
    [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"录音结束" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [view show];

}

- (void)recognitionFail:(NSError *)error
{
    
}

- (void)recognitionSuccess:(NSString *)result
{
    [_resultView setText:[NSString stringWithFormat:@"%@", result]];
    [_resultView scrollRangeToVisible:NSMakeRange(_resultView.text.length - 1, 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
