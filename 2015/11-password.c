#include <stdio.h>

#define PASSLEN 8

int has_straight(const char *pw) {
  return (pw[0]+1 == pw[1] && pw[0]+2 == pw[2]) ||
         (pw[1]+1 == pw[2] && pw[1]+2 == pw[3]) ||
         (pw[2]+1 == pw[3] && pw[2]+2 == pw[4]) ||
         (pw[3]+1 == pw[4] && pw[3]+2 == pw[5]) ||
         (pw[4]+1 == pw[5] && pw[4]+2 == pw[6]) ||
         (pw[5]+1 == pw[6] && pw[5]+2 == pw[7]);
}

int has_doubles(const char *pw) {
  int i, j;
  for (i = 0; i <= 4; i++) {
    for (j = i + 2; j <= 6; j++) {
      if (pw[i] == pw[i+1] && pw[j] == pw[j+1] && pw[i] != pw[j]) {
        return 1;
      }
    }
  }
  return 0;
}

int has_no_iols(const char *pw) {
  int i;
  for (i = 0; i < 8; i++) {
    if (pw[i] == 'i' || pw[i] == 'o' || pw[i] == 'l') {
      return 0;
    }
  }
  return 1;
}

int is_valid(const char *pw) {
  return has_no_iols(pw) && has_straight(pw) && has_doubles(pw);
}

void increment_pw(char *pw) {
  int i;
  for (i = 7; i >= 0; i--) {
    if (pw[i] == 'z') {
      pw[i] = 'a';
    } else {
      pw[i]++;
      break;
    }
  }
}

int main() {
  char cur[PASSLEN+1] = "vzbxkghb";

  while (!is_valid(cur)) { increment_pw(cur); }
  increment_pw(cur);
  while (!is_valid(cur)) { increment_pw(cur); }

  printf("%s\n", cur);

  return 0;
}

