
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Funções auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"


/* -------------------------------------------------------------------
 *  variáveis globais
 * ------------------------------------------------------------------- */

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando, int* arg1, int* arg2) 
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
  fprintf(fp, "\n");
}

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}


void atualizaTS(int num, char token[TAM_TOKEN])
{
  printf("HERE COMES THE TOKEN TUDUDUDUDU %s\n", token); return;
}

char *intToStr(int n)
{
    char *ret;
    int i, j=0;
    
    ret=(char *)malloc(sizeof(char)*10);
    for (i=0;i<10;i++) ret[i]=' ';
    ret[i]='0';
    while (n>0) {ret[i]=0x30+(n%10); n=n/10; i--;}
    while (i<10) {i++; ret[j]=ret[i]; j++;}
    ret[j]='\0';
    return ret;
}
