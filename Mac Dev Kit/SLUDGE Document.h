//
//  SLUDGE Document.h
//  Sludge Dev Kit
//
//  Created by Rikard Peterson on 2010-12-28.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLUDGE_Document : NSDocument {
	__unsafe_unretained SLUDGE_Document *project;
}

@property (assign) SLUDGE_Document *project;

@end
