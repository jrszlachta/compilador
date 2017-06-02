
// Testar se funciona corretamente o empilhamento de parametros
// passados por valor ou por referencia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "list.h"

int num_vars, contVar, totalVar;
int maxRotulo;
int nivelLexico, deslocamento;
int relacaoDada;
char simboloEsquerda[4];
char elementoEsquerda[TAM_TOKEN];
char comando[64];
list TS;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token LABEL TIPO ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR AND NOT
%token IGUAL MAIOR MENOR MAIS MENOS ASTERISCO DIV
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE INTEGER


%%

programa    :{
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
              parte_declara_vars
              {
              }

              comando_composto
      			  {
        				sprintf(comando, "DMEM %d", totalVar);
        				geraCodigo (NULL, comando);
        				memset(comando, 0, 64);
      			  }
              ;




parte_declara_vars:  var
;


var         : VAR declara_vars
            |
;

declara_vars: declara_vars declara_var PONTO_E_VIRGULA
            | declara_var PONTO_E_VIRGULA
;

declara_var : { contVar = 0; }
              lista_id_var DOIS_PONTOS
              tipo
              {
                sprintf(comando, "AMEM %d", contVar);
                geraCodigo(NULL, comando);
                atualizaTS(contVar, token);
                contVar = 0;
                memset(comando, 0, 64);
              }
;

tipo        : INTEGER
;

lista_id_var: lista_id_var VIRGULA IDENT
              {
        				contVar++;
        				criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar);
        				totalVar++;
			        }
              | IDENT
			        {
        				contVar++;
        				criaSimboloTS_VS(token, TS_CAT_VS, nivelLexico, totalVar);
        				totalVar++;
			        }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
          | comandos comando
          | comando
;

comando: numero comando_sem_rotulo
;

numero: NUMERO DOIS_PONTOS |
;

comando_sem_rotulo: atribuicao
;

atribuicao: variavel ATRIBUICAO expressao PONTO_E_VIRGULA
;

variavel: IDENT
          {
            sprintf(elementoEsquerda, "%s", token);
          }
;

/*expressao: NUMERO
           {
             sprintf(comando, "CRCT %s", token);
             geraCodigo(NULL, comando);
             memset(comando, 0, 64);
             tSimboloTs* s = buscaTS(elementoEsquerda);
             sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
             geraCodigo(NULL, comando);
             memset(comando, 0, 64);
             memset(elementoEsquerda, 0, TAM_TOKEN);
           }
;*/

expressao: e {
		tSimboloTs *s = buscaTS(elementoEsquerda);
		sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		memset(elementoEsquerda, 0, TAM_TOKEN);
	}
	| e relacao e {
		geraCodigo(NULL, simboloEsquerda);
		memset(simboloEsquerda, 0, 64);
	}
;

relacao: IGUAL {sprintf(simboloEsquerda, "CMIG");}
	   | MAIOR {sprintf(simboloEsquerda, "CMMA");}
	   | MENOR {sprintf(simboloEsquerda, "CMME");}
	   | MAIOR_IGUAL {sprintf(simboloEsquerda, "CMAG");}
	   | MENOR_IGUAL {sprintf(simboloEsquerda, "CMEG");}
	   | DIFERENTE {sprintf(simboloEsquerda, "CMDG");}

;

e: e MAIS f {
		sprintf(comando, "SOMA");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
    }
 | e MENOS f {
		sprintf(comando, "SUBT");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | f
;

f: f ASTERISCO t {
		sprintf(comando, "MULT");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | f DIV t {
		sprintf(comando, "DIVI");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | t
;

t: IDENT {
		tSimboloTs *s = buscaTS(token);
		sprintf(comando, "CRVL %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
 	}
 | NUMERO {
		sprintf(comando, "CRCT %s", token);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | ABRE_PARENTESES e FECHA_PARENTESES
;

%%

char* geraRotulo()
{
	char* rot;
	rot = (char *) malloc(sizeof(char)*10);
	sprintf(rot, "R%5.0d", maxRotulo++);
	for (int i=0;i<9;++i)
 	{
  		if (rot[i]==' ')
			rot[i] = '0';
 	}
	return rot;
}

int yylex();

int main (int argc, char** argv) {
	FILE* fp;
   	extern FILE* yyin;

	TS = criaTS();
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
 	*  Inicia a Tabela de Simbolos
 	* ------------------------------------------------------------------- */

 	yyin=fp;
 	yyparse();

 	printf("\n\nTABELA DE S�MBOLOS\n");
 	for (node n=list_first(TS); n; n=list_next(n))
 	{
  		tSimboloTs* t = list_value(n);
  		imprimeSimboloTS(t);
 	}

	return 0;
}
