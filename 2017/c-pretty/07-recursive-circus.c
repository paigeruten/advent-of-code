#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/loadinput.h"

#define SPLIT_BY_WHITESPACE_AND_SYMBOLS " \t\n()->,"
#define MAX_CHILDREN 15

typedef struct {
  char *name;
  int weight;
  int has_parent;
  char *children[MAX_CHILDREN + 1];
} Node;

typedef struct {
  Node *items;
  size_t nitems, nslots;
} NodeTable;

// http://www.cse.yorku.ca/~oz/hash.html
static size_t hash(const char *name) {
  size_t hash = 5381;
  int c;

  while ((c = *name++)) {
    hash = ((hash << 5) + hash) + c;
  }

  return hash;
}

static NodeTable *table_new() {
  NodeTable *table = malloc(sizeof(NodeTable));

  table->nitems = 0;
  table->nslots = 255;
  table->items = calloc(table->nslots, sizeof(Node));

  return table;
}

static void table_free(NodeTable *table) {
  size_t i;
  char **child;

  for (i = 0; i < table->nslots; i++) {
    free(table->items[i].name);
    for (child = table->items[i].children; *child; child++) {
      free(*child);
    }
  }

  free(table->items);
  free(table);
}

static Node *table_lookup(NodeTable *table, const char *name) {
  size_t i, j;

  i = hash(name) % table->nslots;

  for (j = 0; j < table->nslots; j++) {
    if (table->items[i].name == NULL) {
      return &table->items[i];
    } else if (!strcmp(table->items[i].name, name)) {
      return &table->items[i];
    }
    i = (i+1) % table->nslots;
  }

  return NULL;
}

static void table_resize(NodeTable *table) {
  size_t i, old_nslots;
  Node *old_items, *slot;

  if (table->nslots > table->nitems) return;

  old_nslots = table->nslots;
  old_items = table->items;

  table->nslots = (old_nslots + 1)*2 - 1;
  table->items = calloc(table->nslots, sizeof(Node));

  for (i = 0; i < old_nslots; i++) {
    if (old_items[i].name) {
      slot = table_lookup(table, old_items[i].name);
      memcpy(slot, &old_items[i], sizeof(Node));
    }
  }

  free(old_items);
}

static int parse_node(char *line, Node *node) {
  char *p;
  size_t i;

  // Parse name.
  p = strtok(line, SPLIT_BY_WHITESPACE_AND_SYMBOLS);
  if (!p) return 0;
  node->name = strdup(p);

  // Parse weight.
  p = strtok(NULL, SPLIT_BY_WHITESPACE_AND_SYMBOLS);
  if (!p) {
    free(node->name);
    return 0;
  }
  node->weight = atoi(p);

  // Set has_parent to false.
  node->has_parent = 0;

  // Parse list of children.
  p = strtok(NULL, SPLIT_BY_WHITESPACE_AND_SYMBOLS);
  i = 0;
  while (p && i < MAX_CHILDREN) {
    node->children[i++] = strdup(p);
    p = strtok(NULL, SPLIT_BY_WHITESPACE_AND_SYMBOLS);
  }
  node->children[i] = NULL;

  return 1;
}

static void add_node(NodeTable *table, Node *node) {
  Node *slot;
  char **child;

  // table[name] = node
  table->nitems++;
  table_resize(table);
  slot = table_lookup(table, node->name);
  if (slot->name) {
    table->nitems--;
    free(slot->name);
    node->has_parent = 1;
  }
  *slot = *node;

  // for each child: table[child_name].has_parent = 1
  for (child = node->children; *child; child++) {
    table->nitems++;
    table_resize(table);
    slot = table_lookup(table, *child);
    if (slot->name) {
      table->nitems--;
    } else {
      slot->name = strdup(*child);
    }
    slot->has_parent = 1;
  }
}

static int find_weights(NodeTable *table, Node *node, int *solution) {
  size_t i, num_children;
  int weights[MAX_CHILDREN];
  int total_weight, proper_weight, improper_weight;
  Node *child;

  total_weight = node->weight;
  for (i = 0; node->children[i]; i++) {
    weights[i] = find_weights(table, table_lookup(table, node->children[i]), solution);
    if (weights[i] == -1) return -1; // found solution, return immediately!
    total_weight += weights[i];
  }
  num_children = i;

  if (num_children > 2) {
    if (weights[0] == weights[1] || weights[0] == weights[2]) {
      proper_weight = weights[0];
    } else {
      proper_weight = weights[1];
    }

    for (i = 0; i < num_children; i++) {
      if (weights[i] != proper_weight) {
        child = table_lookup(table, node->children[i]);
        *solution = child->weight + proper_weight - weights[i];
        return -1;
      }
    }
  }

  return total_weight;
}

static const char *find_root(NodeTable *table) {
  size_t i, j;

  for (i = 0; i < table->nslots; i++) {
    if (table->items[i].name && !table->items[i].has_parent) {
      return table->items[i].name;
    }
  }

  return NULL;
}

int main() {
  FILE *fp;
  char *line, *line_dup;
  size_t linecap;
  ssize_t linelen;
  NodeTable *table;
  Node node;
  const char *root;
  int solution;

  table = table_new();

  fp = fopen("input/input07", "r");
  line = NULL;
  linecap = 0;
  while ((linelen = getline(&line, &linecap, fp)) != -1) {
    line_dup = strdup(line);
    if (parse_node(line_dup, &node)) {
      add_node(table, &node);
    }
    free(line_dup);
  }
  free(line);
  fclose(fp);

  root = find_root(table);
  find_weights(table, table_lookup(table, root), &solution);

  table_free(table);

  printf("Solutions:\n");
  printf("  Part 1: %s\n", root);
  printf("  Part 2: %d\n", solution);

  return 0;
}
