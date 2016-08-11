//
//  JNSpeechRecognizer.m
//  JNSpeechRecognizer
//
//  Created by Joshua on 16/8/11.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "JNSpeechRecognizer.h"

@interface JNSpeechRecognizer ()
@property (nonatomic, strong) AVAudioEngine         *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer    *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest     *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask   *recognitionTask;


@property (nonatomic, strong) NSLocale                  *locale;
@end

@implementation JNSpeechRecognizer

- (instancetype)initWithLocaleIdentifier:(NSString *)localeIdentifier
{
    self = [super init];
    if (self) {
        self.locale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    }
    return self;
}

- (void)checkSpeechAuthorization:(JNSpeechAuthorizationCallback)callback
{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isAuthorized = NO;
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            case SFSpeechRecognizerAuthorizationStatusDenied:
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                // Error
            {
                isAuthorized = NO;
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                // Good
            {
                isAuthorized = YES;
            }
                break;
                
            default:
                break;
        }
        if (callback) {
            callback(isAuthorized, status);
        }
    }];
}

- (void)initAudioEngine
{
    if (self.audioEngine) {
        return;
    }
    self.audioEngine = [[AVAudioEngine alloc] init];
}

- (void)initSpeechRecognizer
{
    if (self.speechRecognizer) {
        return;
    }
    // 中文 zh-CN
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:self.locale];
}

- (void)initAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)createRecognitionRequest
{
    if (self.recognitionRequest) {
        [self.recognitionRequest endAudio];
        self.recognitionRequest = nil;
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
 
    // 实时返回
    self.recognitionRequest.shouldReportPartialResults = YES;
}

- (void)createRecognitionTask
{
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        NSString *bestResult = [[result bestTranscription] formattedString];
        isFinal = result.isFinal;
        if (error || isFinal) {
            [self endTask];
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognitionFail:)]) {
                [self.delegate recognitionFail:error];
            }
        } else {
            NSLog(@"[%@]", bestResult);
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognitionSuccess:)]) {
                [self.delegate recognitionSuccess:bestResult];
            }
        }
    }];

}

- (void)startRecording
{
    [self initSpeechRecognizer];
    [self initAudioEngine];
    [self initAudioSession];
    
    [self createRecognitionRequest];
    [self createRecognitionTask];
    
    AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
    [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    
    NSError *startError = nil;
    [self.audioEngine startAndReturnError:&startError];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recognitionDidStart:)]) {
        [self.delegate recognitionDidStart:startError];
    }
}

- (void)endTask
{
    [[self.audioEngine inputNode] removeTapOnBus:0];
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    self.recognitionRequest = nil;
    self.recognitionTask = nil;
}

- (void)stopRecording
{
    [self endTask];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recognitionDidStop)]) {
        [self.delegate recognitionDidStop];
    }
}

- (BOOL)isRunning
{
    return [self.audioEngine isRunning];
}
@end
