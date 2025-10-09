//
//  MultitouchBridge.h
//  Bridge header for private MultitouchSupport.framework
//

#ifndef MultitouchBridge_h
#define MultitouchBridge_h

#import <Foundation/Foundation.h>

// Touch point structure
typedef struct {
    float x;
    float y;
} MTPoint;

// Touch readout (position and velocity)
typedef struct {
    MTPoint position;
    MTPoint velocity;
} MTReadout;

// Finger/Touch structure
typedef struct {
    int frame;
    double timestamp;
    int identifier;
    int state;
    int foo3;
    int foo4;
    MTReadout normalized;  // Normalized coordinates (0-1)
    float size;
    int zero1;
    float angle;
    float majorAxis;
    float minorAxis;
    MTReadout absoluteVector;  // Absolute position in mm
    int zero2[2];
    float unk2;
} MTTouch;

// Device reference
typedef void* MTDeviceRef;

// Callback function type
typedef int (*MTContactCallbackFunction)(int device, MTTouch *touches, int numTouches, double timestamp, int frame);

// Framework functions
#ifdef __cplusplus
extern "C" {
#endif

// Get list of all multitouch devices
CFMutableArrayRef MTDeviceCreateList(void);

// Register callback for touch events
void MTRegisterContactFrameCallback(MTDeviceRef device, MTContactCallbackFunction callback);

// Unregister callback
void MTUnregisterContactFrameCallback(MTDeviceRef device, MTContactCallbackFunction callback);

// Start receiving touch events
void MTDeviceStart(MTDeviceRef device, int unknown);

// Stop receiving touch events
void MTDeviceStop(MTDeviceRef device);

// Release device
void MTDeviceRelease(MTDeviceRef device);

// Check if device is a Magic Mouse
bool MTDeviceIsOpaqueSurface(MTDeviceRef device);

// Check if device is built-in (trackpad) or external (Magic Mouse)
bool MTDeviceIsBuiltIn(MTDeviceRef device);

#ifdef __cplusplus
}
#endif

#endif /* MultitouchBridge_h */
