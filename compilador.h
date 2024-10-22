/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e vaiáveis globais do compilador
 *
 * ------------------------------------------------------------------- */

#include "list.h"

#define TAM_TOKEN 16
//Categoria da tabela de símbolos: Variável Simples
#define TS_CAT_VS 0
//Categoria da tabela de símbolos: Parâmetro Formal
#define TS_CAT_PF 1
//Categoria da tabela de símbolos: Procedimento
#define TS_CAT_CP 2
//Categoria da tabela de símbolos: Função
#define TS_CAT_CF 3
//Categoria da tabela de símbolos: Label
#define TS_CAT_LB 4
//Tipo Integer
#define TS_TIP_INT 0
//Tipo Boolean
#define TS_TIP_BOO 1
//Tipo Imaginarium
#define TS_TIP_IMG 2
//Tipo de passagem de parâmetro: Valor
#define TS_PAR_VAL 0
//Tipo de passagem de parâmetro: Referência
#define TS_PAR_REF 1

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  simb_label, simb_tipo, simb_array,
  simb_procedure, simb_function, simb_goto, simb_if, simb_then,
  simb_else, simb_while, simb_do, simb_or, simb_and, simb_not,
  simb_mais, simb_menos, simb_asterisco, simb_div, simb_igual,
  simb_maior, simb_menor, simb_maior_igual, simb_menor_igual,
  simb_diferente, simb_integer, simb_read, simb_write, simb_imaginarium,
  simb_numeroi
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
 int tipo;
}tPfTs;

//Campos da tabela de símbolos para chamada de procedimentos
typedef struct cpTs
{
 char* rotulo;
 int nivel;
 int nParams;
 list tipoPassagem;
}tCpTs;

//Campos da tabela de símbolos para chamada de função
typedef struct cfTs
{
  tVsTs *v;
  tCpTs *p;
}tCfTs;

//Campos da tabela de símbolos para label
typedef struct lbTs
{
  char *rotulo;
}tLbTs;

typedef struct simboloTs
{
 char* ident;
 int categoria;
 int nivel;
 union categoriaTs
 {
  tVsTs* v;
  tPfTs* p;
  tCpTs* c;
  tCfTs* f;
  tLbTs* l;
 }categoriaTs;
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

int nivel_lexico;
int yylex();
void yyerror(const char *s);
char *geraRotulo(void);
void geraCodigo (char* rot, char* comando);
int imprimeErro(char* erro);

list criaTS();
void imprimeSimboloTS(tSimboloTs* t);
tSimboloTs* criaSimboloTS(char* rot, int categoria, int nivel);
tSimboloTs* criaSimboloTS_VS(char *rot, int categoria, int nivel, int deslocamento);
tSimboloTs* criaSimboloTS_PF(char *rot, int categoria, int nivel, int tipoPassagem);

void atualizaSimboloTS_VS(tSimboloTs* s, int tipo);
void atualizaSimboloTS_PF(list l, int tipo, int nParam);
void atualizaSimboloTS_CP(tSimboloTs* s, char* rotulo, int nivel, int nParams, list tipoPassagem);
void atualizaSimboloTS_CF(tSimboloTs* s, char* rotulo, int nivel, int nParams, list tipoPassagem, int tipoFunc, int desloc);
void atualizaSimboloTS_LB(tSimboloTs *s, char *rotulo);

int insereTS(tSimboloTs* s);
tSimboloTs* buscaTS(char* rot);
void atualizaTS(int num, char token[TAM_TOKEN]);
int removeTS(int s);
char *intToStr(int n);
char *catTS(int categoria);
char *tipoTS(int tipo);
char *tipoPassagemTS(int tipo);
