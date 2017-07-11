#import "SpriteBank.h"
#include <unistd.h>
#include <sys/stat.h>
#include "project.hpp"

#import "AppController.h"
#include <Carbon/Carbon.h>

#include "settings.h"
#import "ProjectDocument.h"
#import "ScriptDocument.h"
#import "SLUDGE Document.h"
#include "interface.h"

AppController *aC;

/* The main class of the application, the application's delegate */
@implementation AppController

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

-(id) init
{
	if (self = [super init]) {
		aC = self;
	}
	return self;
}


- (IBAction)menuOpen:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	return [docControl openDocument: sender];
}

- (IBAction)newProject:(id)sender
{    
	NSString *path = nil;
	NSSavePanel *savePanel = [ NSSavePanel savePanel ];
	[savePanel setTitle:@"New SLUDGE Project"];
	[savePanel setAllowedFileTypes:@[@"slp"]];
	
	if ( [ savePanel runModal ] ) {
		path = [ [savePanel URL] path];
		int numFiles = 0;
		doNewProject ([path fileSystemRepresentation], 0, &numFiles);
	}
	
	if (path) {	
		NSURL *file = [NSURL fileURLWithPath: path];
		NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
		NSError **err;
		NSDocument *project = [docControl makeDocumentWithContentsOfURL:file ofType:@"SLUDGE Project file" error:err];
		if (project) {
			[docControl addDocument: project];
			[project makeWindowControllers];
			[project showWindows];
		}
	}
}

- (IBAction)scriptNew:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SLUDGE_Document *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE Script" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
		
}

- (IBAction)spriteBankNew:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SpriteBank *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE Sprite Bank" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
}
- (IBAction)spriteBankFontify:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SpriteBank *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE Sprite Bank" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
	[doc fontifyMe];
}
- (IBAction)floorNew:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SLUDGE_Document *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE Floor" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
}
- (IBAction)translationNew:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SLUDGE_Document *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE Translation file" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
}
- (IBAction)zBufferNew:(id)sender
{
	NSDocumentController *docControl = [NSDocumentController sharedDocumentController];
	NSError **err;
	SLUDGE_Document *doc = [docControl makeUntitledDocumentOfType:@"SLUDGE zBuffer" error:err];
	[docControl addDocument: doc];
	[doc makeWindowControllers];
	[doc showWindows];
}

- (IBAction)prefsMenu:(id)sender
{
	[preferenceWindow makeKeyAndOrderFront:nil];
	
	[prefKeepImages setState: ! programSettings.compilerKillImages];
	[prefWriteStrings setState: programSettings.compilerWriteStrings];
	[prefVerbose setState: programSettings.compilerVerbose];
	
}

- (IBAction)compileMenu:(id)sender
{
	SLUDGE_Document *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	ProjectDocument *p = (ProjectDocument *)[doc project];
	
	[p compile];
}
- (IBAction)projectPrefsMenu:(id)sender{
	SLUDGE_Document *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	ProjectDocument *p = (ProjectDocument *)[doc project];
	
	[p showProjectPrefs];
}


/*
OSStatus RegisterMyHelpBook(void)
{
    CFBundleRef myApplicationBundle;
    CFURLRef myBundleURL;
    FSRef myBundleRef;
    OSStatus err = noErr;
	
    myApplicationBundle = NULL;
    myBundleURL = NULL;
	
    myApplicationBundle = CFBundleGetMainBundle();// 1
		if (myApplicationBundle == NULL) {err = fnfErr; goto bail;}
		
	myBundleURL = CFBundleCopyBundleURL(myApplicationBundle);// 2
		if (myBundleURL == NULL) {err = fnfErr; goto bail;}
			
	if (!CFURLGetFSRef(myBundleURL, &myBundleRef)) 
		err = fnfErr;// 3
				
	if (err == noErr) err = AHRegisterHelpBook(&myBundleRef);// 4
		return err;
					
bail: return err;

}*/

OSStatus MyGotoHelpPage (CFStringRef pagePath, CFStringRef anchorName)
{
    CFBundleRef myApplicationBundle = NULL;
    CFStringRef myBookName = NULL;
    CFURLRef myBundleURL;
    OSStatus err = noErr;
	
    myApplicationBundle = CFBundleGetMainBundle();
	if (myApplicationBundle == NULL) {
		err = fnfErr; goto bail;
	}
		
	myBundleURL = CFBundleCopyBundleURL(myApplicationBundle);
	if (myBundleURL == NULL) {
		err = fnfErr; goto bail;
	}
	
	err = AHRegisterHelpBookWithURL(myBundleURL);
	if (err != noErr) {
		fprintf (stderr, "Error registering help book. %d", err);
		goto bail;
	}
							
	myBookName = CFBundleGetValueForInfoDictionaryKey(myApplicationBundle,
														  CFSTR("CFBundleHelpBookName"));
	if (myBookName == NULL) {
		err = fnfErr; goto bail;
	}
				
	if (CFGetTypeID(myBookName) != CFStringGetTypeID()) {
		err = paramErr; goto bail;
	}

	err = AHGotoPage (myBookName, pagePath, anchorName);
					
bail:
	if (myBundleURL) {
		CFRelease(myBundleURL);
	}
	return err;
			
}

- (IBAction)helpMenu:(id)sender
{
	MyGotoHelpPage(NULL, NULL);
}

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem {
	int t = [menuItem tag];
	SLUDGE_Document *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	ProjectDocument *p = (ProjectDocument *)[doc project];

	if (t == 1000)  {
		// Compile project
		if (p) {
			[menuItem setTitle: [NSString stringWithFormat:@"Compile %@", [p getTitle]]];
			return true;
		} else {
			[menuItem setTitle: @"Compile Game"];
			return false;
		}
	} else if (t == 1001)  {
		// Project properties
		if (! p)
			return false;
	} else if (t == 2000)  {
		// For script editor
		if (! [[doc fileType] isEqualToString:@"SLUDGE Script"])
			return false;
	}
	return true;
}


/* Called when the internal event loop has just started running */
- (void) applicationDidFinishLaunching: (NSNotification *) note
{

}

void saveIniFile() {
	unsigned char appsupport_path[1024];
	FSRef foundRef;
	
	// Find the preference folder and go there
	FSFindFolder (kUserDomain, kPreferencesFolderType , kDontCreateFolder, &foundRef);	
	FSRefMakePath( &foundRef, appsupport_path, 1024);
	chdir ((char *) appsupport_path);
	mkdir ("SLUDGE Development Kit", 0000777);
	chdir ("SLUDGE Development Kit");
	
	FILE * fp = fopen ("SLUDGE.ini", "wb");
	
	fprintf (fp, "KillImages=%d\n", programSettings.compilerKillImages);
	fprintf (fp, "WriteStrings=%d\n", programSettings.compilerWriteStrings);
	fprintf (fp, "Verbose=%d\n", programSettings.compilerVerbose);
	fprintf (fp, "SearchSensitive=%d\n", programSettings.searchSensitive);
	fclose (fp);
}

- (IBAction)prefKeepImagesClick:(id)sender
{
	programSettings.compilerKillImages = ! [prefKeepImages state];
	saveIniFile();
}
- (IBAction)prefWriteStringsClick:(id)sender
{
	programSettings.compilerWriteStrings = [prefWriteStrings state];
	saveIniFile();
}
- (IBAction)prefVerboseClick:(id)sender
{
	programSettings.compilerVerbose = [prefVerbose state];
	saveIniFile();
}

- (IBAction)commentMenu:(id)sender
{
	ScriptDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if ([doc commentMenu])
		return;
	errorBox("Error", "Can't comment text: Wrong kind of file.");
}


@end

const char * getTempDir () {
	return [NSTemporaryDirectory() UTF8String];
}

bool askAQuestion (const char * head, const char * msg) {
	if (! NSRunAlertPanel ([NSString stringWithUTF8String: head], @"%@", @"Yes", @"No", NULL, [NSString stringWithUTF8String: msg]) == NSAlertDefaultReturn)
		return false;
	return true;
}


bool errorBox (const char * head, const char * msg) {
	NSRunAlertPanel ([NSString stringWithUTF8String: head], @"%@", NULL, NULL, NULL, [NSString stringWithUTF8String: msg]);
	return false;
}

unsigned int stringToInt (char * s) {
	int i = 0;
	for (;;) {
		if (*s >= '0' && *s <= '9') {
			i *= 10;
			i += *s - '0';
			s ++;
		} else {
			return i;
		}
	}
}

void readIniFile () {
	unsigned char appsupport_path[1024];
	FSRef foundRef;

	// Find the preference folder and go there
	FSFindFolder (kUserDomain, kPreferencesFolderType , kDontCreateFolder, &foundRef);	
	FSRefMakePath( &foundRef, appsupport_path, 1024);
	chdir ((char *) appsupport_path);
	mkdir ("SLUDGE Development Kit", 0000777);
	chdir ("SLUDGE Development Kit");

	FILE * fp = fopen ("SLUDGE.ini", "rb");
	
	programSettings.compilerKillImages = 0;
	programSettings.compilerWriteStrings = 0;
	programSettings.compilerVerbose = 1;
	programSettings.searchSensitive = 0;
		
	if (fp) {
		char lineSoFar[257] = "";
		char secondSoFar[257] = "";
		unsigned char here = 0;
		char readChar = ' ';
		bool keepGoing = true;
		bool doingSecond = false;
		
		do {
			readChar = fgetc (fp);
			if (feof (fp)) {
				readChar = '\n';
				keepGoing = false;
			}
			switch (readChar) {
				case '\n':
				case '\r':

					fprintf (fp, "KillImages=%d\n", programSettings.compilerKillImages);
					fprintf (fp, "WriteStrings=%d\n", programSettings.compilerWriteStrings);
					fprintf (fp, "Verbose=%d\n", programSettings.compilerVerbose);
					fprintf (fp, "SearchSensitive=%d\n", programSettings.searchSensitive);
					
					
					if (doingSecond) {
						if (strcmp (lineSoFar, "KillImages") == 0)
						{
							programSettings.compilerKillImages = stringToInt (secondSoFar);
						}
						else if (strcmp (lineSoFar, "WriteStrings") == 0)
						{
							programSettings.compilerWriteStrings = stringToInt (secondSoFar);
						}
						else if (strcmp (lineSoFar, "Verbose") == 0)
						{
							programSettings.compilerVerbose = stringToInt (secondSoFar);
						}
						else if (strcmp (lineSoFar, "SearchSensitive") == 0)
						{
							programSettings.searchSensitive = stringToInt (secondSoFar);
						}
					}
					here = 0;
					doingSecond = false;
					lineSoFar[0] = 0;
					secondSoFar[0] = 0;
					break;
					
				case '=':
					doingSecond = true;
					here = 0;
					break;
					
				default:
					if (doingSecond) {
						secondSoFar[here ++] = readChar;
						secondSoFar[here] = 0;
					} else {
						lineSoFar[here ++] = readChar;
						lineSoFar[here] = 0;
					}
					break;
			}
		} while (keepGoing);
		
		fclose (fp);
	}
}


int main(int argc, char *argv[])
{
	
	readIniFile ();
	
	return NSApplicationMain (argc, (const char **) argv);
}
