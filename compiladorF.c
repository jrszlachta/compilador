
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Fun��es auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

extern list TS;

/* -------------------------------------------------------------------
 *  vari�veis globais
 * ------------------------------------------------------------------- */

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando, int* arg1, int* arg2, int* arg3)
{
  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }
  if (rot == NULL) {
    fprintf(fp, "     %s", comando); fflush(fp);
  } else {
    fprintf(fp, "%s: %s", rot, comando); fflush(fp);
  }
  if (arg1 != NULL)
  {
    fprintf(fp, " %d", *arg1);
  }
  if (arg2 != NULL)
  {
    fprintf(fp, ", %d", *arg2);
  }
  if (arg3 != NULL)
  {
    fprintf(fp, ", %d", *arg3);
  }
  fprintf(fp, "\n");
}

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}

tSimboloTs* criaSimboloTS(char* rot, int categoria, int nivel)
{
 printf("\nTentando criar símbolo com o nome %s e categoria %s\n", rot, catTS(categoria));
 tSimboloTs* t = (tSimboloTs*)malloc(sizeof(tSimboloTs));
 if (t)
 {
  t->ident = rot;
  t->categoria = categoria;
  t->nivel = nivel;

  if (!insereTS(t))
   printf("Catástrofe detectada:\nNão foi possível inserir o símbolo na TS\n");
 }
 return t;
}

tSimboloTs* criaSimboloTS_VS(char *rot, int categoria, int nivel, int deslocamento)
{
  printf("\nTentando criar símbolo com o nome %s e categoria %s\n", rot, catTS(categoria));
  tSimboloTs* t = (tSimboloTs*)malloc(sizeof(tSimboloTs));
  t->categoriaTs.v = (tVsTs*)malloc(sizeof(tVsTs));
  if (t)
  {
   t->ident = (char*)malloc(sizeof(char)*TAM_TOKEN);
   strcpy(t->ident, rot);
   t->categoria = categoria;
   t->nivel = nivel;
   t->categoriaTs.v->deslocamento = deslocamento;

   if (!insereTS(t))
    printf("Catástrofe detectada:\nNão foi possível inserir o símbolo na TS\n");
  }
  return t;
}

void atualizaSimboloTS_VS(tSimboloTs* s, int tipo)
{
 if (s->categoria==TS_CAT_VS)
 {
  s->categoriaTs.v->tipo = tipo;
 }
 else printf("Catástrofe detectada:\nTentando atualizar simbolo TS do tipo VS porém a categoria é %d\n\n", s->categoria);
}

void atualizaSimboloTS_PF(tSimboloTs* s, int deslocamento, int tipoPassagem)
{
 if (s->categoria==TS_CAT_PF)
 {
  s->categoriaTs.p = (tPfTs*)malloc(sizeof(tPfTs));
  s->categoriaTs.p->deslocamento = deslocamento;
  s->categoriaTs.p->tipoPassagem = tipoPassagem;
 }
 else printf("Catástrofe detectada:\nTentando atualizar simbolo TS do tipo PF porém a categoria é %d\n\n", s->categoria);
}

void atualizaSimboloTS_CP(tSimboloTs* s, char* rotulo, int nivel, int nParams, int* tipoPassagem)
{
 if (s->categoria==TS_CAT_CP)
 {
  s->categoriaTs.c = (tCpTs*)malloc(sizeof(tCpTs));
  s->categoriaTs.c->rotulo = rotulo;
  s->categoriaTs.c->nivel = nivel;
  s->categoriaTs.c->nParams = nParams;
  s->categoriaTs.c->tipoPassagem = tipoPassagem;
 }
 else printf("Catástrofe detectada:\nTentando atualizar simbolo TS do tipo CP porém a categoria é %d\n\n", s->categoria);
}

int insereTS(tSimboloTs* s)
{
 if (s)
 {
  if (list_push(s, TS)!=NULL)
   return 1;
 }
 return 0;
}

tSimboloTs* buscaTS(char* rot)
{
 tSimboloTs* s;
 for (node n=list_first(TS);n;n=list_next(n))
 {
  s = list_value(n);
  if (strcmp(s->ident, rot)==0)
   return s;
 }
 return NULL;
}

void atualizaTS(int num, char token[TAM_TOKEN])
{
  int i = 0;
  for (node n=list_first(TS); n && i<num; n=list_next(n))
  {
   tSimboloTs* t = list_value(n);
   if (t->categoria==TS_CAT_VS)
   {
    printf("\n%s\n", token);
    if (strcmp(token, "integer")==0)
     atualizaSimboloTS_VS(t, TS_TIP_INT);
    else if (strcmp(token, "boolean")==0)
     atualizaSimboloTS_VS(t, TS_TIP_BOO);
    i++;
   }
  }
}

int removeTS(int n)
{
 while(n>0)
 {
  list_pop(TS);
  n--;
 }
 return 0;
}

list criaTS()
{
 list l = list_new();
 return l;
}

void imprimeSimboloTS(tSimboloTs* t)
{
 switch(t->categoria)
 {
  case TS_CAT_VS:
   printf("\nSimbolo TS:\nRot\tCat\tNiv\tDesl\tTipo\n%s\t%s\t%d\t%d\t%s\n\n", t->ident, catTS(t->categoria), t->nivel, t->categoriaTs.v->deslocamento, tipoTS(t->categoriaTs.v->tipo));
  break;

  case TS_CAT_PF:
   printf("\nSimbolo TS:\nRot\tCat\tNiv\tDesl\tTipo\n%s\t%s\t%d\t%d\t%s\n\n", t->ident, catTS(t->categoria), t->nivel, t->categoriaTs.p->deslocamento, tipoPassagemTS(t->categoriaTs.p->tipoPassagem));
  break;

  case TS_CAT_CP:
   printf("\nSimbolo TS:\nRot\tCat\tNiv\tRot\tNiv\tnParams\n%s\t%s\t%d\t%s\t%d\t%d\n", t->ident, catTS(t->categoria), t->nivel, t->categoriaTs.c->rotulo, t->categoriaTs.c->nivel, t->categoriaTs.c->nParams);
   if (t->categoriaTs.c->tipoPassagem!=NULL)
   {
    printf("Tipos Passagem: [%d", t->categoriaTs.c->tipoPassagem[0]);
    for (int i=1;i<t->categoriaTs.c->nParams;++i)
     printf(", %d", t->categoriaTs.c->tipoPassagem[i]);
    printf("]\n\n");
   }
  break;
 }
}

char *catTS(int categoria)
{
 switch(categoria)
 {
  case TS_CAT_VS:
   return "VS";
  break;

  case TS_CAT_CP:
   return "CP";
  break;

  case TS_CAT_PF:
   return "PF";
  break;

  default:
   return "?";
  break;
 }
}

char *tipoTS(int tipo)
{
 switch(tipo)
 {
  case TS_TIP_INT:
   return "INT";
  break;

  case TS_TIP_BOO:
   return "BOOLEAN";
  break;

  default:
   return "?";
  break;
 }
}

char *tipoPassagemTS(int tipo)
{
 switch(tipo)
 {
  case TS_TIP_INT:
   return "VAL";
  break;

  case TS_TIP_BOO:
   return "REF";
  break;

  default:
   return "?";
  break;
 }
}
