
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


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
char comando[64];
list TS;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token LABEL TIPO ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR AND NOT
%token MAIS MENOS ASTERISCO DIV IGUAL MAIOR MENOR
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE

%%

programa:{
          geraCodigo (NULL, "INPP");
          nivelLexico = 0;
         }
         PROGRAM IDENT
         ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
         bloco PONTO
         {
          geraCodigo (NULL, "PARA");
         }
;

bloco       : {totalVar = 0;}
              parte_declara_rotulos parte_vars parte_declara_procedimentos
              {

              }

              comando_composto
              {
				sprintf(comando, "DMEM %d", totalVar);
                geraCodigo (NULL, "DMEM");
				memset(comando, 0, 64);
              }
;


parte_vars: parte_declara_vars |
;

parte_declara_vars: parte_declara_vars PONTO_E_VIRGULA declara_vars PONTO_E_VIRGULA | VAR declara_vars
;


declara_vars : {contVar = 0;}
              lista_id_var DOIS_PONTOS
              tipo
              {
				sprintf(comando, "AMEM %d", contVar);
                geraCodigo (NULL, comando);
                atualizaTS(contVar, token);
				contVar = 0;
				memset(comando, 0, 64);
              }
;

tipo: IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { contVar++;
				criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar);
				totalVar++;
			  }
            | IDENT
			  { contVar++;
			 	criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar);
				totalVar++;
			  }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

parte_declara_rotulos: label num |
;

parte_declara_procedimentos: procedure | function |
;

comando_composto: T_BEGIN comandos T_END
				| comando
;

comandos: comandos comando
		| comando
;

comando: rotulo comando_sem_rotulo
;

rotulo: NUMERO |
;

comando_sem_rotulo:  atribuicao
                  |  chamada_procedimento
                  |  desvio
				  |	 comando_composto
				  |  comando_condicional
				  |  comando_repetitivo
;

atribuicao: variavel DOIS_PONTOS IGUAL expressao
		  {geraCodigo(NULL, "ARMZ");}
;

expressao:  expressao MAIS texpressao {geraCodigo(NULL, "SOMA");}
		  | expressao MENOS texpressao {geraCodigo(NULL, "SUBT");}
		  | expressao OR texpressao {geraCodigo(NULL, "DISJ");}
		  | texpressao
;

texpressao: texpressao ASTERISCO fexpressao {geraCodigo(NULL, "MULT");}
		  | texpressao DIV fexpressao {geraCodigo(NULL, "DIVI");}
		  | texpressao AND fexpressao {geraCodigo(NULL, "CONJ");}
		  | fexpressao
;

fexpressao: IDENT {geraCodigo(NULL, "CRVL");}
		  | ABRE_PARENTESES expressao FECHA_PARENTESES
		  | NUMERO {geraCodigo(NULL, "CRCT");}
;

chamada_procedimento:
;

desvio:
;

comando_condicional: IF expressao THEN comando_composto
;

comando_repetitivo: WHILE
    { //gera
    }
    expressao DO comando_composto
;

variavel:
;

expressao:
;

procedure:
;

function:
;

label:
;

num:
;

expressao: variavel {strcpy(elementoEsquerda, token); printf("ESQ: %s\n", elementoEsquerda)} simbolos
;

variavel: IDENT {
                 tSimboloTs* t = buscaTS(token);
                 if (t && t->categoria==TS_CAT_VS) {
					sprintf(comando, "CRVL %d %d", t->nivel, t->categoriaTs.v->deslocamento);
                    geraCodigo(NULL, comando);
					memset(comando, 0, 64);
				 }
                }
        | NUMERO
			{int val = atoi(token);
			 sprintf(comando, "CRCT %d", val);
			 geraCodigo(NULL, "CRCT");
			 memset(comando, 0, 64);
			}
;

simbolos: ATRIBUICAO simbolos PONTO_E_VIRGULA
		{
          printf("ESQ: %s\n", elementoEsquerda);
          tSimboloTs* t = buscaTS(elementoEsquerda);
          if (t && t->categoria==TS_CAT_VS) {
			sprintf(comando, "ARMZ %d %d", t->nivel, t->categoriaTs.v->deslocamento);
          	geraCodigo(NULL, comando);
		 }
        }
        | compara simbolos
;

compara: IGUAL | MENOR | MENOR_IGUAL | MAIOR | MAIOR_IGUAL | DIFERENTE
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
