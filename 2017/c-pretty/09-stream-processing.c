#include <stdio.h>

#include "common/loadinput.h"

int main() {
  char *stream, *c;
  int level, score, garbage;
  int in_escape, in_garbage;

  level = 0; // nesting level of the group we're in
  score = 0; // total score of groups we've closed so far
  garbage = 0; // amount of non-escaped garbage we've seen
  in_escape = 0; // whether the next character is !-escaped
  in_garbage = 0;  // whether we're in <>-delimited garbage

  stream = loadinput("input/input09", NULL);

  for (c = stream; *c; c++) {
    // !-escapes always take precedence
    if (in_escape) { in_escape = 0; continue; }
    if (*c == '!') { in_escape = 1; continue; }

    // then <>-delimited garbage
    if (in_garbage) {
      if (*c == '>') { in_garbage = 0; }
      else           { garbage++; }
      continue;
    }

    // then the rest
    switch (*c) {
      case '<':
        in_garbage = 1;
        break;
      case '{':
        level++;
        break;
      case '}':
        score += level;
        level--;
        break;
    }
  }

  free(stream);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", score);
  printf("  Part 2: %d\n", garbage);

  return 0;
}

