/* -------------------------------------------------------------------
 *            Arquivo: simulaMepa.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 11/2014
 *      Atualizado em: [16/11/2015, 18h:33m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e vaiáveis globais do simulador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <string.h>

typedef enum instrucao { 
  inpp, para, soma, subt, mult, divi, invr, conj, disj, nega, 
  cmme, cmma, cmig, cmdg, cmeg, cmag, nada, leit, impr, 
  crct, amem, dmem, enpr, enrt, dsvs, dsvf,
  crvl, armz, crvi, armi, cren, chpr, rtpr, dsvr

} instrucao;

#define TAM_TOKEN 10
extern char rotulo[TAM_TOKEN];
extern char rotuloAlvo[TAM_TOKEN];
extern char rotuloDesvio[TAM_TOKEN];

extern int param1_int;
extern int param2_int;
extern int param3_int;
extern char param1_rot[TAM_TOKEN];
extern int inteiro;

/* -------------------------------------------------------------------
 * Opções da linha de comando
 * ------------------------------------------------------------------- */

extern int arg_debug;
extern int arg_impr;
extern char arq_in[10];
extern char arq_out[10];


/* -------------------------------------------------------------------
 * Os comandos MEPA do arquivo de entrada são mapeados para a 
 * estrutura de execução abaixo. Cada instrução MEPA é uma linha 
 * em INST
 * ------------------------------------------------------------------- */

typedef struct instStruct {
  char* rotulo; // rótulo associado a esta linha (se não houver, NULL)
  instrucao inst;  // código de operação
  int op1;         // operando 1 
  char rotOp1[10]; // se oper1 for um rótulo, contém o string associado.
  int op2;         // operando 2
  int op3;         // operando 3
  int op4;         // operando 4
  char* desvio;   // o rótulo para onde desviar por exemplo dsvs
  int endDesvio;  // endereço do rótulo "desvio"
} instStruct;

#define MAX_INSTR 4096
extern instStruct instr[MAX_INSTR];
extern int num_linha;

void insereInstr (char* rot, instrucao inst, 
                  int op1,  int op2,  int op3, int op4, char* desvio);

void imprimeInstr(instStruct *instr);
