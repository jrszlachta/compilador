
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
int nParam;
char simboloEsquerda[4];
char elementoEsquerda[TAM_TOKEN];
char comando[64];
tSimboloTs *tAtual;
list TS;
list rotulos;
list totalVars;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token LABEL TIPO ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN WHILE DO NOT
%token IGUAL MAIOR MENOR MAIS MENOS ASTERISCO DIV
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE INTEGER
%token READ WRITE

%left OR
%left AND
%left ABRE_PARENTESES

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
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
				int *aux = (int *) malloc(sizeof(int));
				*aux = totalVar;
				list_push(aux, totalVars);
				char *r0 = geraRotulo();
				list_push(r0, rotulos);
				sprintf(comando, "DSVS %s", r0);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
			  }
			  parte_declara_subrotinas
              {
				char *r0 = (char *) list_value(list_pop(rotulos));
				geraCodigo(r0, "NADA");
				free(r0);
              }

              comando_composto
      			  {
						int *aux = (int *) list_value(list_pop(totalVars));
        				sprintf(comando, "DMEM %d", *aux);
        				geraCodigo (NULL, comando);
        				memset(comando, 0, 64);
						free(aux);
      			  }
              ;




parte_declara_vars:  var
;

parte_declara_subrotinas: parte_declara_subrotinas declara_procedimento
						| parte_declara_subrotinas declara_funcao
						| declara_procedimento
						| declara_funcao
;

declara_procedimento: PROCEDURE IDENT
	{
		nParam = 0;
		nivelLexico++;
		char *r0 = geraRotulo();
		list_push(r0, rotulos);
		sprintf(comando, "ENPR %d", nivelLexico);
		geraCodigo(r0, comando);
		memset(comando, 0, 64);
		tSimboloTs* t = criaSimboloTS(token, TS_CAT_CP, nivelLexico);
		tAtual = t;
	}
	parametros
	{
		char *r0 = (char *) list_value(list_pop(rotulos));
		atualizaSimboloTS_CP(tAtual, r0, nivelLexico, nParam, NULL);
		free(r0);
	}
	PONTO_E_VIRGULA
	bloco
	{
		sprintf(comando, "RTPR %d, %d", nivelLexico, 0);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		nivelLexico--;
	}
	PONTO_E_VIRGULA
;

declara_funcao:
;

parametros:
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
;

comandos: comandos PONTO_E_VIRGULA comando
          | comando
          |
;

comando: numero comando_sem_rotulo
;

numero: NUMERO DOIS_PONTOS |
;

comando_sem_rotulo: atr_ou_proc | comando_repetitivo | comando_condicional | leitura | escrita
;

leitura: READ ABRE_PARENTESES IDENT
	{
		geraCodigo(NULL, "LEIT");
		tSimboloTs *s = buscaTS(token);
		sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		memset(elementoEsquerda, 0, TAM_TOKEN);
	}
	FECHA_PARENTESES
;

escrita: WRITE ABRE_PARENTESES lista_write FECHA_PARENTESES
;

lista_write: lista_write VIRGULA e
	{
		geraCodigo(NULL, "IMPR");
	}
	| e
	{
		geraCodigo(NULL, "IMPR");
	}
;

atr_ou_proc: IDENT {sprintf(elementoEsquerda, "%s", token);} atr_ou_proc_cont
;

atr_ou_proc_cont: ATRIBUICAO expressao
		   | ABRE_PARENTESES alguma_coisa FECHA_PARENTESES
		   | {
				tSimboloTs *t = buscaTS(elementoEsquerda);
				memset(elementoEsquerda, 0, TAM_TOKEN);
				sprintf(comando, "CHPR %s, %d", t->categoriaTs.c->rotulo, nivelLexico);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
			 }
;

alguma_coisa:
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
;

avalia_expressao: avalia_expressao AND avalia_expressao {
		sprintf(comando, "CONJ");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
	| avalia_expressao OR avalia_expressao {
		sprintf(comando, "DISJ");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
	| ABRE_PARENTESES avalia_expressao FECHA_PARENTESES
	| e relacao e {
		geraCodigo(NULL, simboloEsquerda);
		memset(simboloEsquerda, 0, 4);
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

comando_repetitivo: WHILE
  {
    char *r0 = geraRotulo();
    list_push(r0, rotulos);
    geraCodigo(r0, "NADA");
  }
avalia_expressao
  {
    char *r1 = geraRotulo();
    list_push(r1, rotulos);
    sprintf(comando, "DSVF %s", r1);
    geraCodigo(NULL, comando);
    memset(comando, 0, 64);
  }
  comando_repetitivo_do
;
comando_repetitivo_do:
  DO comando_composto
  {
    char *r1 = (char *) list_value(list_pop(rotulos));
    char *r0 = (char *) list_value(list_pop(rotulos));
    sprintf(comando, "DSVS %s", r0);
    geraCodigo(NULL, comando);
    memset(comando, 0, 64);
    geraCodigo(r1, "NADA");
	free(r0);
	free(r1);
  }
  | DO comando {
    char *r1 = (char *) list_value(list_pop(rotulos));
    char *r0 = (char *) list_value(list_pop(rotulos));
    sprintf(comando, "DSVS %s", r0);
    geraCodigo(NULL, comando);
    memset(comando, 0, 64);
    geraCodigo(r1, "NADA");
	free(r0);
	free(r1);
  }
;

comando_condicional:
  if_then cond_else
	{
		char *r0 = (char *) list_value(list_pop(rotulos));
		geraCodigo(r0, "NADA");
		free(r0);
	}
;

if_then:
  IF avalia_expressao
  {
    //em_if_apos_expr ();
	char *r0 = geraRotulo();
	char *r1 = geraRotulo();
	list_push(r0, rotulos);
	list_push(r1, rotulos);
	sprintf(comando, "DSVF %s", r1);
	geraCodigo(NULL, comando);
	memset(comando, 0, 64);
  }
   THEN then_comando
  {
	char *r1 = (char *) list_value(list_pop(rotulos));
	char *r0 = (char *) list_value(list_pop(rotulos));
	list_push(r0, rotulos);
	sprintf(comando, "DSVS %s", r0);
	geraCodigo(NULL, comando);
	memset(comando, 0, 64);
	geraCodigo(r1, "NADA");
	free(r1);
  }
;

then_comando: comando_composto | comando
;

cond_else: ELSE else_comando
  | %prec LOWER_THAN_ELSE
;

else_comando: comando_composto | comando
;

%%

int yylex();

char* geraRotulo()
{
	char* rot;
	rot = (char *) malloc(sizeof(char)*10);
	sprintf(rot, "R%2.0d", maxRotulo++);
	for (int i=0;i<9;++i)
 	{
  		if (rot[i]==' ')
			rot[i] = '0';
 	}
	return rot;
}

int main (int argc, char** argv) {
	FILE* fp;
   	extern FILE* yyin;

	TS = criaTS();
	rotulos = list_new();
	totalVars = list_new();
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

 	printf("\n\nTABELA DE SÍMBOLOS\n");
 	for (node n=list_first(TS); n; n=list_next(n))
 	{
  		tSimboloTs* t = list_value(n);
  		imprimeSimboloTS(t);
 	}

	return 0;
}
