
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
int nParam, nParam_local, nParam_chamada;
int tipo_param;
int ch_proc;
char simboloEsquerda[4];
char elementoEsquerda[TAM_TOKEN];
char comando[64];
tSimboloTs *tAtual;
list TS;
list rotulos;
list totalVars;
list nParams, lista_param;
list fupr;
list tipoExp;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token LABEL TIPO ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN WHILE DO NOT
%token IGUAL MAIOR MENOR MAIS MENOS ASTERISCO DIV
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE INTEGER
%token READ WRITE IMAGINARIO NUMERO_I

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

bloco       : parte_declara_rotulos
			  {totalVar = 0;}
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
						if (*aux > 0) {
        					sprintf(comando, "DMEM %d", *aux);
        					geraCodigo (NULL, comando);
        					memset(comando, 0, 64);
						}
						free(aux);
      			  }
              ;


parte_declara_rotulos: parte_declara_rotulos declara_rotulo
					 | declara_rotulo
					 |
;

declara_rotulo: LABEL list_id_rotulo PONTO_E_VIRGULA;

list_id_rotulo: list_id_rotulo VIRGULA NUMERO
			  {
				char *r0 = geraRotulo();
				tSimboloTs *t = criaSimboloTS(token, TS_CAT_LB, nivelLexico);
				atualizaSimboloTS_LB(t, r0);
			  }
			  | NUMERO
			  {
				char *r0 = geraRotulo();
				tSimboloTs *t = criaSimboloTS(token, TS_CAT_LB, nivelLexico);
				atualizaSimboloTS_LB(t, r0);
			  }
;

parte_declara_vars:  var
;

parte_declara_subrotinas: parte_declara_subrotinas declara_procedimento
						| parte_declara_subrotinas declara_funcao
						| declara_procedimento
						| declara_funcao
						|
;

declara_procedimento: PROCEDURE IDENT
	{
		nParam = 0;
		nivelLexico++;
		lista_param = list_new();
		char *r0 = geraRotulo();
		list_push(r0, rotulos);
		sprintf(comando, "ENPR %d", nivelLexico);
		geraCodigo(r0, comando);
		memset(comando, 0, 64);
		tSimboloTs* t = criaSimboloTS(token, TS_CAT_CP, nivelLexico);
		list_push(t, fupr);
	}
	parametros
	{
		char *r0 = (char *) list_value(list_pop(rotulos));
		int *tipo;
		list tipoParams = NULL;
		if (nParam) {
			tipoParams = list_new();
			for (node n = list_first(lista_param); n; n = list_next(n)) {
				tipo = (int *) malloc(sizeof(int));
				tSimboloTs *t = list_value(n);
				*tipo = t->categoriaTs.p->tipoPassagem;
				list_push(tipo, tipoParams);
			}
		}
		tSimboloTs *t = list_value(list_first(fupr));
		atualizaSimboloTS_CP(t, r0, nivelLexico, nParam, tipoParams);
		free(r0);
		int *aux = (int *) malloc(sizeof(int));
		*aux = nParam;
		list_push(aux, nParams);
	}
	PONTO_E_VIRGULA
	bloco
	{
		int *aux = (int *) list_value(list_pop(nParams));
		sprintf(comando, "RTPR %d, %d", nivelLexico, *aux);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		nivelLexico--;
	}
	PONTO_E_VIRGULA
	{
		list_free(lista_param, NULL);
		tSimboloTs *t = list_value(list_pop(fupr));
		node n;
		n = list_first(TS);
		tSimboloTs *s = list_value(n);
		for(n = list_first(TS); n && t != s; n = list_next(n)) {
			list_pop(TS);
			s = list_value(list_next(n));
		}
	}
;

declara_funcao: FUNCTION IDENT
    {
        nParam = 0;
        nivelLexico++;
        lista_param = list_new();
        char *r0 = geraRotulo();
        list_push(r0, rotulos);
        sprintf(comando, "ENPR %d", nivelLexico);
        geraCodigo(r0, comando);
        memset(comando, 0, 64);
        tSimboloTs* t = criaSimboloTS(token, TS_CAT_CF, nivelLexico);
        list_push(t, fupr);
    }
    parametros
    DOIS_PONTOS tipo
    {
        int tipoFunc;
        if (strcmp(token, "integer")==0)
            tipoFunc = TS_TIP_INT;
		else if(strcmp(token, "imaginario")== 0)
			tipoFunc = TS_TIP_IMG;
        char *r0 = (char *) list_value(list_pop(rotulos));
        int *tipo;
        list tipoParams = list_new();
        for (node n = list_first(lista_param); n; n = list_next(n)) {
            tipo = (int *) malloc(sizeof(int));
            tSimboloTs *t = list_value(n);
            *tipo = t->categoriaTs.p->tipoPassagem;
            list_push(tipo, tipoParams);
        }
        tSimboloTs *t = list_value(list_first(fupr));
        atualizaSimboloTS_CF(t, r0, nivelLexico, nParam, tipoParams, tipoFunc, -4-nParam);
        free(r0);
        int *aux = (int *) malloc(sizeof(int));
        *aux = nParam;
        list_push(aux, nParams);
    }
	PONTO_E_VIRGULA
	bloco
    {
        int *aux = (int *) list_value(list_pop(nParams));
        sprintf(comando, "RTPR %d, %d", nivelLexico, *aux);
        geraCodigo(NULL, comando);
        memset(comando, 0, 64);
        nivelLexico--;
    }
    PONTO_E_VIRGULA
    {
        list_free(lista_param, NULL);
        tSimboloTs *t = list_value(list_pop(fupr));
        node n;
        n = list_first(TS);
        tSimboloTs *s = list_value(n);
        for(n = list_first(TS); n && t != s; n = list_next(n)) {
            list_pop(TS);
            s = list_value(list_next(n));
        }
    }
;

parametros: ABRE_PARENTESES secao_parametros FECHA_PARENTESES
		  {
			int i = 0;
			for (node n = list_first(lista_param); n; n = list_next(n)) {
				tSimboloTs *t = list_value(n);
				t->categoriaTs.p->deslocamento = -4-i;
				insereTS(t);
				i++;
			}
		  }
		|
;

secao_parametros: secao_parametros PONTO_E_VIRGULA {nParam_local = 0;} lista_param
				| {nParam_local = 0;} lista_param
;

lista_param: tem_var lista_id_param DOIS_PONTOS tipo
		   {
				int tipo;
				if (strcmp(token, "integer") == 0)
					tipo = TS_TIP_INT;
				else if(strcmp(token, "imaginario")== 0)
					tipo = TS_TIP_IMG;
				atualizaSimboloTS_PF(lista_param, tipo, nParam_local);
				tipo_param = 0;
		   }
;

tem_var: VAR {tipo_param = TS_PAR_REF;} | {tipo_param = TS_PAR_VAL;}
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

tipo        : INTEGER | IMAGINARIO
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

lista_id_param: lista_id_param VIRGULA IDENT
              {
        				nParam++;
						nParam_local++;
        				tSimboloTs *t = criaSimboloTS_PF(token, TS_CAT_PF, nivelLexico, tipo_param);
						list_push(t, lista_param);
			  }
			  | IDENT
              {
        				nParam++;
						nParam_local++;
        				tSimboloTs *t = criaSimboloTS_PF(token, TS_CAT_PF, nivelLexico, tipo_param);
						list_push(t, lista_param);
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

numero: NUMERO
	    {
			sprintf(elementoEsquerda, "%s", token);
		}
	    DOIS_PONTOS
	 	{
			tSimboloTs *s = buscaTS(elementoEsquerda);
			memset(elementoEsquerda, 0, TAM_TOKEN);
			tSimboloTs *t = list_value(list_first(fupr));
			int i, *nvl;
			nvl = list_value(list_first(totalVars));
			sprintf(comando, "ENRT %d, %d", nivelLexico, *nvl);
			geraCodigo(s->categoriaTs.l->rotulo, comando);
			memset(comando, 0, 64);
		} |
;

comando_sem_rotulo: atr_ou_proc | comando_repetitivo | comando_condicional | comando_6070 | leitura | escrita
;

leitura: READ ABRE_PARENTESES lista_read FECHA_PARENTESES
;

lista_read: lista_read VIRGULA IDENT
	{
		geraCodigo(NULL, "LEIT");
		tSimboloTs *s = buscaTS(token);
		if (s->categoria == TS_CAT_VS || (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_VAL))
			sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		else if (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_REF)
			sprintf(comando, "ARMI %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		memset(elementoEsquerda, 0, TAM_TOKEN);
	}
	| IDENT
	{
		geraCodigo(NULL, "LEIT");
		tSimboloTs *s = buscaTS(token);
		if (s->categoria == TS_CAT_VS || (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_VAL))
			sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		else if (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_REF)
			sprintf(comando, "ARMI %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
		memset(elementoEsquerda, 0, TAM_TOKEN);
	}
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
			| chamada_proc
;

chamada_proc: ABRE_PARENTESES
			 {ch_proc = 1; nParam_chamada = 0;
			  tSimboloTs *t = buscaTS(elementoEsquerda);
			  tAtual = t;
			  if (t->categoria == TS_CAT_CF)
				geraCodigo(NULL, "AMEM 1");
			 }
			 alguma_coisa FECHA_PARENTESES
			 {
			  	tSimboloTs *t = buscaTS(elementoEsquerda);
				memset(elementoEsquerda, 0, TAM_TOKEN);
				int i = t->categoriaTs.c->nParams;
				for(;i > 0;i--){
					list_pop(tipoExp);
				}
				sprintf(comando, "CHPR %s, %d", t->categoriaTs.c->rotulo, nivelLexico);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
				ch_proc = 0;
			 }
		   | {
				tSimboloTs *t = buscaTS(elementoEsquerda);
				tAtual = t;
			  	if (t->categoria == TS_CAT_CF)
				  geraCodigo(NULL, "AMEM 1");
				memset(elementoEsquerda, 0, TAM_TOKEN);
				sprintf(comando, "CHPR %s, %d", t->categoriaTs.c->rotulo, nivelLexico);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
			 }
;

alguma_coisa: alguma_coisa VIRGULA e {nParam_chamada++;} | e {nParam_chamada++;} |
;

expressao: e {
		tSimboloTs *s = buscaTS(elementoEsquerda);
		int *d = list_value(list_pop(tipoExp));
		if (s->categoria == TS_CAT_VS){
			if(s->categoriaTs.v->tipo != *d){
				printf("Erro de atribuicao\n");
				exit(0);
			}
			sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		}
		else if (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_VAL){
			if(s->categoriaTs.p->tipo != *d){
				printf("Erro de atribuicao\n");
				exit(0);
			}
			sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.p->deslocamento);
		}
		else if (s->categoria == TS_CAT_PF && s->categoriaTs.p->tipoPassagem == TS_PAR_REF){
			if(s->categoriaTs.p->tipo != *d){
				printf("Erro de atribuicao\n");
				exit(0);
			}
			sprintf(comando, "ARMI %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		}
		else if (s->categoria == TS_CAT_CF){
			if(s->categoriaTs.f->v->tipo != *d){
				printf("Erro de atribuicao\n");
				exit(0);
			}
			sprintf(comando, "ARMZ %d, %d", s->nivel, s->categoriaTs.f->v->deslocamento);
		}
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
	| NOT ABRE_PARENTESES avalia_expressao FECHA_PARENTESES {geraCodigo(NULL, "NEGA");}
	| e relacao e {
		int* e, *d;
		d = list_value(list_pop(tipoExp));
		e = list_value(list_pop(tipoExp));
		if(*d != *e){
			printf("Erro de comparacao\n");
			exit(0);
		}
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
		int* e, *d, *r;
		d = list_value(list_pop(tipoExp));
		e = list_value(list_pop(tipoExp));
		if(*d != *e){
			printf("Erro de tipos\n");
			exit(0);
		}
		r = malloc(sizeof(int));
		*r = *d;
		list_push(r,tipoExp);
		sprintf(comando, "SOMA");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
    }
 | e MENOS f {
		int* e, *d, *r;
		d = list_value(list_pop(tipoExp));
		e = list_value(list_pop(tipoExp));
		if(*d != *e){
			printf("Erro de tipos\n");
			exit(0);
		}
		r = malloc(sizeof(int));
		*r = *d;
		list_push(r,tipoExp);
		sprintf(comando, "SUBT");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | f
;

f: f ASTERISCO t {
		int* e, *d, *r;
		d = list_value(list_pop(tipoExp));
		e = list_value(list_pop(tipoExp));
		if(*d != *e){
			printf("Erro de tipos\n");
			exit(0);
		}
		r = malloc(sizeof(int));
		*r = TS_TIP_INT;
		list_push(r,tipoExp);
		sprintf(comando, "MULT");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | f DIV t {
		int* e, *d, *r;
		d = list_value(list_pop(tipoExp));
		e = list_value(list_pop(tipoExp));
		if(*d != *e){
			printf("Erro de tipos\n");
			exit(0);
		}
		r = malloc(sizeof(int));
		*r = TS_TIP_INT;
		list_push(r,tipoExp);
		sprintf(comando, "DIVI");
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 | t
;

t: variavel
 | qual_numero
 | ABRE_PARENTESES e FECHA_PARENTESES
 | chamada_func
;

qual_numero:NUMERO
			{
				sprintf(comando, "CRCT %s", token);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
				int *tipo = malloc(sizeof(int));
				*tipo = TS_TIP_INT;
				list_push(tipo,tipoExp);
			}
		   | NUMERO_I
			{
				int i;
				for(i = 0; i < TAM_TOKEN; i++)
					if (token[i] = 'i')
						token[i] = '\0';
				sprintf(comando, "CRCT %s", token);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
				int *tipo = malloc(sizeof(int));
				*tipo = TS_TIP_IMG;
				list_push(tipo,tipoExp);
			}
;

variavel: IDENT
 {
		tSimboloTs *s = buscaTS(token);
		if (s && s->categoria == TS_CAT_CF) {
			tAtual = buscaTS(token);
			int *tipo = malloc(sizeof(int));
			*tipo = s->categoriaTs.f->v->tipo;
			list_push(tipo,tipoExp);
			/*tSimboloTs *t = buscaTS(elementoEsquerda);
			tAtual = t;
			if (t->categoria == TS_CAT_CF)
			  geraCodigo(NULL, "AMEM 1");
			memset(elementoEsquerda, 0, TAM_TOKEN);
			sprintf(comando, "CHPR %s, %d", t->categoriaTs.c->rotulo, nivelLexico);
			geraCodigo(NULL, comando);
			memset(comando, 0, 64);*/
		} else if (s) {
			int *tp;
			int *tipo = malloc(sizeof(int));
			//if(!ch_proc){
				if(s->categoria == TS_CAT_VS)
					*tipo = s->categoriaTs.v->tipo;
				else if(s->categoria == TS_CAT_PF)
					*tipo = s->categoriaTs.p->tipo;
				list_push(tipo,tipoExp);
			//}
		if(ch_proc) {
			int i = 0; node n;
			if (ch_proc == 1)
				for(n = list_first(tAtual->categoriaTs.c->tipoPassagem); n && i < nParam_chamada; n = list_next(n)){
					i++;
				}
			else if (ch_proc == 2)
				for(n = list_first(tAtual->categoriaTs.f->p->tipoPassagem); n && i < nParam_chamada; n = list_next(n)){
					i++;
				}
			tp = (int *) list_value(n);
		}
		if (s->categoria == TS_CAT_VS) {
			if (ch_proc && *tp == TS_PAR_REF)
				sprintf(comando, "CREN %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
			else
				sprintf(comando, "CRVL %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
		}
		else if (s->categoria == TS_CAT_PF) {
			if (s->categoriaTs.p->tipoPassagem == TS_PAR_VAL) {
				if (ch_proc && *tp == TS_PAR_REF)
					sprintf(comando, "CREN %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
				else
					sprintf(comando, "CRVL %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
			}
			else if (s->categoriaTs.p->tipoPassagem == TS_PAR_REF) {
				if (ch_proc && *tp == TS_PAR_REF)
					sprintf(comando, "CRVL %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
				else
					sprintf(comando, "CRVI %d, %d", s->nivel, s->categoriaTs.v->deslocamento);
			}
		}
		geraCodigo(NULL, comando);
		memset(comando, 0, 64);
	}
 }
;

chamada_func: variavel
			 {ch_proc = 2; nParam_chamada = 0;
			  //tSimboloTs *t = buscaTS(elementoEsquerda);
			  //tAtual = t;
			  if (tAtual->categoria == TS_CAT_CF){
				geraCodigo(NULL, "AMEM 1");
				/*int *r = malloc(sizeof(int));
				*r = tAtual->categoriaTs.f->v->tipo;
				list_push(r,tipoExp);*/
			  }
			 }
			 ABRE_PARENTESES
			 alguma_coisa
			 FECHA_PARENTESES
			 {
			  	//tSimboloTs *t = buscaTS(elementoEsquerda);
				//memset(elementoEsquerda, 0, TAM_TOKEN);
				int i = tAtual->categoriaTs.f->p->nParams;
				for(;i > 0;i--){
					list_pop(tipoExp);
				}
				sprintf(comando, "CHPR %s, %d", tAtual->categoriaTs.f->p->rotulo, nivelLexico);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
				ch_proc = 0;
			 }
;

comando_6070: GOTO NUMERO {
				tSimboloTs *t = buscaTS(token);
				tSimboloTs *s = list_value(list_first(fupr));
				if (s)
					sprintf(comando, "DSVR %s, %d, %d", t->categoriaTs.l->rotulo, t->nivel, s->nivel);
				else
					sprintf(comando, "DSVR %s, %d, %d", t->categoriaTs.l->rotulo, t->nivel, 0);
				geraCodigo(NULL, comando);
				memset(comando, 0, 64);
			 }
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
	nParams = list_new();
	fupr = list_new();
	tipoExp = list_new();
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
