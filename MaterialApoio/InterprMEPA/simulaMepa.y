/* -------------------------------------------------------------------
 *            Arquivo: simulaMepa.y
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 11/2015
 *      Atualizado em: [17/11/2015, 10h:57m]
 *
 * -------------------------------------------------------------------
 *   Analisador sintático da MEPA.
 *   A regra básica é: 
 *   RXX: XXXX [P1 [P2 [P3]]] 
 * ------------------------------------------------------------------- */

%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "simulaMepa.h"

%}

// símbolos 
%token DOIS_PONTOS ROTULO INTEIRO VIRGULA
// instruções com nenhum parâmetro
%token INPP PARA SOMA SUBT MULT DIVI INVR CONJ DISJ NEGA 
%token CMME CMMA CMIG CMDG CMEG CMAG NADA LEIT IMPR 
// instruções com um parâmetro
%token CRCT AMEM DMEM ENPR ENRT DSVS DSVF 
// instruções com dois parâmetros
%token CRVL ARMZ CRVI ARMI CREN CHPR RTPR DSVR

%%
 // REGRAS --------------------------------

linhas: linhas linha
      | linha
;

linha: rot 
       { 
         strcpy(rotuloAlvo,rotulo);  
         strcpy(rotulo,"");
       } 
       comando 
       {
         strcpy(rotulo,"");
       }
;

// A regra abaixo coloca na variável global "rotulo" o string
// correspondente ao rótulo-alvo (o que fica à esquerda do comando) 
rot : ROTULO DOIS_PONTOS 
    | %empty
;

// Para não exigir a presença da vírgula
virgula : VIRGULA 
        | %empty
;

comando : 
// Comandos com nenhum parâmetro
  INPP { insereInstr (rotuloAlvo, inpp, 0, 0, 0, 0, NULL); };
| PARA { insereInstr (rotuloAlvo, para, 0, 0, 0, 0, NULL); };
| SOMA { insereInstr (rotuloAlvo, soma, 0, 0, 0, 0, NULL); };
| SUBT { insereInstr (rotuloAlvo, subt, 0, 0, 0, 0, NULL); };
| MULT { insereInstr (rotuloAlvo, mult, 0, 0, 0, 0, NULL); };
| DIVI { insereInstr (rotuloAlvo, divi, 0, 0, 0, 0, NULL); };
| INVR { insereInstr (rotuloAlvo, invr, 0, 0, 0, 0, NULL); };
| CONJ { insereInstr (rotuloAlvo, conj, 0, 0, 0, 0, NULL); };
| DISJ { insereInstr (rotuloAlvo, disj, 0, 0, 0, 0, NULL); };
| NEGA { insereInstr (rotuloAlvo, nega, 0, 0, 0, 0, NULL); };
| CMME { insereInstr (rotuloAlvo, cmme, 0, 0, 0, 0, NULL); };
| CMMA { insereInstr (rotuloAlvo, cmma, 0, 0, 0, 0, NULL); };
| CMIG { insereInstr (rotuloAlvo, cmig, 0, 0, 0, 0, NULL); };
| CMDG { insereInstr (rotuloAlvo, cmdg, 0, 0, 0, 0, NULL); };
| CMEG { insereInstr (rotuloAlvo, cmeg, 0, 0, 0, 0, NULL); };
| CMAG { insereInstr (rotuloAlvo, cmag, 0, 0, 0, 0, NULL); };
| NADA { insereInstr (rotuloAlvo, nada, 0, 0, 0, 0, NULL); };
| LEIT { insereInstr (rotuloAlvo, leit, 0, 0, 0, 0, NULL); };
| IMPR { insereInstr (rotuloAlvo, impr, 0, 0, 0, 0, NULL); };

// Comandos com um parâmetro
| CRCT INTEIRO {insereInstr (rotuloAlvo, crct, inteiro, 0, 0, 0, NULL); };
| AMEM INTEIRO {insereInstr (rotuloAlvo, amem, inteiro, 0, 0, 0, NULL); };
| DMEM INTEIRO {insereInstr (rotuloAlvo, dmem, inteiro, 0, 0, 0, NULL); };
| ENPR INTEIRO {insereInstr (rotuloAlvo, enpr, inteiro, 0, 0, 0, NULL); };
| DSVS ROTULO  {insereInstr (rotuloAlvo, dsvs, 0, 0, 0, 0, rotulo); };
| DSVF ROTULO  {insereInstr (rotuloAlvo, dsvf, 0, 0, 0, 0, rotulo); };

// Comandos com dois parâmetros inteiros
| CRVL INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, crvl, param1_int, inteiro, 0, 0, NULL); };
| ARMZ INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, armz, param1_int, inteiro, 0, 0, NULL); };
| CRVI INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, crvi, param1_int, inteiro, 0, 0, NULL); };
| ARMI INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, armi, param1_int, inteiro, 0, 0, NULL); };
| CREN INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, cren, param1_int, inteiro, 0, 0, NULL); };
| ENRT INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, enrt, param1_int, inteiro, 0, 0, NULL); };

// Comandos da parte básica da MEPA
| CHPR ROTULO virgula INTEIRO 
  {insereInstr (rotuloAlvo, chpr, inteiro, 0, 0, 0, rotulo); };
| RTPR INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, rtpr, param1_int, inteiro, 0, 0, NULL); };
| DSVR ROTULO virgula 
       INTEIRO { param1_int = inteiro;} virgula
       INTEIRO {insereInstr (rotuloAlvo, dsvr, param1_int, inteiro, 0, 0, rotulo); };

%%

int yyerror (char *s) {
    fprintf (stderr, "%s\n", s);
}

char* msg_help = "uso: simulaMepa [-d -p -h -iArqIn -oArqOut]\n"
                 "Onde:\n"
                 "    -d => debug\n"
                 "    -p => pretty printer\n"
                 "    -h => help\n"
//               "    -oARQ => arquivo de saída\n"
                 "    -iARQ => arquivo de entrada (default=MEPA)\n";
parser_opcoes(int argc, char **argv) 
{
  int c;

/* -------------------------------------------------------------------
 *   -d => debug
 *   -p => pretty printer
 *   -iARQ => arquivo de entrada
 *   -oARQ => arquivo de saída
 *   -h => help
 * ------------------------------------------------------------------- */

  while ((c = getopt (argc, argv, "dphi:")) != -1)
    switch (c)
      {
      case 'd':
        arg_debug = 1;
        break;
      case 'p':
        arg_impr = 1;
        break;
        /* case 'o': */
        /* strcpy(arq_out, optarg); */
        /* break; */
      case 'i':
        strcpy(arq_in, optarg);
        break;
      case 'h':
        printf("%s", msg_help);
        exit(0);
        break;
      case '?':
        if (optopt == 'i')
          fprintf (stderr, "Option -%i requer nome do arquivo de saida\n", 
                   optopt);
        else if (isprint (optopt))
          fprintf (stderr, "Opcao `-%c' desconecida\n", optopt);
        else
          fprintf (stderr,
                   "o que voce quer dizer com `%c' ?????\n",
                   optopt);
        exit (0);
      default:
        abort ();
      }

  // Se não disse o nome do arquivo de entrada, 
  // então a entrada é o arquivo "MEPA"
  if (strlen(arq_in)==0)
    strcpy (arq_in, "MEPA");
}



main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   parser_opcoes(argc, argv);

   printf("Arquivo de entrada: %s", arq_in);
   fp=fopen (arq_in, "r");
   if (fp == NULL) {
     printf("Arquivo %s não encontrado\n", arq_in);
      return(-1);
   }
  yyin=fp;

  // Iniciações de variáveis globais
  iniciaTabInstr();
  strcpy(rotulo,"");

  // faz a análise sintática e gera os comandos no formato indicado
  // pela "instStruct".
  yyparse();

  // Coloca o número da linha no comandos com rótulos, verifica por
  // duplicidades, etc.
  ajustaRotulos();

  // Imprime (pretty printer) do código MEPA.
  if (arg_impr)
    imprimeProg();

  // Finalmente interpreta os comandos em "instStruct"
  interpretaMEPA();

  return 0;
 }
