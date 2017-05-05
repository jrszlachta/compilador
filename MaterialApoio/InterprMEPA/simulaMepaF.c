
/* -------------------------------------------------------------------
 *            Aquivo: simulaMepaF.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 11/2015
 *      Atualizado em: [17/11/2015, 11h:00m]
 *
 * -------------------------------------------------------------------
 *
 * Funções auxiliares do simulador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simulaMepa.h"

void ImprimeDebug (char *s)
{
  fprintf(stdout, "%s\n", s);
  fflush (stdout);
}

instStruct instr[MAX_INSTR];

int num_linha=0;

// Rótulo Alvo é o que fica à esquerda do comando enquanto que o
// rótuloDesvio fica à direita do comando.
char rotulo[TAM_TOKEN];
char rotuloAlvo[TAM_TOKEN];
char rotuloDesvio[TAM_TOKEN];

int param1_int;
int param2_int;
int param3_int;
char param1_rot[TAM_TOKEN];
int inteiro;

/* -------------------------------------------------------------------
 * Opções da linha de comando
 * ------------------------------------------------------------------- */

int arg_debug=0;
int arg_impr=0;
char arq_in[10];
char arq_out[10];

/* -------------------------------------------------------------------
 * Coloca os strings apropriados em tabInstr (para o pretty printer)
 * ------------------------------------------------------------------- */
char tabInstr[100][100];
void iniciaTabInstr ()
{
  strcpy(tabInstr[inpp], "INPP"); 
  strcpy(tabInstr[para], "PARA"); 
  strcpy(tabInstr[nada], "NADA"); 
  strcpy(tabInstr[soma], "SOMA"); 
  strcpy(tabInstr[subt], "SUBT"); 
  strcpy(tabInstr[mult], "MULT"); 
  strcpy(tabInstr[divi], "DIVI");
  strcpy(tabInstr[invr], "INVR");
  strcpy(tabInstr[conj], "CONJ");
  strcpy(tabInstr[disj], "DISJ");
  strcpy(tabInstr[nega], "NEGA"); 
  strcpy(tabInstr[cmme], "CMME"); 
  strcpy(tabInstr[cmma], "CMMA"); 
  strcpy(tabInstr[cmig], "CMIG"); 
  strcpy(tabInstr[cmdg], "CMDG"); 
  strcpy(tabInstr[cmeg], "CMEG"); 
  strcpy(tabInstr[cmag], "CMAG"); 
  strcpy(tabInstr[leit], "LEIT"); 
  strcpy(tabInstr[impr], "IMPR"); 
  strcpy(tabInstr[crct], "CRCT"); 
  strcpy(tabInstr[amem], "AMEM"); 
  strcpy(tabInstr[dmem], "DMEM"); 
  strcpy(tabInstr[enpr], "ENPR"); 
  strcpy(tabInstr[dsvs], "DSVS"); 
  strcpy(tabInstr[dsvf], "DSVF"); 
  strcpy(tabInstr[crvl], "CRVL"); 
  strcpy(tabInstr[armz], "ARMZ"); 
  strcpy(tabInstr[crvi], "CRVI"); 
  strcpy(tabInstr[armi], "ARMI"); 
  strcpy(tabInstr[cren], "CREN"); 
  strcpy(tabInstr[enrt], "ENRT"); 
  strcpy(tabInstr[chpr], "CHPR"); 
  strcpy(tabInstr[rtpr], "RTPR"); 
  strcpy(tabInstr[dsvr], "DSVR"); 
}


/* -------------------------------------------------------------------
 *   Insere comando MEPA em "instrn" ("instStruct")
 * -------------------------------------------------------------------  */
void insereInstr ( char* rot, instrucao inst, 
                   int op1,  int op2,  int op3, int op4, char* desvio) {

  if (strcmp(rot,"")==0)
    instr[num_linha].rotulo = NULL;
  else {
    instr[num_linha].rotulo = malloc (TAM_TOKEN);
    strcpy (instr[num_linha].rotulo, rot);
  }

  instr[num_linha].inst = inst;
  instr[num_linha].op1 = op1; 
  instr[num_linha].op2 = op2;
  instr[num_linha].op3 = op3;
  instr[num_linha].op4 = op4;

  if (desvio == NULL)
    instr[num_linha].desvio = desvio;
  else {
    instr[num_linha].desvio = malloc (TAM_TOKEN);
    strcpy (instr[num_linha].desvio, desvio);
  }

  num_linha++;
}
/* -------------------------------------------------------------------
 *   Imprime Programa MEPA (pretty printer)
 * -------------------------------------------------------------------  */

void imprimeInstr(instStruct *instr) {
    // impressão de acordo com o número de parâmetros da instrução
    switch (instr->inst) {
      // Sem Parâmetros --------------------------------------  
    case inpp:
    case para:
    case soma:
    case subt:
    case mult:
    case divi:
    case invr:
    case conj:
    case disj:
    case nega:
    case cmme:
    case cmma:
    case cmig:
    case cmeg:
    case cmag:
    case cmdg:
    case nada:
    case leit:
    case impr:
     printf("%s",
            tabInstr[instr->inst]);
      // 1 Parâmetro    --------------------------------------
      // 2 Parâmetros   --------------------------------------
      // 3 Parâmetros   --------------------------------------
     break;
    case crct:
    case amem:
    case dmem:
    case enpr:
      printf("%s %d",
             tabInstr[instr->inst], 
             instr->op1);
      break;
    case dsvs:
    case dsvf:
      printf("%s %s (%d)",
             tabInstr[instr->inst],  
             instr->desvio,
             instr->endDesvio  );
      break;
    case crvl:
    case armz:
    case crvi:
    case armi:
    case cren:
    case rtpr:
    case enrt:
      printf("%s %d, %d",
             tabInstr[instr->inst], 
             instr->op1, 
             instr->op2 );
      break;
    case chpr:
      printf("%s %s, %d (%d)",
             tabInstr[instr->inst], 
             instr->desvio, 
             instr->op1, 
             instr->endDesvio);
      break;
    case dsvr:
      printf("%s %s, %d, %d (%d)",
             tabInstr[instr->inst], 
             instr->desvio, 
             instr->op1, 
             instr->op2,
             instr->endDesvio);
      break;
    }
}

imprimeProg(){
  int i;
  for (i=0; i<num_linha; i++) {
    // Cabeçalho: numero da linha
    printf("\n[%03d]: ", i);
    // Cabeçalho: rotulo (ou brancos)
    if (instr[i].rotulo == NULL) {
      printf("    ");
    } else {
      printf("%s ", instr[i].rotulo);
    }
    imprimeInstr(&instr[i]);
  }
  printf("\n");
}

/* -------------------------------------------------------------------
 *  Lê estrutura MEPA (instStruct) e substitui os rótulos (lado direito)
 *  pelos endereços onde o rótulo foi definido
 * ------------------------------------------------------------------- */


// tabelaRotulos armazena os rótulos existentes na MEPA.
typedef struct tabelaRotulos {
  char *rot;         // O nome do rótulo
  int  *endereco;   // locais onde é encontrado ([0] indica onde foi
                     // definido
} tabelaRotulos;
#define MAX_ROT 100
int tot_rot=0;
tabelaRotulos *TR;

// busca pelo rótulo solicitado. Retorna a linha se existe e -1 caso
// contrário.
int buscaRotulo (char *rot) {
  int i;
  for (i=0; i<tot_rot; i++) {
    if (strcmp (TR[i].rot, rot) == 0) // achou
      return i;
  }
return (-1);
}

// "RotuloAlvo" é o rótulo à esquerda.
int insereRotuloAlvo (char* rot, int endereco) {
  int i;

  for (i=0; i<tot_rot; i++){
    if (strcmp (TR[i].rot, rot) == 0) { // já existe
      printf("ERRO: Rótulo %s declarado mais de uma vez\n",
             rot);
      exit (-1);
    }
  }
  TR[i].rot = rot;
  TR[i].endereco [0] = endereco;
  tot_rot++;

}

void imprimeTabRotulos (){
  int i;
  printf("---- TABELA DE ROTULOS ---\n");
  for (i=0; i<tot_rot; i++){
    printf("{%d}:%s\n", TR[i].endereco[0], TR[i].rot);
  }
  printf("---- FIM TABELA DE ROTULOS ---\n");
}

void ajustaRotulos(){
  int i, j;

  TR = malloc (sizeof (tabelaRotulos)*MAX_ROT);
  for (i=0; i<MAX_ROT; i++){
    TR[i].rot=0;
    TR[i].endereco = malloc (sizeof(int)*MAX_ROT);
  }

  // (1) percorre a tabela "instStruct". Quando houver algo em
  // "rotulo", cria uma nova entrada em tabelaRotulos, colocando o
  // endereço da instrução em enderecos[0]

  for (i=0; i<num_linha; i++) {
     if (instr[i].rotulo != NULL) {
       insereRotuloAlvo(instr[i].rotulo, i);
     }
  }
  //  imprimeTabRotulos ();

  // (1) percorre a tabela "instStruct" novamente. Cada vez que
  // encontrar um rótulo do lado direito, (desvio), coloca o endereço
  // do rótulo em "endDesvio".

  for (i=0; i<num_linha; i++) {
     if (instr[i].desvio != NULL) {
       j = buscaRotulo (instr[i].desvio);
       if (j < 0) {
         printf("ERRO: Rótulo %s não declarado\n",
                instr[i].desvio);
         exit (-1);
       }
       instr[i].endDesvio=TR[j].endereco[0];
     }
  }


}

