

/* -------------------------------------------------------------------
 *            Arquivo: interpretaMEPA.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 11/2015
 *      Atualizado em: [16/11/2015, 19h:20m]
 *
 * -------------------------------------------------------------------
 *  O interpretador. Para cada instrução em instr, utiliza o 
 *  ambiente virtual MEPA para executar a instrução conforme indicado
 *  no Apêndice 3 do livro do Tomasz.
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include "simulaMepa.h"

/* -------------------------------------------------------------------
 * Máquina de Execução de Pascal (MEPA)
 * ------------------------------------------------------------------- */

#define TAM_PILHA 4096
#define TAM_BASE  16
int M[TAM_PILHA];
int D[16];
int s;
int i;


/* -------------------------------------------------------------------
 * Estrutura contendo as instruções
 * ------------------------------------------------------------------- */

extern instStruct instr[MAX_INSTR];

void imprimePilha() {
  int j;

  printf("------------------------------------ \n");
  printf("Vetor D[]: ");
  for (j=0; j<=5; j++) {
    printf("[%02d] ", j);
  }
  printf("\n");
  printf("           ");
  for (j=0; j<=5; j++) {
    printf(" %02d  ", D[j]);
  }
  printf("\n -------------- \n");
  printf("Vetor M[]: ");
  for (j=0; j<=s; j++) {
    printf("[%02d] ", j);
  }
  printf("\n");
  printf("           ");
  for (j=0; j<=s; j++) {
    printf(" %02d  ", M[j]);
  }
  printf("\n------------------------------------ \n");
}

int depurador (instStruct *instrAtual, int i) {
  char controle;

  printf("[%03d] ", i);
  imprimeInstr(instrAtual);
  printf("\n");
  do {
    scanf("%c", &controle);
    switch (controle) {
    case 'm':
      imprimePilha();
      break;
    } 
  } while (controle != '\n' && controle != 'q');
  if (controle == 'q')
    return 1;
  else
    return 0;
}

interpretaMEPA() {
  int lido, temp1, temp2, j, fim;
  char controle;
  instStruct *instrAtual;

  // inicia estruturas de execução
  for (j=0;j<TAM_PILHA;j++)
    M[j]=0;
  for (j=0;j<TAM_BASE;j++)
    D[j]=0;
  i=0;

  printf("\nIniciando Execução\n");
  if (arg_debug) {
    printf("Modo depuração:\n"
           "       q => sai\n"
           "       r => resume execucao\n"
           "       m => imprime D[] e M[]\n"
           "  outros => proximo comando\n");
  }
  int exec_interativa = 1;
  do {
    instrAtual = &instr[i];

    if (arg_debug) {
      printf("[%03d] ", i);
      imprimeInstr(instrAtual);
      printf("\n");
      fim=0;
      while (!fim && exec_interativa) {
          scanf(" %c",&controle);
          getchar(); // consome o pulo de linha ('\n')
          switch (controle) {
          case 'm':
            imprimePilha();
            break;
          case 'r':
            exec_interativa=0;
            break;
          case 'q':
            printf("Execução cancelada\n");
            exit(-1);
          default:
            fim=1;
            break;
          }
      }
    };

    instrAtual = &instr[i];

    switch (instrAtual->inst) {
    case inpp:
      s = -1;
      D[0] = 0;
      i++;
      break;
    case soma:
      M[s-1] = M[s-1] + M[s];
      s--;
      i++;
      break;
    case subt:
      M[s-1] = M[s-1] - M[s];
      s--;
      i++;
      break;
    case mult:
      M[s-1] = M[s-1] * M[s];
      s--;
      i++;
      break;
    case divi:
      M[s-1] = M[s-1] / M[s];
      s--;
      i++;
      break;
    case invr:
    case conj:
      M[s-1] = M[s-1] && M[s];
      s--;
      i++;
      break;
    case disj:
      M[s-1] = M[s-1] || M[s];
      s--;
      i++;
      break;
    case nega:
    case cmme:
      M[s-1] = M[s-1] < M[s];
      s--;
      i++;
      break;
    case cmma:
      M[s-1] = M[s-1] > M[s];
      s--;
      i++;
      break;
    case cmig:
      M[s-1] = M[s-1] == M[s];
      s--;
      i++;
      break;
    case cmeg:
      M[s-1] = M[s-1] <= M[s];
      s--;
      i++;
      break;
    case cmag:
      M[s-1] = M[s-1] >= M[s];
      s--;
      i++;
       break;
   case cmdg:
      M[s-1] = M[s-1] != M[s];
      s--;
      i++;
      break;
    case nada:
      i++;
      break;
    case leit:
      printf("Digite um número: ");
      scanf ("%d", &lido);
      s++;
      M[s]=lido;
      i++;
      break;
    case impr:
      printf ("%d\n", M[s]);
      s--;
      i++;
      break;
    case crct:
      s++;
      M[s]=instrAtual->op1;
      i++;
      break;
    case amem: 
      s+=instrAtual->op1;
      i++;
      break;  
    case dmem:
      s-=instrAtual->op1;
      i++;
      break;
    case crvl:
      s++;
      M[s] = M[D[instrAtual->op1] + instrAtual->op2];
      i++;
      break;
    case armz:
      M[D[instrAtual->op1] + instrAtual->op2] = M[s];
      s--;
      i++;
      break;
    case crvi:
      s++;
      M[s] = M[M[D[instrAtual->op1] + instrAtual->op2]];
      i++;
      break;
    case armi:
      M[M[D[instrAtual->op1] + instrAtual->op2]] = M[s];
      s--;
      i++;
      break;
    case cren:
      s++;
      M[s] = D[instrAtual->op1] + instrAtual->op2;
      i++;
      break;
    case dsvs:
      i=instrAtual->endDesvio;
      break;
    case dsvf:
      if (M[s] == 0)
        i=instrAtual->endDesvio; 
      else
        i++;
      s--;
      break;
    case chpr:
      M[s+1]=i+1;
      M[s+2]=instrAtual->op2;
      s+=2;
      i=instrAtual->endDesvio;
      break;
    case enpr:
      s++;
      M[s]=D[instrAtual->op1];
      D[instrAtual->op1] = s+1;
      i++;
      break;
    case rtpr:
      D[instrAtual->op1] = M[s];
      i = M[s-2];
      s = s-(instrAtual->op2+3);
      break;
    case enrt:
      s = D[instrAtual->op1]+instrAtual->op2-1;
      i++;
      break;
    case dsvr:
      temp1 = instrAtual->op2;
      while (temp1 != instrAtual->op1) {
        temp2 = M[D[temp1]-2];
        D[temp1] =  M[D[temp1]-1];
        temp1 = temp2;
      }
      i = instrAtual->endDesvio;
      break;
    }

  } while(instrAtual->inst != para );

  printf("Execução concluída com sucesso\n");

}


