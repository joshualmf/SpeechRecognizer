//
//  JNSpeechRecognizer.h
//  JNSpeechRecognizer
//
//  Created by Joshua on 16/8/11.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

typedef void(^JNSpeechAuthorizationCallback)(BOOL authorized, SFSpeechRecognizerAuthorizationStatus status);

@protocol JNSpeechRecognizerDelegate <NSObject>

- (void)recognitionDidStart:(NSError *)error;
- (void)recognitionDidStop;
- (void)recognitionFail:(NSError *)error;
- (void)recognitionSuccess:(NSString *)result;

@end

@interface JNSpeechRecognizer : NSObject

@property (nonatomic, assign) id<JNSpeechRecognizerDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL isRunning;

- (instancetype)initWithLocaleIdentifier:(NSString *)localeIdentifier;
- (void)checkSpeechAuthorization:(JNSpeechAuthorizationCallback)callback;
- (void)startRecording;
- (void)stopRecording;
@end
