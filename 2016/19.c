#include <stdio.h>

#define NUM_ELVES 3018458

typedef struct Link {
  struct Link * next;
  struct Link * prev;
  int id;
} Link;

Link elves[NUM_ELVES];

int main() {
  int i, num_elves;
  struct Link *across, *next_across;

  for (i = 0; i < NUM_ELVES; i++) {
    elves[i].next = &elves[(i+1)%NUM_ELVES];
    elves[i].prev = &elves[(i-1)%NUM_ELVES];
    elves[i].id = i;
  }

  num_elves = NUM_ELVES;
  across = &elves[NUM_ELVES / 2];
  while (across != across->next) {
    printf("%d\n", num_elves);
    if (num_elves == 3) {
      i = across->next->id;
      break;
    } else if (num_elves % 2 == 0) {
      next_across = across->next->next;
    } else {
      next_across = across->next;
    }

    if (next_across == across) {
      next_across = across->next;
    }

    across->prev->next = across->next;
    across->prev = NULL;
    across->next = NULL;
    across = next_across;
    num_elves--;
  }

  printf("%d\n", i + 1);

  return 0;
}

