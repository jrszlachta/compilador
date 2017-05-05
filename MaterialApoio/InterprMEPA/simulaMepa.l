/* -------------------------------------------------------------------
 *            Arquivo: simulaMepa.l
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 11/2015
 *      Atualizado em: [17/11/2015, 10h:45m]
 *
 * -------------------------------------------------------------------
 *   Analisador léxico: Reconhecedor dos tokens descritos em 
 *   simulaMepa.y
 * ------------------------------------------------------------------- */

%{

#include<stdio.h>
#include<string.h>

#include "simulaMepa.h"
#include "simulaMepa.tab.h"

%}

descarte [\t ]+
defRotulo [RL][0-9]+
defNumero [-+]?[0-9]+

%%

{descarte}

{defNumero}     { inteiro = atoi (yytext);
                  return INTEIRO; }
{defRotulo}     { strncpy (rotulo, yytext, TAM_TOKEN);
                  return ROTULO; }   
\:              { return DOIS_PONTOS; }
\,              { return VIRGULA; }
INPP            { return INPP; }
PARA            { return PARA; }
NADA            { return NADA; }
SOMA            { return SOMA; }
SUBT            { return SUBT; }
MULT            { return MULT; }
DIVI            { return DIVI; }
INVR            { return INVR; }
CONJ            { return CONJ; }
DISJ            { return DISJ; }
NEGA            { return NEGA; }
CMME            { return CMME; }
CMMA            { return CMMA; }
CMIG            { return CMIG; }
CMDG            { return CMDG; }
CMEG            { return CMEG; }
CMAG            { return CMAG; }
LEIT            { return LEIT; }
IMPR            { return IMPR; }
CRCT            { return CRCT; }
AMEM            { return AMEM; }
DMEM            { return DMEM; }
ENPR            { return ENPR; }
DSVS            { return DSVS; }
DSVF            { return DSVF; }
CRVL            { return CRVL; }
ARMZ            { return ARMZ; }
CRVI            { return CRVI; }
ARMI            { return ARMI; }
CREN            { return CREN; }
ENRT            { return ENRT; }
CHPR            { return CHPR; }
RTPR            { return RTPR; }
DSVR            { return DSVR; }
%%
