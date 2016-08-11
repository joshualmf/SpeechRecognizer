//
//  ViewController.h
//  JNSpeechRecognizer
//
//  Created by Joshua on 16/8/11.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNSpeechRecognizer.h"

@interface ViewController : UIViewController <JNSpeechRecognizerDelegate>

@property (nonatomic, assign) IBOutlet UIButton *recordButton;
@property (nonatomic, assign) IBOutlet UITextView *resultView;
@end

