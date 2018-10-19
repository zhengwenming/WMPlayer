//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNDisplayView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "WNPlayerVideoFrame.h"

#define VERTEX_ATTRIBUTE_POSITION   0
#define VERTEX_ATTRIBUTE_TEXCOORD   1

@interface WNDisplayView (){
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _programHandle;
    GLint _backingWidth;
    GLint _backingHeight;
    
    GLuint _positionSlot;
    GLuint _projectionSlot;
    GLuint _rotationSlot;
    GLuint _viewRatioSlot;
    GLuint _ratioSlot;
    GLuint _scaleSlot;
    GLfloat _vec4Position[8];
    GLfloat _vec2Texcoord[8];
    GLfloat _mat4Projection[16];
    GLfloat _mat3Rotation[9];
    GLfloat _mat3ViewRatio[9];
    GLfloat _mat3Ratio[9];
    GLfloat _mat3Scale[9];
    
    BOOL _shouldRotate;
    BOOL _shouldScale;
    BOOL _isFlipVertical;
    float _ratio[2];
    float _scale[2];
}
@property (nonatomic, strong) WNPlayerVideoFrame *lastFrame;

@end

@implementation WNDisplayView
- (instancetype)init{
    self = [super init];
    if (self) {
        if (![self initVars]) {
            self = nil;
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (![self initVars]) {
            self = nil;
            return nil;
        }
    }
    return self;
}
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reload];
}

- (void)reload {
    [self deleteGLBuffer];
    [self deleteGLProgram];
    [self createGLBuffer];
    [self createGLProgram];
    [self updatePosition];
    [self updateScale];
    [self updateRotationMatrix];
    [self render:self.lastFrame];
}

- (void)clear {
    self.keepLastFrame = NO;
    self.lastFrame = nil;
    [self render:nil];
}

- (BOOL)initVars {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @(NO),
                                       kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
                                       };
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (_context == nil) return NO;
    if (![EAGLContext setCurrentContext:_context]) return NO;
    
    [self initVertex];
    [self initTexCord];
    [self initProjection];
    
    self.rotation = 0;
    self.keepLastFrame = NO;
    return YES;
}

- (void)initVertex {
    _vec4Position[0] = -1; _vec4Position[1] = -1;
    _vec4Position[2] =  1; _vec4Position[3] = -1;
    _vec4Position[4] = -1; _vec4Position[5] =  1;
    _vec4Position[6] =  1; _vec4Position[7] =  1;
}

- (void)initTexCord {
    _vec2Texcoord[0] = 0; _vec2Texcoord[1] = 1;
    _vec2Texcoord[2] = 1; _vec2Texcoord[3] = 1;
    _vec2Texcoord[4] = 0; _vec2Texcoord[5] = 0;
    _vec2Texcoord[6] = 1; _vec2Texcoord[7] = 0;
}

- (void)initProjection {
    [WNDisplayView ortho:_mat4Projection];
}

- (void)createGLBuffer {
    // render buffer
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    // frame buffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)deleteGLBuffer {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
}

- (void)createGLProgram {
    // Create program
    GLuint program = glCreateProgram();
    if (program == 0) {
        NSLog(@"FAILED to create program.");
        return;
    }
    
    // Load shaders
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *vertexShaderFilename = @"WNPlayerVertexShader";
    if (_shouldScale) vertexShaderFilename = @"WNPlayerRotationScaleVertexShader";
        else if (_shouldRotate) vertexShaderFilename = @"WNPlayerRotationVertexShader";
            NSString *vertexShaderFile = [bundle pathForResource:vertexShaderFilename ofType:@"glsl"];
            GLuint vertexShader = [WNDisplayView loadShader:GL_VERTEX_SHADER withFile:vertexShaderFile];
            NSString *fragmentShaderResource = _isYUV ? @"WNPlayerYUVFragmentShader" : @"WNPlayerRGBFragmentShader";
            NSString *fragmentShaderFile = [bundle pathForResource:fragmentShaderResource ofType:@"glsl"];
            GLuint fragmentShader = [WNDisplayView loadShader:GL_FRAGMENT_SHADER withFile:fragmentShaderFile];
            
            // Attach shaders
            glAttachShader(program, vertexShader);
            glAttachShader(program, fragmentShader);
            
            // Bind
            glBindAttribLocation(program, VERTEX_ATTRIBUTE_POSITION, "position");
            glBindAttribLocation(program, VERTEX_ATTRIBUTE_TEXCOORD, "texcoord");
            
            // Link program
            glLinkProgram(program);
            
            // Check status
            GLint linked = 0;
            glGetProgramiv(program, GL_LINK_STATUS, &linked);
            if (linked == 0) {
                GLint length = 0;
                glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
                if (length > 1) {
                    char *log = malloc(sizeof(char) * length);
                    glGetProgramInfoLog(program, length, NULL, log);
                    NSLog(@"FAILED to link program, error: %s", log);
                    free(log);
                }
                
                glDeleteProgram(program);
                return;
            }
    
    glUseProgram(program);
    
    _positionSlot = glGetAttribLocation(program, "position");
    _projectionSlot = glGetUniformLocation(program, "projection");
    if (_shouldRotate) {
        _rotationSlot = glGetUniformLocation(program, "rotation");
    }
    if (_shouldScale) {
        _scaleSlot = glGetUniformLocation(program, "scale");
        _ratioSlot = glGetUniformLocation(program, "ratio");
        _viewRatioSlot = glGetUniformLocation(program, "viewratio");
    }
    _programHandle = program;
}

- (void)deleteGLProgram {
    glDeleteProgram(_programHandle);
    _programHandle = 0;
}

- (void)updatePosition {
    const float cw = _contentSize.width;
    const float ch = _contentSize.height;
    if (cw == 0 || ch == 0) {
        _ratio[0] = _ratio[1] = 1;
        _vec4Position[0] = -1; _vec4Position[1] = -1;
        _vec4Position[2] =  1; _vec4Position[3] = -1;
        _vec4Position[4] = -1; _vec4Position[5] =  1;
        _vec4Position[6] =  1; _vec4Position[7] =  1;
        return;
    }
    
    const float bw = _backingWidth;
    const float bh = _backingHeight;
    const float rw = bw / cw; // ratio of width
    const float rh = bh / ch; // ratio of height
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        _ratio[0] = _ratio[1] = MIN(rw, rh);
    } else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        _ratio[0] = _ratio[1] = MAX(rw, rh);
    } else if (self.contentMode == UIViewContentModeScaleToFill) {
        _ratio[0] = rw; _ratio[1] = rh;
    }
    const float w = (cw * _ratio[0]) / bw;
    const float h = (ch * _ratio[1]) / bh;
    
    _vec4Position[0] = -w; _vec4Position[1] = -h;
    _vec4Position[2] =  w; _vec4Position[3] = -h;
    _vec4Position[4] = -w; _vec4Position[5] =  h;
    _vec4Position[6] =  w; _vec4Position[7] =  h;
}

- (void)updateScale {
    if (!_shouldScale) return;
    const float cw = _contentSize.width ;
    const float ch = _contentSize.height;
    if (cw == 0 || ch == 0) {
        _scale[0] = _scale[1] = 1;
        return;
    }
    
    const float bw = _backingWidth;
    const float bh = _backingHeight;
    const float acw = _shouldScale ? ch * _ratio[1] : cw * _ratio[0];
    const float ach = _shouldScale ? cw * _ratio[0] : ch * _ratio[1];
    const float sw = bw / acw; // scale of width
    const float sh = bh / ach; // scale of height
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        _scale[0] = _scale[1] = MIN(sw, sh);
    } else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        _scale[0] = _scale[1] = MAX(sw, sh);
    } else if (self.contentMode == UIViewContentModeScaleToFill) {
        _scale[0] = sw; _scale[1] = sh;
    }
}

- (void)updateRotationMatrix {
    if (_shouldRotate) {
        if (_isFlipVertical) { [WNDisplayView flipVertical:_mat3Rotation]; }
        else { [WNDisplayView rotate:self.rotation matrix:_mat3Rotation]; }
    }
    if (_shouldScale) {
        [WNDisplayView ratio:(GLfloat)_backingWidth/(GLfloat)_backingHeight matrix:_mat3Ratio];
        [WNDisplayView ratio:(GLfloat)_backingHeight/(GLfloat)_backingWidth matrix:_mat3ViewRatio];
        [WNDisplayView scale:_scale matrix:_mat3Scale];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self updatePosition];
    [self updateScale];
    [self updateRotationMatrix];
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    [self updatePosition];
    [self updateScale];
    [self updateRotationMatrix];
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
    NSInteger r = round(rotation);
    _isFlipVertical = (r % 180 == 0);
    _shouldScale = (!_isFlipVertical && r % 90 == 0);
    _shouldRotate = (r % 360 != 0);
    [self reload];
}

- (void)setIsYUV:(BOOL)isYUV {
    _isYUV = isYUV;
    [self reload];
}

- (void)render:(WNPlayerVideoFrame *)frame {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    // Set frame
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if ([frame prepareRender:_programHandle]) {
        glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, _mat4Projection);
        if (_shouldRotate) {
            glUniformMatrix3fv(_rotationSlot, 1, GL_FALSE, _mat3Rotation);
        }
        if (_shouldScale) {
            glUniformMatrix3fv(_ratioSlot, 1, GL_FALSE, _mat3Ratio);
            glUniformMatrix3fv(_viewRatioSlot, 1, GL_FALSE, _mat3ViewRatio);
            glUniformMatrix3fv(_scaleSlot, 1, GL_FALSE, _mat3Scale);
        }
        glVertexAttribPointer(VERTEX_ATTRIBUTE_POSITION, 2, GL_FLOAT, GL_FALSE, 0, _vec4Position);
        glEnableVertexAttribArray(VERTEX_ATTRIBUTE_POSITION);
        glVertexAttribPointer(VERTEX_ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, _vec2Texcoord);
        glEnableVertexAttribArray(VERTEX_ATTRIBUTE_TEXCOORD);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    if (_keepLastFrame) self.lastFrame = frame;
        }

#pragma mark - Utils
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString {
    // 1. Create shader
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"FAILED to create shader.");
        return 0;
    }
    
    // 2. Load shader source
    const char *shaderUTF8String = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderUTF8String, NULL);
    
    // 3. Compile shader
    glCompileShader(shader);
    
    // 4. Check status
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (compiled == 0) {
        GLint length = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
        if (length > 1) {
            char *log = malloc(sizeof(char) * length);
            glGetShaderInfoLog(shader, length, NULL, log);
            NSLog(@"FAILED to compile shader, error: %s", log);
            free(log);
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

+ (GLuint)loadShader:(GLenum)type withFile:(NSString *)shaderFile {
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFile encoding:NSUTF8StringEncoding error:&error];
    if (shaderString == nil) {
        NSLog(@"FAILED to load shader file: %@, Error: %@", shaderFile, error);
        return 0;
    }
    
    return [self loadShader:type withString:shaderString];
}

/*
 * https://www.opengl.org/sdk/docs/man2/xhtml/glOrtho.xml
 */
+ (void)ortho:(float *)mat4f {
    float left = -1, right = 1;
    float bottom = -1, top = 1;
    float near = -1, far = 1;
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / r_l;
    float ty = - (top + bottom) / t_b;
    float tz = - (far + near) / f_n;
    
    mat4f[0] = 2 / r_l;
    mat4f[1] = 0;
    mat4f[2] = 0;
    mat4f[3] = 0;
    
    mat4f[4] = 0;
    mat4f[5] = 2 / t_b;
    mat4f[6] = 0;
    mat4f[7] = 0;
    
    mat4f[8] = 0;
    mat4f[9] = 0;
    mat4f[10] = -2 / f_n;
    mat4f[11] = 0;
    
    mat4f[12] = tx;
    mat4f[13] = ty;
    mat4f[14] = tz;
    mat4f[15] = 1;
}

/*
 * Rotate X
 *  ---------------------
 * | 1,   0  ,   0   , 0 |
 * | 0, cos a, -sin a, 0 |
 * | 0, sin a,  cos a, 0 |
 * | 0,   0  ,   0   , 1 |
 *  ---------------------
 *
 * Rotate Y
 *  ---------------------
 * |  cos a, 0, sin a, 0 |
 * |    0  , 1,   0  , 0 |
 * | -sin a, 0, cos a, 0 |
 * |    0  , 0,   0  , 1 |
 *  ---------------------
 *
 * Rotate Z
 *  ---------------------
 * | cos a, -sin a, 0, 0 |
 * | sin a,  cos a, 0, 0 |
 * |   0  ,    0  , 1, 0 |
 * |   0  ,    0  , 0, 1 |
 *  ---------------------
 */
+ (void)rotate:(float)degree matrix:(float *)mat3f {
    float radian = degree * M_PI / 180;
    float sina = sin(radian);
    float cosa = cos(radian);
    mat3f[0] = cosa; mat3f[1] = -sina; mat3f[2] = 0;
    mat3f[3] = sina; mat3f[4] =  cosa; mat3f[5] = 0;
    mat3f[6] =    0; mat3f[7] =     0; mat3f[8] = 1;
}

+ (void)flipVertical:(float *)mat3f {
    mat3f[0] = -1; mat3f[1] =  0; mat3f[2] = 0;
    mat3f[3] =  0; mat3f[4] = -1; mat3f[5] = 0;
    mat3f[6] =  0; mat3f[7] =  0; mat3f[8] = 1;
}

/*
 *  ---------
 * | r, 0, 0 |
 * | 0, 1, 0 |
 * | 0, 0, 1 |
 *  ---------
 */
+ (void)ratio:(double)ratio matrix:(float *)mat3f {
    mat3f[0] = ratio; mat3f[1] = 0; mat3f[2] = 0;
    mat3f[3] =     0; mat3f[4] = 1; mat3f[5] = 0;
    mat3f[6] =     0; mat3f[7] = 0; mat3f[8] = 1;
}

/*
 *  ---------
 * | s, 0, 0 |
 * | 0, s, 0 |
 * | 0, 0, 1 |
 *  ---------
 */
+ (void)scale:(float *)scale matrix:(float *)mat3f {
    mat3f[0] = scale[0]; mat3f[1] =        0; mat3f[2] = 0;
    mat3f[3] =        0; mat3f[4] = scale[1]; mat3f[5] = 0;
    mat3f[6] =        0; mat3f[7] =        0; mat3f[8] = 1;
}
- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}
@end
