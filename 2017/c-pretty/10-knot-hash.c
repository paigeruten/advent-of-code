#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/loadinput.h"

#define HASH_LEN 256

typedef struct {
  unsigned char list[HASH_LEN];
  int *lengths;
  size_t nlengths;
  int pos;
  int skip;
} Hash;

static void hash_init(Hash *hash, int *lengths, size_t nlengths) {
  size_t i;
  for (i = 0; i < HASH_LEN; i++) {
    hash->list[i] = (unsigned char)i;
  }

  hash->lengths = lengths;
  hash->nlengths = nlengths;
  hash->pos = 0;
  hash->skip = 0;
}

static void hash_reverse(unsigned char *list, int from, int to) {
  unsigned char temp;

  if (from == to) return;

  // to is exclusive
  to--;
  if (to == -1) to = HASH_LEN - 1;

  if (to < from) to += HASH_LEN;

  while (from < to) {
    temp = list[from % HASH_LEN];
    list[from % HASH_LEN] = list[to % HASH_LEN];
    list[to % HASH_LEN] = temp;

    from++; to--;
  }
}

static void hash_round(Hash *hash) {
  size_t i;
  for (i = 0; i < hash->nlengths; i++) {
    hash_reverse(hash->list, hash->pos, (hash->pos + hash->lengths[i]) % HASH_LEN);

    hash->pos = (hash->pos + hash->lengths[i] + hash->skip) % HASH_LEN;
    hash->skip++;
  }
}

static void hash_condense(Hash *hash) {
  size_t i, j;
  int block_xor;

  for (i = 0; i < HASH_LEN / 16; i++) {
    block_xor = 0;
    for (j = i*16; j < (i+1)*16 && j < HASH_LEN; j++) {
      block_xor ^= hash->list[j];
    }
    hash->list[i] = block_xor;
  }
}

static void hash_tostring(Hash *hash, char *str) {
  size_t i;
  for (i = 0; i < HASH_LEN / 16; i++) {
    snprintf(str, 3, "%02x", hash->list[i]);
    str += 2;
  }
}

static int *read_lengths(char *input, size_t *nread) {
  char *p;
  int *lengths;
  size_t nitems, nslots;

  nitems = 0;
  nslots = 8;
  lengths = malloc(nslots * sizeof(int));

  p = strtok(input, ", \t\n");
  while (p) {
    if (nitems >= nslots) {
      nslots *= 2;
      lengths = realloc(lengths, nslots * sizeof(int));
    }
    lengths[nitems++] = atoi(p);
    p = strtok(NULL, ", \t\n");
  }

  *nread = nitems;
  return lengths;
}

static int *read_chars(char *input, size_t *nread) {
  char *p;
  int *chars;
  size_t nitems;

  nitems = 0;
  chars = malloc(strlen(input) * sizeof(int));

  p = input;
  while (*p) {
    if (!isspace(*p)) {
      chars[nitems++] = *p;
    }
    p++;
  }

  *nread = nitems;
  return chars;
}

int main() {
  char *input;
  int *lengths;
  size_t nlengths, round;
  Hash hash;
  int first_two;
  char hex[33];

  // Part 1
  input = loadinput("input/input10", NULL);
  lengths = read_lengths(input, &nlengths);
  hash_init(&hash, lengths, nlengths);
  hash_round(&hash);
  first_two = hash.list[0] * hash.list[1];
  free(lengths);
  free(input);

  // Part 2
  input = loadinput("input/input10", NULL);
  lengths = read_chars(input, &nlengths);
  nlengths += 5;
  lengths = realloc(lengths, nlengths * sizeof(int));
  lengths[nlengths-5] = 17;
  lengths[nlengths-4] = 31;
  lengths[nlengths-3] = 73;
  lengths[nlengths-2] = 47;
  lengths[nlengths-1] = 23;
  hash_init(&hash, lengths, nlengths);
  for (round = 0; round < 64; round++) {
    hash_round(&hash);
  }
  hash_condense(&hash);
  hash_tostring(&hash, hex);
  free(lengths);
  free(input);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", first_two);
  printf("  Part 2: %s\n", hex);

  return 0;
}

