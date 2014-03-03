//
//  LWRadioViewController.h
//  Pastor Chris Digital Library
//
//  Created by ehiss on 2/24/14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LWRadioViewController : UIViewController<AVAudioPlayerDelegate>{
    
    IBOutlet UIButton *playButton;
    IBOutlet UIActivityIndicatorView *theIndicator;
    int thePlayerChecker;
    AVAudioPlayer *audioPlayer;
    
    AVPlayer *thePlayer;
    
    NSTimer *updateTimer;
    
    NSTimer *pollingTimer;
    NSDateFormatter *dateFormatter;
    IBOutlet UILabel *theTime;
     NSString *theCurrentTime;
}

@property (nonatomic, retain) NSDateFormatter *dateFormatter;


- (IBAction)playButtonPressed:(UIButton*)sender;
-(IBAction)volumeControl:(id)sender;
-(void)initiateAudioPlayer:(NSString*)theUrl;

@end
