#ifndef __COMPILERINFO_H__
#define __COMPILERINFO_H__

#ifdef __cplusplus
extern "C" {
#endif
	
typedef struct
{
	double progress1;
	double progress2;
	char task[1000];
	char file[1000];
	char item[1000];
	int funcs;
	int objs;
	int globs;
	int strings;
	int resources;
	bool newComments;
	bool finished;
	bool success;
} compilerInfo;

enum whichPerc {
	P_TOP,
	P_BOTTOM
};

enum compilerStatusText {
	COMPILER_TXT_ACTION,
	COMPILER_TXT_FILENAME,
	COMPILER_TXT_ITEM
};

#ifdef __APPLE__
	void setCompilerText (const enum compilerStatusText where, const char * theText);
#else
	void setCompilerText (const compilerStatusText where, const char * theText);
#endif
void setCompilerStats (int funcs, int objTypes, int files, int globals, int strings);	
	
void setInfoReceiver(void (*infoReceiver)(compilerInfo *));
void clearRect(int i, int whichBox);
void percRect(unsigned int i, int whichBox);

void compilerCommentsUpdated();
void setFinished(bool success);

#ifdef __cplusplus
}
#endif
		
#endif
