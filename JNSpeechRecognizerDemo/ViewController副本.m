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
    SFSpeechRecognizer              *speechRecognizer;
    AVAudioEngine                   *audioEngine;
    SFSpeechAudioBufferRecognitionRequest   *recognitionRequest;
    SFSpeechRecognitionTask         *recognitionTask;
}

@end

@implementation ViewController

- (void)initAudioEngineAndRecognizer
{
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    audioEngine = [[AVAudioEngine alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initAudioEngineAndRecognizer];
    
    [self.recordButton setBackgroundColor:[UIColor grayColor]];
    [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(recordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.resultView setUserInteractionEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // TODO
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            case SFSpeechRecognizerAuthorizationStatusDenied:
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                // Error
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                // Good
                break;
                
            default:
                break;
        }
    }];
}

- (void)recording
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    AVAudioInputNode *inputNode = [audioEngine inputNode];
    recognitionRequest.shouldReportPartialResults = YES;
    
    
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        BOOL isFinal = NO;
        NSString *bestResult = [[result bestTranscription] formattedString];
        isFinal = result.isFinal;
        if (error || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recognitionRequest = nil;
            recognitionTask = nil;
            [self stopRecord];

            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"录音结束" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        } else {
            NSLog(@"[%@]", bestResult);
            [_resultView setText:[NSString stringWithFormat:@"%@", bestResult]];
            [_resultView scrollRangeToVisible:NSMakeRange(_resultView.text.length - 1, 1)];
        }
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:nil];
}


- (void)recordButtonTapped:(id)sender
{
    if (audioEngine.isRunning) {
        [self stopRecord];
    } else {
        [self startRecord];
    }
}

- (void)startRecord
{
    [self recording];
    [self.recordButton setTitle:@"停止录音" forState:UIControlStateNormal];
    [self.resultView setText:@""];
}

- (void)stopRecord
{
    [audioEngine stop];
    [recognitionRequest endAudio];
    [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
