//
//  WNPlayerVideoRGBFrame.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerVideoRGBFrame.h"

@interface WNPlayerVideoRGBFrame (){
    GLint _sampler;
    GLuint _texture;
    GLint _format;
}

@end

@implementation WNPlayerVideoRGBFrame
- (instancetype)init{
    self = [super init];
    if (self) {
        self.videoType = kWNPlayerVideoFrameTypeRGB;
        _sampler = -1;
        _texture = 0;
        _hasAlpha = NO;
        _format = GL_RGB;
    }
    return self;
}
- (void)deleteTexture {
    if (_texture != 0) {
        glDeleteTextures(1, &_texture);
        _texture = 0;
    }
}

- (BOOL)prepareRender:(GLuint)program {
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (_texture == 0) {
        glGenTextures(1, &_texture);
        if (_texture == 0) return NO;
    }
    
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 _format,
                 self.width,
                 self.height,
                 0,
                 _format,
                 GL_UNSIGNED_BYTE,
                 self.data.bytes);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if (_sampler == -1) {
        _sampler = glGetUniformLocation(program, "s_texture");
        if (_sampler == -1) return NO;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(_sampler, 0);
    return YES;
}

- (void)setHasAlpha:(BOOL)hasAlpha {
    _hasAlpha = hasAlpha;
    _format = hasAlpha ? GL_RGBA : GL_RGB;
}

- (void)dealloc {
    [self deleteTexture];
}
@end
