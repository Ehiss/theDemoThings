//
//  LWRadioViewController.m
//  Pastor Chris Digital Library
//
//  Created by ehiss on 2/24/14.
//
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "LWRadioViewController.h"

#define kPollingInterval 0.1

@interface LWRadioViewController ()

@end

@implementation LWRadioViewController

@synthesize dateFormatter;


void RouteChangeListener(	void *                  inClientData,
						 AudioSessionPropertyID	inID,
						 UInt32                  inDataSize,
						 const void *            inData);



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(332.0, 220.0);
    self.navigationController.navigationBarHidden = YES;
    
    [theIndicator startAnimating];
    
    NSDate *today = [[NSDate alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"HH : mm : ss"];
    
    NSString *currentTime = [self.dateFormatter stringFromDate: today];
    [theTime setText:currentTime];
    //[today release];
    
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval
                                                    target:self
                                                  selector:@selector(pollTime)
                                                  userInfo:nil
                                                   repeats:YES];
    
    dispatch_async(kBgQueue, ^{
        
        NSMutableData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://pastorchrislive.net/mservices/lwr/radio-url/ios/index.php"]];
        
        [self performSelectorOnMainThread:@selector(getTvStationStreamingURL:) withObject:xmlData waitUntilDone:YES];
        
        //[xmlData setLength:0];
    });
    

    

}


- (void)getTvStationStreamingURL:(NSMutableData *)responseData {
    
    [theIndicator stopAnimating];
    
    NSString *theXML = [[NSString alloc] initWithBytes:[responseData mutableBytes] length:[responseData length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"this is the response data %@", theXML);
    
    if([theXML length] == 0){
        
        NSString *title = @"There is an issue connecting to the internet at this time, please try again. Thank You";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else{
        
        NSLog(@"this is the response data %@", theXML);
        
        
        [self initiateAudioPlayer:theXML];
    }
    
}

- (void)pollTime
{
    NSDate *today = [[NSDate alloc] init];
    theCurrentTime = [self.dateFormatter stringFromDate: today];
    [theTime setText:theCurrentTime];
    //[today release];
}

-(void)initiateAudioPlayer:(NSString*)theUrl{
	
	thePlayerChecker = 1;
	
    
	
	
	
	NSURL *url = [NSURL URLWithString:theUrl];
    
    //NSData *fileUrl=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:theUrl]];
	
	//NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], theUrl]];
	
	//NSError *error;
	//audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    //audioPlayer = [[AVAudioPlayer alloc]initWithData:fileUrl error:nil];
    thePlayer = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    // thePlayer.volume = 0.70;
	//thePlayer.delegate = self ;
	
	[thePlayer play];
	//audioPlayer.volume = volumeValue;
	//[self updateViewForPlayerInfo:audioPlayer];
	//theDelegateForFlaires22.viewController.audioPlayer.numberOfLoops = 0;
	//audioPlayer.delegate = self ;
	//[audioPlayer play];
	
	//[audioPlayer play];
	//[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
	//updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:audioPlayer repeats:YES];
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(UIButton*)sender{
    
    // [self updateCurrentTimeForPlayer:audioPlayer];
	
	//if (updateTimer)
    //[updateTimer invalidate];
    
	//else{
    
    if(thePlayerChecker == 1){
        [thePlayer pause];
        [playButton setImage:[UIImage imageNamed:@"ic_play.png"] forState:UIControlStateNormal];
        updateTimer = nil;
        [pollingTimer invalidate];
        thePlayerChecker = 2;
    }
    else
        if(thePlayerChecker == 2){
			[thePlayer play];
			[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            thePlayerChecker = 1;
            
            pollingTimer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval
                                                            target:self
                                                          selector:@selector(pollTime)
                                                          userInfo:nil
                                                           repeats:YES];
			
		}
    
	//}
	
}

-(IBAction)volumeControl:(id)sender{
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(10, 37, 260, 20)];
    
    UIAlertView *volumeAlert = [[UIAlertView alloc] initWithTitle:@"Volume" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [volumeView sizeToFit];
    [volumeAlert addSubview:volumeView];
    
    /*
     for (UIView *view in [volumeView subviews]) {
     if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
     volumeViewSlider = view;
     }
     }*/
    
    [volumeAlert show];
    //[volumeAlert release];
}


void RouteChangeListener(	void *                  inClientData,
						 AudioSessionPropertyID	inID,
						 UInt32                  inDataSize,
						 const void *            inData)
{
	//AudioPlayerViewController* This = (AudioPlayerViewController*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];
		
		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
			
			//[This pausePlaybackForPlayer:[This audioPlayer]];
		}
	}
}


@end
