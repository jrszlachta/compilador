
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int num_vars;
char comando[64];
// l_elem

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token LABEL TIPO ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR AND NOT
%token MAIS MENOS ASTERISCO DIV IGUAL MAIOR MENOR
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE

%%

programa    :{
             geraCodigo (NULL, "INPP");
			 nivel_lexico = 0;
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
			 //finaliza
             geraCodigo (NULL, "PARA");
             }
;

bloco       : parte_declara
              {
              }
              comando_composto
              ;

/* pode não ser a melhor saída */
parte_declara: parte_declara_rotulos parte_declara_vars parte_declara_procedimentos |
			   parte_declara_rotulos parte_declara_vars |
			   parte_declara_rotulos parte_declara_procedimentos |
               parte_declara_vars parte_declara_procedimentos |
			   parte_declara_rotulos |
			   parte_declara_vars |
               parte_declara_procedimentos |
;

parte_declara_vars:  var declara_vars
;

parte_declara_rotulos:
;

parte_declara_procedimentos:
;

var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              { /* AMEM */
				sprintf(comando, "AMEM %d", num_vars);
				geraCodigo(NULL, comando);
				// atualiza TS(num_vars)
			    num_vars = 0;
				memset(comando, 0, 64);
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere última vars na tabela de símbolos */
				// insere TS
				num_vars++;
			  }
            | IDENT { /* insere vars na tabela de símbolos */
				// insere TS
				num_vars++;
			  }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos: comandos comando
	   	| comando
;

comando: rotulo comando_sem_rotulo
;

rotulo: NUMERO |
;

comando_sem_rotulo: atribuicao
				  | chamada_procedimento
				  | desvio
				  | comando_composto
				  | comando_condicional
				  | comando_repetitivo
;

atribuicao: variavel DOIS_PONTOS IGUAL expressao
		  {geraCodigo(NULL, "ARMZ");}
;

expressao: expressao MAIS texpressao {geraCodigo(NULL, "SOMA");}
		 | expressao MENOS texpressao {geraCodigo(NULL, "SUBT");}
		 | expressao OR texpressao {geraCodigo(NULL, "DISJ");}
		 | texpressao
;

texpressao: texpressao ASTERISCO fexpressao {geraCodigo(NULL, "MULT")}
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

comando_condicional:
;

comando_repetitivo:
;

variavel:
;

expressao:
;

%%

main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}

