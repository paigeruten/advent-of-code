#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/loadinput.h"

#define NUM_BANKS 16

typedef struct {
  int memory[NUM_BANKS];
  size_t cycles;
} Sighting;

typedef struct {
  Sighting *sightings;
  size_t nitems, nslots;
} SeenTable;

// http://www.cse.yorku.ca/~oz/hash.html
static size_t seen_hash(const int *memory) {
  size_t hash = 5381;
  size_t i;

  for (i = 0; i < NUM_BANKS; i++) {
    hash = ((hash << 5) + hash) + memory[i];
  }

  return hash;
}

static SeenTable *seen_new() {
  SeenTable *seen = malloc(sizeof(SeenTable));

  seen->nitems = 0;
  seen->nslots = 255;
  seen->sightings = calloc(seen->nslots, sizeof(Sighting));

  return seen;
}

static void seen_free(SeenTable *seen) {
  free(seen->sightings);
  free(seen);
}

static Sighting *seen_lookup(SeenTable *seen, const int *memory) {
  size_t i, j;

  i = seen_hash(memory) % seen->nslots;

  for (j = 0; j < seen->nslots; j++) {
    if (seen->sightings[i].cycles == 0) {
      return &seen->sightings[i];
    } else if (!memcmp(seen->sightings[i].memory, memory, NUM_BANKS * sizeof(int))) {
      return &seen->sightings[i];
    }
    i = (i+1) % seen->nslots;
  }

  return NULL;
}

static void seen_resize(SeenTable *seen) {
  size_t i, old_nslots;
  Sighting *old_sightings, *slot;

  if (seen->nslots > seen->nitems) return;

  old_nslots = seen->nslots;
  old_sightings = seen->sightings;

  seen->nslots = (old_nslots + 1)*2 - 1;
  seen->sightings = calloc(seen->nslots, sizeof(Sighting));

  for (i = 0; i < old_nslots; i++) {
    if (old_sightings[i].cycles) {
      slot = seen_lookup(seen, old_sightings[i].memory);
      memcpy(slot->memory, old_sightings[i].memory, NUM_BANKS * sizeof(int));
      slot->cycles = old_sightings[i].cycles;
    }
  }

  free(old_sightings);
}

static void read_memory(char *input, int *memory) {
  size_t i;
  char *p;

  i = 0;
  p = strtok(input, " \t\n");
  while (p && i < NUM_BANKS) {
    memory[i++] = atoi(p);
    p = strtok(NULL, " \t\n");
  }
}

static size_t array_max(const int *ary, size_t n) {
  size_t i, max_i;
  int max;

  max_i = 0;
  max = ary[0];
  for (i = 0; i < n; i++) {
    if (ary[i] > max) {
      max = ary[i];
      max_i = i;
    }
  }

  return max_i;
}

static void run_cycle(int *memory) {
  size_t i;
  int max;

  i = array_max(memory, NUM_BANKS);
  max = memory[i];
  memory[i] = 0;
  while (max > 0) {
    i = (i+1) % NUM_BANKS;
    memory[i]++;
    max--;
  }
}

static size_t see(const int *memory, SeenTable *seen, size_t cycles) {
  Sighting *slot;

  seen_resize(seen);
  slot = seen_lookup(seen, memory);

  if (slot->cycles) {
    return slot->cycles;
  } else {
    seen->nitems++;
    memcpy(slot->memory, memory, NUM_BANKS * sizeof(int));
    slot->cycles = cycles;
    return 0;
  }
}

static void print_memory(const int *memory) {
  size_t i;

  for (i = 0; i < NUM_BANKS; i++) {
    printf("%d\t", memory[i]);
  }
  printf("\n");
}

int main() {
  size_t cycles, seen_at;
  char *input;
  int memory[NUM_BANKS];
  SeenTable *seen;

  input = loadinput("input/input06", NULL);
  read_memory(input, memory);
  free(input);

  cycles = 1;
  seen = seen_new();
  while (1) {
    seen_at = see(memory, seen, cycles);
    if (seen_at) break;

    run_cycle(memory);
    cycles++;
  }
  seen_free(seen);

  printf("Solutions:\n");
  printf("  Part 1: %zu\n", cycles - 1);
  printf("  Part 2: %zu\n", cycles - seen_at);

  return 0;
}
