/*
 * KryptoNotes - a command line utility for file encryption and decryption using OpenSSL
 * this utility keeps data compatibility with kryptonotes-1.0 version.
 *
 * Copyright (C) 2007-2012 Arvid Juskaitis <arvydas.juskaitis (at) gmail (dot) com>
 */

#include <unistd.h>
#include <getopt.h>
#include <stdarg.h>
#include <errno.h>
#include <strings.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <openssl/evp.h>

#include "crypt.h"

/* Operation type */
typedef enum {
    Undefined = -1,
    Decryption = 0,
    Encryption = 1
} OperationType;


/* file header */
FileHeader file_header = { {0x0b, 0x0b, 0x0d}, sizeof(FileHeader) };

/* forward declaration */
int buffer_do_crypt(OperationType operation_type, char *password, char *inbuf, int inlen, char *outbuf, int *poutlen);
int file_do_crypt(OperationType operation_type, char *password, FILE *in, FILE *out);


#pragma mark helper functions

/* returns nonzero if header is compatible with program */
int validate_header(FileHeader *pheader)
{
    if (memcmp(pheader->magic, &file_header.magic, sizeof(file_header.magic)) != 0) {
        return 0;
    }
    if (pheader->hdr_len < sizeof(FileHeader)) {
        return 0;
    }
    if (pheader->algo_id != ALGO_NONE && pheader->algo_id != ALGO_BLOWFISH_CBC) {
        return 0;
    }

    return 1;
}

/* calculates buffer size required for output */
int calculate_output_size(int insize)
{
    return sizeof(FileHeader) + insize + EVP_MAX_BLOCK_LENGTH;
}


#pragma mark buffer operations

/* returns number of bytes written on -1 in case of error */ 
int buffer_write_header(char *outbuf, char algoid, char docver)
{
	FileHeader *pheader = (FileHeader *)outbuf;
    time_t now = time(NULL);

    memcpy(outbuf, &file_header, sizeof(FileHeader));
	pheader->algo_id = algoid;
	pheader->doc_ver = docver;
    strftime((char *)pheader->updated, sizeof(pheader->updated), "%Y-%m-%d %H:%M:%S", localtime(&now));
    return sizeof(FileHeader);
}

int buffer_read_header(char *inbuf, int inlen, int *phdrlen, int *enc, char *algo, int *pdocver, char *updated)
{
	FileHeader *pheader = (FileHeader *)inbuf;
	if (inlen < sizeof(FileHeader) || !validate_header(pheader) || inlen < pheader->hdr_len) {
		return -1;
	}
	
    *phdrlen = pheader->hdr_len;
    *enc = 0;
    *pdocver = pheader->doc_ver;
	switch(pheader->algo_id) {
	case ALGO_NONE:
		strcpy(algo, "ClearText");
		break;
	
	case ALGO_BLOWFISH_CBC:
        *enc = 1;
		strcpy(algo, "BlowFish CBC");
		break;
		
	default:
		strcpy(algo, "Unsupported");
	};
    memcpy(updated, pheader->updated, sizeof(pheader->updated));
	return 0;
}

int buffer_encrypt(char *password, char *inbuf, int inlen, char *outbuf, int *poutlen)
{
    return buffer_do_crypt(Encryption, password, inbuf, inlen, outbuf, poutlen);
}

int buffer_decrypt(char *password, char *inbuf, int inlen, char *outbuf, int *poutlen)
{
    return buffer_do_crypt(Decryption, password, inbuf, inlen, outbuf, poutlen);
}


#pragma mark file operations

int file_write_header(FILE *out, char algoid, char docver)
{
    char header_data[256];
    int header_data_len;

    header_data_len = buffer_write_header(header_data, algoid, docver);
    if (header_data_len <= 0) {
        return -1;
    }

    return fwrite(&header_data, 1, header_data_len, out) == header_data_len ? 0 : -1;
}

int file_read_header(FILE *in, int *phdrlen, int *enc, char *algo, int *pdocver, char *updated)
{
    int header_data_len;
    char header_data[256];
	FileHeader *pheader = (FileHeader *)&header_data;
    
    if (fread(&header_data, 1, sizeof(FileHeader), in) != sizeof(FileHeader)) {
        return -1;
    }

    header_data_len = pheader->hdr_len - sizeof(FileHeader);
    if (pheader->hdr_len > sizeof(FileHeader) || 
        header_data_len > 0 && 
        fread(&header_data + sizeof(FileHeader), 1, header_data_len, in) != header_data_len) {
        return -1;
    }

	return buffer_read_header(header_data, sizeof(header_data), phdrlen, enc, algo, pdocver, updated);
}

int file_encrypt(char *password, FILE *in, FILE *out)
{
    return file_do_crypt(Encryption, password, in, out);
}

int file_decrypt(char *password, FILE *in, FILE *out)
{
    return file_do_crypt(Decryption, password, in, out);
}


#pragma mark SSL encryption/decryption

/* do buffer encryption/decryption */
int buffer_do_crypt(OperationType operation_type, char *password, char *inbuf, int inlen, char *outbuf, int *poutlen)
{
    EVP_CIPHER_CTX ctx;
    int outlen = 0;

    /* Don’t set key or IV because we will modify the parameters */
    EVP_CIPHER_CTX_init(&ctx);
    EVP_CipherInit_ex(&ctx, EVP_bf_cbc(), NULL, NULL, NULL, operation_type);
    EVP_CIPHER_CTX_set_key_length(&ctx, strlen(password));

    /* We finished modifying parameters so now we can set key and IV */
    EVP_CipherInit_ex(&ctx, NULL, NULL, password, NULL, operation_type);

    if (!EVP_CipherUpdate(&ctx, outbuf, &outlen, inbuf, inlen)) {
        /* Error */
        EVP_CIPHER_CTX_cleanup(&ctx);
        return -1;
    }

    if (!EVP_CipherFinal_ex(&ctx, outbuf + outlen, poutlen)) {
        /* Error */
        EVP_CIPHER_CTX_cleanup(&ctx);
        return -1;
    }
    *poutlen += outlen;

    EVP_CIPHER_CTX_cleanup(&ctx);
    return 0;
}

/* do file encryption/decryption */
int file_do_crypt(OperationType operation_type, char *password, FILE *in, FILE *out)
{
    /* Allow enough space in output buffer for additional block */
    char inbuf[1024], outbuf[1024 + EVP_MAX_BLOCK_LENGTH];
    int inlen, outlen;
    EVP_CIPHER_CTX ctx;

    /* Don’t set key or IV because we will modify the parameters */
    EVP_CIPHER_CTX_init(&ctx);
    EVP_CipherInit_ex(&ctx, EVP_bf_cbc(), NULL, NULL, NULL, operation_type);
    EVP_CIPHER_CTX_set_key_length(&ctx, strlen(password));

    /* We finished modifying parameters so now we can set key and IV */
    EVP_CipherInit_ex(&ctx, NULL, NULL, password, NULL, operation_type);

    for (;;) {
        inlen = fread(inbuf, 1, sizeof(inbuf), in);
        if (inlen <= 0)
            break;

        if (!EVP_CipherUpdate(&ctx, outbuf, &outlen, inbuf, inlen)) {
            /* Error */
            EVP_CIPHER_CTX_cleanup(&ctx);
            return -1;
        }
        fwrite(outbuf, 1, outlen, out);
    }

    if (!EVP_CipherFinal_ex(&ctx, outbuf, &outlen)) {
        /* Error */
        EVP_CIPHER_CTX_cleanup(&ctx);
        return -1;
    }
    fwrite(outbuf, 1, outlen, out);

    EVP_CIPHER_CTX_cleanup(&ctx);

    return 0;
}



