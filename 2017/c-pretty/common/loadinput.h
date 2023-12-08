#include <stdio.h>
#include <stdlib.h>

#define LOADINPUT_CHUNK_SIZE 4096

char *loadinput(const char *path, size_t *len_out) {
  FILE *fp;
  char *buffer;
  size_t nread, i;

  fp = fopen(path, "r");
  buffer = NULL;
  i = 0;
  while (!feof(fp)) {
    buffer = realloc(buffer, i + LOADINPUT_CHUNK_SIZE);
    i += fread(&buffer[i], 1, LOADINPUT_CHUNK_SIZE, fp);
  }
  fclose(fp);

  if (i % LOADINPUT_CHUNK_SIZE == 0) {
    buffer = realloc(buffer, i + 1);
  }
  buffer[i] = '\0';

  if (len_out) {
    *len_out = i;
  }

  return buffer;
}

