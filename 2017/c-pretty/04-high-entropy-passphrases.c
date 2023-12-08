#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/loadinput.h"

#define SPLIT_BY_WHITESPACE " \t\n"
#define MAX_WORDS 31

typedef struct {
  char **items;
  size_t num_slots;
} Set;

// http://www.cse.yorku.ca/~oz/hash.html
static size_t set_hash(const char *value) {
  size_t hash = 5381;
  int c;

  while ((c = *value++)) {
    hash = ((hash << 5) + hash) + c;
  }

  return hash;
}

static Set *set_new() {
  Set *set = malloc(sizeof(Set));

  set->num_slots = MAX_WORDS; // no need to resize/rehash
  set->items = calloc(set->num_slots, sizeof(char*));

  return set;
}

static void set_free(Set *set) {
  size_t i;
  for (i = 0; i < set->num_slots; i++) {
    free(set->items[i]);
  }
  free(set->items);
  free(set);
}

static int set_insert(Set *set, const char *value) {
  size_t i, j;

  i = set_hash(value) % set->num_slots;

  for (j = 0; j < set->num_slots; j++) {
    if (set->items[i] == NULL) {
      set->items[i] = strdup(value);
      return 1;
    } else if (!strcmp(set->items[i], value)) {
      return 0;
    }
    i = (i+1) % set->num_slots;
  }

  return 0;
}

static int compare_char(const void *a, const void *b) {
  return strncmp(a, b, 1);
}

static int has_duplicates(char *passphrase, int anagram_mode) {
  char *p;
  Set *words = set_new();

  p = strtok(passphrase, SPLIT_BY_WHITESPACE);
  while (p != NULL) {
    if (anagram_mode) {
      qsort(p, strlen(p), sizeof(char), compare_char);
    }
    if (!set_insert(words, p)) {
      set_free(words);
      return 1;
    }
    p = strtok(NULL, SPLIT_BY_WHITESPACE);
  }

  set_free(words);

  return 0;
}

int main() {
  FILE *fp;
  char *line = NULL;
  char *passphrase;
  size_t linecap = 0;
  ssize_t linelen;
  int num_no_duplicates, num_no_anagrams;

  fp = fopen("input/input04", "r");

  num_no_duplicates = 0;
  num_no_anagrams = 0;
  while ((linelen = getline(&line, &linecap, fp)) != -1) {
    passphrase = strdup(line);
    if (!has_duplicates(passphrase, 0)) num_no_duplicates++;
    free(passphrase);

    passphrase = strdup(line);
    if (!has_duplicates(passphrase, 1)) num_no_anagrams++;
    free(passphrase);
  }

  free(line);
  fclose(fp);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", num_no_duplicates);
  printf("  Part 2: %d\n", num_no_anagrams);

  return 0;
}
