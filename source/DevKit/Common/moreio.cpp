#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


#include "moreio.h"

#define MOVETEXT 1

#if defined __unix__ && !(defined __APPLE__)
#include <endian.h>
#if __BYTE_ORDER == __BIG_ENDIAN
#define __BIG_ENDIAN__
#endif
#endif

char * readString (FILE * fp) {
	int n = get2bytes (fp), a;
	char * grabber = new char[n + 1];

//	checkNew (grabber);

	for (a = 0; a < n; a ++) {
		grabber[a] = (char) (fgetc (fp) - MOVETEXT);
	}
	grabber[n] = 0;

	return grabber;
}

void put2bytes (unsigned int numtoput, FILE * fp) {
	fputc ((unsigned char) (numtoput / 256), fp);
	fputc ((unsigned char) (numtoput % 256), fp);
}

void put2bytesR (int numtoput, FILE * fp) {
	fputc ((char) (numtoput % 256), fp);
	fputc ((char) (numtoput / 256), fp);
}

void put4bytes (int32_t i, FILE * fp) {
//	fwrite (&i, sizeof (long int), 1, fp);
	unsigned char f1, f2, f3, f4;

	f4 = i / (256*256*256);
	i = i % (256*256*256); 
	f3 = i / (256*256);
	i = i % (256*256); 
	f2 = i / 256;
	f1 = i % 256;
	
	fputc (f1, fp);
	fputc (f2, fp);
	fputc (f3, fp);
	fputc (f4, fp);
}


unsigned int get2bytes (FILE * fp) {
	return fgetc (fp) * 256 + fgetc (fp);
}

void deleteString(char * s) {
	delete[] s;
}

char * copyString (const char * c) {
	char * r = new char[strlen (c) + 1];
	if (! r) return NULL;
	strcpy (r, c);
	return r;
}

int32_t get4bytes (FILE * fp) {
	int f1, f2, f3, f4;
	
	f1 = fgetc (fp);
	f2 = fgetc (fp);
	f3 = fgetc (fp);
	f4 = fgetc (fp);
		
	return (f1 + f2*256 + f3*256*256 + f4*256*256*256);
	
	/*
	 
	 int32_t f;
	 fread (& f, sizeof (int32_t), 1, fp);
	 return f;*/
}

void writeString (const char * txt, FILE * fp) {
	int a, n = strlen (txt);

	put2bytes (n, fp);

	for (a = 0; a < n; a ++) {
		fputc (txt[a] + MOVETEXT, fp);
	}
}

char * readText (FILE * fp) {
	char * reply;
	int stringSize, i = 1;
	bool goOn = true;
	fpos_t startPosition;
	fgetpos ( fp, &startPosition );
	while (goOn) {
		stringSize = 200*i;
		reply = new char[stringSize];
		if (fgets ( reply, stringSize, fp )) {
			if (strlen(reply) < stringSize - 1) {
				// Get rid of the newline character:
				while (reply[strlen(reply)-1] == '\x0A' || reply[strlen(reply)-1] == '\x0D') {
					reply[strlen(reply)-1] = 0;        // remove line ending characters if present
				}
				goOn = false;
			} else {
				delete reply;
				fsetpos ( fp, &startPosition );
				i++;
			}
		} else {
			delete reply;
			reply = NULL;
			goOn = false;
		}
	}
	return reply;
}

char * grabWholeFile (char * theName) {
	FILE * inputFile;
	char * allText;
	long int size;

	inputFile = fopen (theName, "rb");
	if (! inputFile) return NULL;//fatal ("Can't read file", theName);

	fseek (inputFile, 0, 2);		// Jump to the end
	size = ftell (inputFile);	// Get the position
	fseek (inputFile, 0, 0);		// Back to the start

//	if (size >= MAXINT - 2) fatal ("File too big to read into memory", theName);

	// Allocate memory... then read and close the file

	allText = new char[size + 1];
//	checkNew (allText);
	size_t bytes_read = fread (allText, size, 1, inputFile);
	if (bytes_read != size && ferror (inputFile)) {
		fprintf(stderr, "Reading error in grabWholeFile.\n");
	}
	allText[size] = 0;
	fclose (inputFile);

	return allText;
}


bool newerFile (char * newFileN, char * oldFileN) {

	struct stat oldFileStat, newFileStat;
	if (stat (oldFileN, & oldFileStat)) return true;
	if (stat (newFileN, & newFileStat)) return true;
	return difftime (oldFileStat.st_mtime, newFileStat.st_mtime) <= 0;

}

float floatSwap( float f )
{
	union
	{
		float f;
		unsigned char b[4];
	} dat1, dat2;
	
	dat1.f = f;
	dat2.b[0] = dat1.b[3];
	dat2.b[1] = dat1.b[2];
	dat2.b[2] = dat1.b[1];
	dat2.b[3] = dat1.b[0];
	return dat2.f;
}


float getFloat (FILE * fp) {
	float f;
	size_t bytes_read = fread (& f, sizeof (float), 1, fp);
	if (bytes_read != sizeof (float) && ferror (fp)) {
		fprintf(stderr, "Reading error in getFloat.\n");
	}
	
#ifdef	__BIG_ENDIAN__
	return floatSwap(f);
#else
	return f;
#endif
}

void putFloat (float f, FILE * fp) {
#ifdef	__BIG_ENDIAN__
	f = floatSwap(f);
#endif
	fwrite (& f, sizeof (float), 1, fp);
}

short shortSwap( short s )
{
	unsigned char b1, b2;
	
	b1 = s & 255;
	b2 = (s >> 8) & 255;
	
	return (b1 << 8) + b2;
}


short getSigned (FILE * fp) {
	short f;
	size_t bytes_read = fread (& f, sizeof (short), 1, fp);
	if (bytes_read != sizeof (short) && ferror (fp)) {
		fprintf(stderr, "Reading error in getSigned.\n");
	}
#ifdef	__BIG_ENDIAN__
	f = shortSwap(f);
#endif
	return f;
}

void putSigned (short f, FILE * fp) {
#ifdef	__BIG_ENDIAN__
	f = shortSwap(f);
#endif
	fwrite (& f, sizeof (short), 1, fp);
}
