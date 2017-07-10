//
//  zDocument.h
//  Sludge Dev Kit
//
//  Created by Rikard Peterson on 2009-08-07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SLUDGE Document.h"


//
//  SpriteBank.h
//  Sludge Dev Kit
//
//  Created by Rikard Peterson on 2009-07-18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


//#include <OpenGL/gl.h>
#include "glee.h"
#import <Cocoa/Cocoa.h>
#include "sprites.h"

@class zDocument;

@interface zOpenGLView : NSOpenGLView
{
	struct spriteBank *backdrop;

	__unsafe_unretained zDocument *doc;
	int x, y, w, h;
	float z, zmul;
}
- (void) connectToDoc: (zDocument*) myDoc;
- (void) drawRect: (NSRect) bounds ;
@end


@interface zDocument : SLUDGE_Document {
	struct spriteBank backdrop;
	
	IBOutlet zOpenGLView *zView;
	IBOutlet NSSlider *zBufSlider;
	
	IBOutlet NSTextField *numBuffers;
	IBOutlet NSTextField *bufferYTextField;

	int buffer;
	int bufferY;
}
@property (nonatomic) int buffer;
@property (nonatomic) int bufferY;

//- (IBAction)setBufferY:(id)sender;

@end
