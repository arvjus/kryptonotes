/*
 * KryptoNotes - a command line utility for file encryption and decryption using OpenSSL
 * this utility keeps data compatibility with kryptonotes-1.0 version.
 *
 * Copyright (C) 2007-2012 Arvid Juskaitis <arvydas.juskaitis (at) gmail (dot) com>
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdarg.h>
#include <errno.h>
#include <strings.h>
#include <string.h>

#include "crypt.h"

/* definitions */
#define KEY_MAX_LEN		20


/* Action */
typedef enum {
    Undef   = -1,
    Decrypt = 0,
    Encrypt = 1,
    Read    = 2,
    Write   = 3,
    Info    = 4
} Action;


/* keep arguments */
char    *input_filename = (char *)NULL;
char    *output_filename = (char *)NULL;
Action  action = Undef;
char	password[KEY_MAX_LEN];
char    doc_ver = 0;


/* print usage */
void print_help(FILE* stream, int exit_code)
{
	fprintf(stream,
			"KryptoNotes v1.0 - utility to encrypt/decrypt files\n"
			"Copyright (C) 2007-2012 by Arvydas Juskaitis. All rights reserved\n\n"
			"usage: kryponotes [OPTIONS]\n"
			"-h,      --help           Print this option list, then exit.\n"
			"-I,      --info           Display document info\n"
			"-E,      --enc            Perform encryption\n"
			"-D,      --dec            Perform decryption\n"
			"-R,      --read           Extract clear text file\n"
			"-W,      --write          Write/create clear text document\n"
			"-i file, --in=file        Input file\n"
			"-o file, --out=file       Output file\n"
			"-p pwd,  --pwd=pwd        Password for encryption/decryption\n"
			"-v ver,  --ver=ver        Document version\n"
			);
	
	exit(exit_code);
}

/* print error message */
void print_error(const char* fmt, ...) 
{
	va_list list;
	va_start(list, fmt);
	vfprintf(stderr, fmt, list);
	va_end(list);
	exit(1);
}

/* parse command line */
void get_options(int argc, char* argv[])
{
	int next_option;
	
	const char* const short_options = "hIEDRWi:o:p:v:";
	
	const struct option long_options[] = {
		{ "help",		0, NULL, 'h' },
		{ "info",		0, NULL, 'I' },
		{ "enc",		0, NULL, 'E' },
		{ "dec",		0, NULL, 'D' },
		{ "read",		0, NULL, 'R' },
		{ "write",		0, NULL, 'W' },
		{ "in",			1, NULL, 'i' },
		{ "out",		1, NULL, 'o' },
		{ "pwd",		1, NULL, 'p' },
		{ "ver",		1, NULL, 'v' },
		{ NULL,			0, NULL, 0   }
	};
	
	if (argc < 2) 
		print_help(stderr, 1);
	
	/* set initial values */
	memset(&password, 0, sizeof(password));
	
	/* get options */
	do {
		next_option = getopt_long(argc, argv, short_options, long_options, 0);
		
		switch(next_option) {
			case 'h':
				print_help(stdout, 0);
				
			case 'I':
				action = Info;
				break;
				
			case 'E':
				action = Encrypt;
				break;
				
			case 'D':
				action = Decrypt;
				break;
				
			case 'R':
				action = Read;
				break;
				
			case 'W':
				action = Write;
				break;
				
			case 'i':
				input_filename = optarg;
				break;
				
			case 'o':
				output_filename = optarg;
				break;
				
			case 'p':
				if (strlen(optarg) > KEY_MAX_LEN) {
					print_error("error: password is too long\n");
					exit(1);
				}
				strcpy(password, optarg);
				break;
				
			case 'v':
				doc_ver = atoi(optarg);
				break;
				
			case '?':
				print_help(stderr, 1);
		};
		
	} while (next_option != -1);
	
	/* check the rest */
	if (optind < argc) 
		print_help(stderr, 1);
	
	if (action == Undef) {
		print_error("error: operation type is not specified, set one of operations -I, -E, -D, -R. -W\n");
		exit(1);
	}
}

int copy_file(FILE *fin, FILE *fout)
{
    char buffer[100];
    int numr, numw;
	while (feof(fin) == 0) {	
	    if((numr = fread(buffer, 1, sizeof(buffer), fin)) != sizeof(buffer)){
		    if (ferror(fin) != 0) {
    		    return -1;
		    }
	    }
	    if((numw = fwrite(buffer, 1, numr, fout)) != numr){
		    fprintf(stderr,"write file error.\n");
		    return -1;
	    }
	}	
    return 0;
}

int main(int argc, char *argv[])
{
    FILE *fin, *fout;
    int rc = 0;
    int hdrlen = 0, enc = 0, docver;
    char algo[25], updated[25], buffer[1024];
	
	get_options(argc, argv);
	
    if (input_filename) {
	    fin = fopen(input_filename,"r");
	    if (!fin) {
			print_error("error: cannot open input file\n");
			exit(1);
	    }
    } else {
    	fin = stdin;
    }
	
    if (output_filename) {
	    fout = fopen(output_filename,"w");
	    if (!fout) {
			print_error("error: cannot create output file\n");
			exit(1);
	    }
    } else {
    	fout = stdout;
    }

	if (action == Info) {
		rc = file_read_header(fin, &hdrlen, &enc, algo, &docver, updated);
		if (rc == 0) {
        	fprintf(stdout, "Header length:    %d\n", hdrlen);
        	fprintf(stdout, "Algorithm:        %s\n", algo);
        	fprintf(stdout, "Document version: %d\n", docver);
        	fprintf(stdout, "Last updated:     %s\n", updated);
		}
	} else if (action == Write) {
		rc = file_write_header(fout, ALGO_NONE, doc_ver);
		if (rc == 0) {
   		    rc = copy_file(fin, fout);
		}
	} else if (action == Read) {
		rc = file_read_header(fin, &hdrlen, &enc, algo, &docver, updated);
		if (rc == 0) {
		    if (enc) {
		        rc = 1;
		    } else {
    		    rc = copy_file(fin, fout);
		    }
		}
	} else if (action == Encrypt || action == Decrypt) {
	    if (!password[0]) {
		    fprintf(stderr, "password: ");
		    scanf("%s", password);
	    }

	    if (action == Encrypt) {
		    rc = file_write_header(fout, ALGO_BLOWFISH_CBC, doc_ver);
		    if (rc == 0) {
        	    rc = file_encrypt(password, fin, fout);
		    }
	    }
	    if (action == Decrypt) {
		    rc = file_read_header(fin, &hdrlen, &enc, algo, &docver, updated);
		    if (rc == 0) {
		        if (!enc) {
		            rc = 1;
		        } else {
            	    rc = file_decrypt(password, fin, fout);
		        }
		    }
	    }
    }

    fclose(fin);
    fclose(fout);
	
    if (rc < 0) {
		unlink(output_filename);
		print_error("error: I/O or encryption error accoured\n");
		exit(1);
    } else if (rc > 0) {
		unlink(output_filename);
		print_error("error: wrong input file\n");
		exit(1);
    }
	
	return rc;
}

