#include "tamSimbolos.h"

// Função para buscar um simbolo na TS usando um token
tSimbolo buscaTS(char * token, lista l){
  no n = primeiro_no(l);
  tSimbolo t;
  while(n){
    t = (tSimbolo) conteudo(n);
    if(strcmp(t->name,token) == 0)
      return t;
    n = proximo_no(n);
  }
  return NULL;
}

// Cria um novo símbolo para posteriormente inserir na TS
tSimbolo newSimbolo(char * token){
  tSimbolo t = malloc(sizeof(struct tSimbolo));
  if(!t)
    return NULL;
  t->name = malloc(sizeof(token));
  if(t->name){
    free(t);
    return NULL;
  }
  strcpy(t->name,token);
  return t;
}

void insereTabSimbVS(tSimbolo s, int nivelLex, int desl, int vType, lista l){
  s->nl = nivelLex;
  s->deloc = dels;
  s->varType = vType;
  insere(s,l);
}
