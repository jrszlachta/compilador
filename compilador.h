/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, prot�tipos e vai�veis globais do compilador
 *
 * ------------------------------------------------------------------- */

#include "list.h"

#define TAM_TOKEN 16
#define TS_CAT_VS 0;
#define TS_CAT_PF 1;
#define TS_CAT_CP 2;
#define TS_TIP_INT 0;
#define TS_TIP_BOO 1;

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  simb_while, simb_do, simb_if, simb_then, simb_else,
  simb_igual, simb_menor, simb_menor_igual, simb_maior, simb_maior_igual, simb_dif,
} simbolos;

//Campos da tabela de símbolos para variáveis simples
typedef struct vsTs
{
 int deslocamento;
 int tipo;
}tVsTs;

//Campos da tabela de símbolos para parâmetros formais
typedef struct pfTs
{
 int deslocamento;
 int tipoPassagem;
}tPfTs;

//Campos da tabela de símbolos para chamada de procedimentos
typedef struct cpTs
{
 char* rotulo;
 int nivel;
 int nParams;
 int* tipoPassagem;
}tCpTs;

union categoriaTs
{
 tVsTs* v;
 tPfTs* p;
 tCpTs* c;
};

typedef struct simboloTs
{
 char* ident;
 int categoria;
 int nivel;
 union categoriaTs;
}tSimboloTs;

/* -------------------------------------------------------------------
 * vari�veis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;


simbolos simbolo, relacao;
char token[TAM_TOKEN];


int yylex();
void yyerror(const char *s);
void geraCodigo (char* rot, char* comando, int* arg1, int* arg2, int* arg3);
int imprimeErro(char* erro);
tSimboloTs* criaSimboloTS(char* rot, int categoria, int nivel);
int insereTS(tSimboloTs* s);
tSimboloTs* buscaTS(char* rot);
void atualizaTS(int num, char token[TAM_TOKEN]);
int removeTS(int s);
char *intToStr(int n);
