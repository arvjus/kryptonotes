/*
 * KryptoNotes - a command line utility for file encryption and decryption using OpenSSL
 * this utility keeps data compatibility with kryptonotes-1.0 version.
 *
 * Copyright (C) 2007-2012 Arvid Juskaitis <arvydas.juskaitis (at) gmail (dot) com>
 */


/* AlgorighmId */
#define	ALGO_NONE			0
#define	ALGO_BLOWFISH_CBC	1


/* File header */
#pragma pack(1)
typedef struct _FileHeader {
    unsigned char magic[3];     /* 0xb0, 0xb0, 0xd0 */
    unsigned char hdr_len;      /* the length of header */
    unsigned char algo_id;      /* currently ALGO_NONE or ALGO_BLOWFISH_CBC */
    unsigned char doc_ver;      /* Document version */
    unsigned char updated[20];  /* Timestamp of last changes. yyyy-mm-dd hh.mm.ss */
    unsigned char reserved[4];  /* not used, must be set to 0 */
} FileHeader;
#pragma pack()


/* returns nonzero if header is compatible with program */
int validate_header(FileHeader *header);

/* calculates buffer size required for output */
int calculate_output_size(int insize);

/* returns number of bytes written on -1 in case of error. size of outbuf must be >= sizeof(FileHeader) */ 
int buffer_write_header(char *outbuf, char algoid, char docver);

/* returns 0 - success, -1 - error */
int buffer_read_header(char *inbuf, int inlen, int *phdrlen, int *enc, char *algo, int *pdocver, char *updated);

/* returns 0 - success, -1 - error */
int buffer_encrypt(char *password, char *inbuf, int inlen, char *outbuf, int *poutlen);

/* returns 0 - success, -1 - error */
int buffer_decrypt(char *password, char *inbuf, int inlen, char *outbuf, int *poutlen);


/* returns number of bytes written on -1 in case of error */
int file_write_header(FILE *out, char algoid, char docver);

/* returns 0 - success, -1 - error */
int file_read_header(FILE *in, int *phdrlen, int *enc, char *algo, int *pdocver, char *updated);

/* returns 0 - success, -1 - error */
int file_encrypt(char *password, FILE *in, FILE *out);

/* returns 0 - success, -1 - error */
int file_decrypt(char *password, FILE *in, FILE *out);


