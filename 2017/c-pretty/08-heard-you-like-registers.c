#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SPLIT_BY_WHITESPACE " \t\n"

/*** instruction data type ***/

typedef enum {
  OP_INC = 0,
  OP_DEC
} OpType;

#define NUM_OPS (OP_DEC+1)

static const char *op_types[NUM_OPS] = {
  "inc", "dec"
};

typedef enum {
  OPCOND_LT = 0,
  OPCOND_GT,
  OPCOND_LE,
  OPCOND_GE,
  OPCOND_EQ,
  OPCOND_NE
} OpCondType;

#define NUM_OPCONDS (OPCOND_NE+1)

static const char *opcond_types[NUM_OPCONDS] = {
  "<", ">", "<=", ">=", "==", "!="
};

typedef struct {
  size_t reg;
  OpType op;
  int arg;
  size_t cond_reg;
  OpCondType cond_op;
  int cond_arg;
} Instruction;

/*** hash table for mapping register names to integer indexes ***/

typedef struct {
  char *name;
  size_t idx;
} Reg;

typedef struct {
  Reg *items;
  size_t nitems, nslots;
} RegTable;

// http://www.cse.yorku.ca/~oz/hash.html
static size_t hash(const char *name) {
  size_t hash = 5381;
  int c;

  while ((c = *name++)) {
    hash = ((hash << 5) + hash) + c;
  }

  return hash;
}

static RegTable *table_new() {
  RegTable *table = malloc(sizeof(RegTable));

  table->nitems = 0;
  table->nslots = 255;
  table->items = calloc(table->nslots, sizeof(Reg));

  return table;
}

static void table_free(RegTable *table) {
  size_t i;

  for (i = 0; i < table->nslots; i++) {
    free(table->items[i].name);
  }

  free(table->items);
  free(table);
}

static Reg *table_lookup(RegTable *table, const char *name) {
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

static void table_resize(RegTable *table) {
  size_t i, old_nslots;
  Reg *old_items, *slot;

  if (table->nslots > table->nitems) return;

  old_nslots = table->nslots;
  old_items = table->items;

  table->nslots = (old_nslots + 1)*2 - 1;
  table->items = calloc(table->nslots, sizeof(Reg));

  for (i = 0; i < old_nslots; i++) {
    if (old_items[i].name) {
      slot = table_lookup(table, old_items[i].name);
      memcpy(slot, &old_items[i], sizeof(Reg));
    }
  }

  free(old_items);
}

/*** parser ***/

static size_t reg_index(RegTable *table, const char *reg_name) {
  Reg *slot;

  table->nitems++;
  table_resize(table);
  slot = table_lookup(table, reg_name);
  if (slot->name) {
    table->nitems--;
  } else {
    slot->name = strdup(reg_name);
    slot->idx = table->nitems - 1;
  }
  return slot->idx;
}

static int parse_instruction(char *line, RegTable *table, Instruction *inst) {
  char *p;
  size_t i, j;

  // Register name
  p = strtok(line, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  inst->reg = reg_index(table, p);

  // Operation (inc or dec)
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  for (j = 0; j < NUM_OPS; j++) {
    if (!strcmp(p, op_types[j])) {
      inst->op = j;
      break;
    }
  }
  if (j == NUM_OPS) return 0;

  // Argument
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  inst->arg = atoi(p);

  // 'if'
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  if (strcmp(p, "if")) return 0;

  // Condition's register name
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  inst->cond_reg = reg_index(table, p);

  // Condition's comparison operator
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  for (j = 0; j < NUM_OPCONDS; j++) {
    if (!strcmp(p, opcond_types[j])) {
      inst->cond_op = j;
      break;
    }
  }
  if (j == NUM_OPCONDS) return 0;

  // Condition's argument
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (!p) return 0;
  inst->cond_arg = atoi(p);

  // End of instruction
  p = strtok(NULL, SPLIT_BY_WHITESPACE);
  if (p) return 0;

  return 1;
}

static int blank_string(const char *p) {
  while (isspace(*p)) p++;
  return *p == '\0';
}

static Instruction *parse_program(const char *filename, size_t *len_out, size_t *num_registers_out) {
  FILE *fp;
  char *line;
  size_t linecap;
  ssize_t linelen;
  RegTable *table;
  Instruction *program;
  size_t program_len, program_size;

  program_len = 0;
  program_size = 64;
  program = malloc(program_size * sizeof(Instruction));

  table = table_new();

  fp = fopen(filename, "r");
  line = NULL;
  linecap = 0;
  while ((linelen = getline(&line, &linecap, fp)) != -1) {
    if (blank_string(line)) continue;

    if (parse_instruction(line, table, &program[program_len])) {
      program_len++;
      if (program_len >= program_size) {
        program_size *= 2;
        program = realloc(program, program_size * sizeof(Instruction));
      }
    } else {
      free(program);
      program = NULL;
      break;
    }
  }
  free(line);
  fclose(fp);

  *num_registers_out = table->nitems;
  *len_out = program_len;

  table_free(table);

  return program;
}

static void disassemble_program(Instruction *code, size_t len) {
  size_t i;

  for (i = 0; i < len; i++) {
    printf(
      "$%zu %s %d if $%zu %s %d\n",
      code[i].reg,
      op_types[code[i].op],
      code[i].arg,
      code[i].cond_reg,
      opcond_types[code[i].cond_op],
      code[i].cond_arg
    );
  }
}

/*** virtual machine ***/

static void execute_program(
  Instruction *code, size_t len, size_t num_registers,
  int *max_out, int *max_ever_out
) {
  size_t pc, i;
  Instruction *inst;
  int *mem;
  int cond;
  int max, max_ever;

  mem = calloc(num_registers, sizeof(int));

  max_ever = 0;
  pc = 0;
  inst = code;
  while (pc < len) {
    switch (inst->cond_op) {
      case OPCOND_LT: cond = mem[inst->cond_reg]  < inst->cond_arg; break;
      case OPCOND_GT: cond = mem[inst->cond_reg]  > inst->cond_arg; break;
      case OPCOND_LE: cond = mem[inst->cond_reg] <= inst->cond_arg; break;
      case OPCOND_GE: cond = mem[inst->cond_reg] >= inst->cond_arg; break;
      case OPCOND_EQ: cond = mem[inst->cond_reg] == inst->cond_arg; break;
      case OPCOND_NE: cond = mem[inst->cond_reg] != inst->cond_arg; break;
    }

    if (cond) {
      switch (inst->op) {
        case OP_INC: mem[inst->reg] += inst->arg; break;
        case OP_DEC: mem[inst->reg] -= inst->arg; break;
      }

      if (mem[inst->reg] > max_ever) {
        max_ever = mem[inst->reg];
      }
    }

    inst++; pc++;
  }

  max = INT_MIN;
  for (i = 0; i < num_registers; i++) {
    if (mem[i] > max) {
      max = mem[i];
    }
  }

  free(mem);

  *max_out = max;
  *max_ever_out = max_ever;
}

int main() {
  Instruction *code;
  size_t code_len, num_registers;
  int max, max_ever;

  code = parse_program("input/input08", &code_len, &num_registers);

  if (code == NULL) {
    fprintf(stderr, "Parse error on line %zu\n", code_len + 1);
    exit(1);
  }

  execute_program(code, code_len, num_registers, &max, &max_ever);

  free(code);

  printf("Solutions:\n");
  printf("  Part 1: %d\n", max);
  printf("  Part 2: %d\n", max_ever);

  return 0;
}
