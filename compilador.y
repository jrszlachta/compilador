
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int num_vars, contVar, totalVar;
int maxRotulo;
int nivelLexico, deslocamento;
char* elementoEsquerda;
list TS;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token WHILE DO IF THEN ELSE
%token IGUAL MENOR MENOR_IGUAL MAIOR MAIOR_IGUAL DIF

%%

programa:{
          geraCodigo (NULL, "INPP", NULL, NULL, NULL);
          nivelLexico = 0;
         }
         PROGRAM IDENT
         ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
         bloco PONTO
         {
          geraCodigo (NULL, "PARA", NULL, NULL, NULL);
         }
;

bloco       : {totalVar = 0}
              parte_declara_vars
              {

              }

              comando_composto
              {
                geraCodigo (NULL, "DMEM", &totalVar, NULL, NULL)
              }
;




parte_declara_vars:  var
                  |  parte_declara_vars var
;


var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : {contVar = 0}
              lista_id_var DOIS_PONTOS
              IDENT
              {
                geraCodigo (NULL, "AMEM", &contVar, NULL, NULL);
                atualizaTS(contVar, token);
              }
              PONTO_E_VIRGULA
;


lista_id_var: lista_id_var VIRGULA IDENT
              { contVar++; totalVar++; criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar)}
            | IDENT { contVar++ ; totalVar++; criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar)}
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END | comando
;

comandos: comando | comandos comando
;

comando: comando_sem_rotulo
;

comando_sem_rotulo:  expressao
                  |  regra_condicional
                  |  regra_while
;

regra_condicional: IF expressao THEN comando_composto
;

regra_while: WHILE
    { //gera
    }
    expressao DO comando_composto
;

expressao: variavel {strcpy(elementoEsquerda, token); printf("ESQ: %s\n", elementoEsquerda)} simbolos 
;

variavel: IDENT {
                 tSimboloTs* t = buscaTS(token);
                 if (t && t->categoria==TS_CAT_VS)
                  geraCodigo(NULL, "CRVL", &t->nivel, &t->categoriaTs.v->deslocamento, NULL);
                }
        | NUMERO {int val = atoi(token); geraCodigo(NULL, "CRCT", &val, NULL, NULL)}
;

simbolos: ATRIBUICAO simbolos PONTO_E_VIRGULA {
                                               printf("ESQ: %s\n", elementoEsquerda);
                                               tSimboloTs* t = buscaTS(elementoEsquerda);
                                               if (t && t->categoria==TS_CAT_VS)
                                                geraCodigo(NULL, "ARMZ", &t->nivel, &t->categoriaTs.v->deslocamento, NULL);
                                              }
        | compara simbolos
;

compara: IGUAL | MENOR | MENOR_IGUAL | MAIOR | MAIOR_IGUAL | DIF
;
%%

//Gera rótulo
char* geraRotulo()
{
 char* rot;
 rot = (char*)malloc(sizeof(char)*10);
 sprintf(rot, "R%5.0d", maxRotulo++);
 for (int i=0;i<9;++i)
 {
  if (rot[i]==' ')
   rot[i] = '0';
 }
 return rot;
}

/// Programa principal

int yylex ();
int main (int argc, char** argv)
{
 FILE* fp;
 extern FILE* yyin;

 TS = criaTS();
 elementoEsquerda = (char*)malloc(sizeof(char)*TAM_TOKEN);
 /*tSimboloTs* s = criaSimboloTS("var", TS_CAT_VS, 0);
 atualizaSimboloTS_VS(s, 0, TS_TIP_INT);

 tSimboloTs* s1 = criaSimboloTS("par", TS_CAT_PF, 0);
 atualizaSimboloTS_PF(s1, -4, TS_PAR_VAL);

 tSimboloTs* s2 = criaSimboloTS("proc", TS_CAT_CP, 0);
 int* tp = (int*)malloc(sizeof(int)*3);
 tp[0] = 0;
 tp[1] = 1;
 tp[2] = 0;
 atualizaSimboloTS_CP(s2, "r01", 0, 3, tp);
 */
 for (node n=list_first(TS); n; n=list_next(n))
 {
  tSimboloTs* t = list_value(n);
  imprimeSimboloTS(t);
 }

 if (argc<2 || argc>2)
 {
  printf("usage compilador <arq>a %d\n", argc);
  return(-1);
 }

 fp=fopen (argv[1], "r");
 if (fp == NULL)
 {
  printf("usage compilador <arq>b\n");
  return(-1);
 }

 /* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */

 yyin=fp;
 yyparse();

 printf("\n\nTABELA DE SÍMBOLOS\n");
 for (node n=list_first(TS); n; n=list_next(n))
 {
  tSimboloTs* t = list_value(n);
  imprimeSimboloTS(t);
 }

 return 0;
}
