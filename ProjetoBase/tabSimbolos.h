#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "lista.h"

//#define VARSIMPLES 1
//#define [TIPO] 2
//#define ...

typedef tSimbolo *tSimbolo;

struct tSimbolo{
  char * name;    // Nome do símbolo (token)
  int type;       // Tipo do símbolo
  int nl;         // Nível léxico
  int desloc      // Deslocamento em relação ao nível léxico
  int varType     // Tipo da var simples
};

tSimbolo buscaTS(char * token, lista l);
tSimbolo newSimbolo(char * token);
void insereTabSimbVS(tSimbolo s, int nivelLex, int desl, int vType, lista l);
void destroySimbolo(tSimbolo s);
// void insereTabSimb[TIPO](...);
