//
//  WNPlayerDef.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#ifndef WNPlayerDef_h
#define WNPlayerDef_h

#define WNPlayerLocalizedStringTable   @"WNPlayerStrings"

#define WNPlayerMinBufferDuration  2
#define WNPlayerMaxBufferDuration  5

#define WNPlayerErrorDomainDecoder         @"WNPlayerDecoder"
#define WNPlayerErrorDomainAudioManager    @"WNPlayerAudioManager"

#define WNPlayerErrorCodeInvalidURL                        -1
#define WNPlayerErrorCodeCannotOpenInput                   -2
#define WNPlayerErrorCodeCannotFindStreamInfo              -3
#define WNPlayerErrorCodeNoVideoAndAudioStream             -4

#define WNPlayerErrorCodeNoAudioOuput                      -5
#define WNPlayerErrorCodeNoAudioChannel                    -6
#define WNPlayerErrorCodeNoAudioSampleRate                 -7
#define WNPlayerErrorCodeNoAudioVolume                     -8
#define WNPlayerErrorCodeCannotSetAudioCategory            -9
#define WNPlayerErrorCodeCannotSetAudioActive              -10
#define WNPlayerErrorCodeCannotInitAudioUnit               -11
#define WNPlayerErrorCodeCannotCreateAudioComponent        -12
#define WNPlayerErrorCodeCannotGetAudioStreamDescription   -13
#define WNPlayerErrorCodeCannotSetAudioRenderCallback      -14
#define WNPlayerErrorCodeCannotUninitAudioUnit             -15
#define WNPlayerErrorCodeCannotDisposeAudioUnit            -16
#define WNPlayerErrorCodeCannotDeactivateAudio             -17
#define WNPlayerErrorCodeCannotStartAudioUnit              -18
#define WNPlayerErrorCodeCannotStopAudioUnit               -19

#pragma mark - Notification
#define WNPlayerNotificationOpened                 @"WNPlayerNotificationOpened"
#define WNPlayerNotificationClosed                 @"WNPlayerNotificationClosed"
#define WNPlayerNotificationEOF                    @"WNPlayerNotificationEOF"
#define WNPlayerNotificationBufferStateChanged     @"WNPlayerNotificationBufferStateChanged"
#define WNPlayerNotificationError                  @"WNPlayerNotificationError"

#pragma mark - Notification Key
#define WNPlayerNotificationBufferStateKey         @"WNPlayerNotificationBufferStateKey"
#define WNPlayerNotificationSeekStateKey           @"WNPlayerNotificationSeekStateKey"
#define WNPlayerNotificationErrorKey               @"WNPlayerNotificationErrorKey"
#define WNPlayerNotificationRawErrorKey            @"WNPlayerNotificationRawErrorKey"


#endif /* WNPlayerDef_h */
