
# *****************************************************************
# INICIO macros
# *****************************************************************


# -----------------------------------------------------------------
#  INPP
# -----------------------------------------------------------------

.macro INPP
   movq %rsp, %rax
   movq $0, %rdi
   movq %rax, D(,%rdi,4)
.endm

# -----------------------------------------------------------------
#  PARA
# -----------------------------------------------------------------

.macro PARA
   movq $FIM_PGMA, %rax
   int  $SYSCALL
.endm

# -----------------------------------------------------------------
#  AMEM
# -----------------------------------------------------------------

.macro AMEM mem
   movq $\mem, %rax
   movq $4, %rbx
   imulq %rbx, %rax
   subq %rax, %rsp
.endm

# -----------------------------------------------------------------
#  DMEM
# -----------------------------------------------------------------

.macro DMEM mem
   movq $\mem, %rax
   movq $4, %rbx
   imulq %rbx, %rax
   addq %rax, %rsp
.endm


# -----------------------------------------------------------------
#  CRCT
# -----------------------------------------------------------------

.macro CRCT k
   pushq $\k
.endm



# -----------------------------------------------------------------
#  CRVL
# -----------------------------------------------------------------

.macro CRVL m n
   movq $\m, %rdi
   movq D(,%rdi,4), %rax
   movq $\n, %rbx
   imul $4, %rbx
   subq %rbx, %rax
   movq (%rax), %rax
   pushq %rax
.endm

# -----------------------------------------------------------------
#  ARMZ
# -----------------------------------------------------------------

.macro ARMZ m n
   popq %rcx
   movq $\m, %rdi
   movq D(,%rdi,4), %rax
   movq $\n, %rbx
   imul $4, %rbx
   subq %rbx, %rax
   movq %rcx, (%rax)

.endm


# -----------------------------------------------------------------
#  CREN
# -----------------------------------------------------------------

.macro CREN m n
   movq $\m, %rdi
   movq D(,%rdi,4), %rax
   movq $\n, %rbx
   imul $4, %rbx
   subq %rbx, %rax
   pushq %rax
.endm

# -----------------------------------------------------------------
#  CRVI
# -----------------------------------------------------------------

.macro CRVI m n
   movq $\m, %rdi
   movq D(,%rdi,4), %rax
   movq $\n, %rbx
   imul $4, %rbx
   subq %rbx, %rax
   movq (%rax), %rax
   movq (%rax), %rax
   pushq %rax
.endm

# -----------------------------------------------------------------
#  ARMI
# -----------------------------------------------------------------

.macro ARMI m n
   popq %rcx
   movq $\m, %rdi
   movq D(,%rdi,4), %rax
   movq $\n, %rbx
   imul $4, %rbx
   subq %rbx, %rax
   movq (%rax), %rax
   movq %rcx, (%rax)
.endm

# -----------------------------------------------------------------
#  ENRT
# -----------------------------------------------------------------

.macro ENRT j n
   movq $\n, %rax
   subq $1, %rax
   imul $4, %rax
   movq $\j, %rdi
   movq D(,%rdi,4), %rbx
   subq %rbx, %rax
   movq %rax, %rsp
.endm

# -----------------------------------------------------------------
#  NADA
# -----------------------------------------------------------------

.macro NADA
   nop
.endm

# -----------------------------------------------------------------
#  DSVS
# -----------------------------------------------------------------

.macro DSVS rot
   jmp \rot
.endm

# -----------------------------------------------------------------
#  DSVF
#  Se topo da pilha == 0, entao desvia para rot,
#                          senao segue
#  Implementa��o complicada.
#  - chama _dsvf com a pilha na seguinte situa�ao:
#      valor booleano (%rcx)
#      endereco de retorno se topo=0 (%rbc)
#      endereco de retorno se topo=1 (%rax)
#  - basta empilhar [%rax, %rbx] de acordo com %rcx e "ret"
#
# -----------------------------------------------------------------

.macro DSVF rot
   pushq $\rot
   call _dsvf
.endm

_dsvf:
   popq %rax
   popq %rbx
   popq %rcx
   cmpq $0, %rcx
   je  _dsvf_falso
   pushq %rax
   ret
_dsvf_falso:
   pushq %rbx
   ret

# -----------------------------------------------------------------
#  DSVR - Desvia para r�tulo
#
# -----------------------------------------------------------------

.macro DSVR rot j k
   pushq $\j
   pushq $\k
   call _dsvr
   jmp \rot
.endm

 _dsvr:
    popq %rax # k
    popq %rbx # j

    pushq %rax
    pushq %rax
    ret


# -----------------------------------------------------------------
#  IMPR
# -----------------------------------------------------------------

.macro IMPR
   pushq $strNumOut
   call printf
   addq $8, %rsp
.endm

# -----------------------------------------------------------------
#  LEIT
# -----------------------------------------------------------------

.macro LEIT
   pushq $entr
   pushq $strNumIn
   call scanf
   addq $8, %rsp
   pushq entr
.endm

# -----------------------------------------------------------------
#  SOMA
# -----------------------------------------------------------------

.macro SOMA
   popq %rax
   popq %rbx
   addq %rax, %rbx
   push %rbx
.endm

# -----------------------------------------------------------------
#  SUBT
# -----------------------------------------------------------------

.macro SUBT
   popq %rax
   popq %rbx
   subq %rax, %rbx
   push %rbx
.endm

# -----------------------------------------------------------------
#  MULT
# -----------------------------------------------------------------

.macro MULT
   popq %rax
   popq %rbx
   imul %rax, %rbx
   push %rbx
.endm

# -----------------------------------------------------------------
#  DIVI
# A divis�o no intel � esquisita. O comando divl n�o usa dois
# operandos, mas sim um. A instru��o assume que a divis�o � do par
# %rdx:%rax (64 # bits) pelo par�metro. O quociente vai em %rax e o
# resto vai # para %rdx.
# -----------------------------------------------------------------

.macro DIVI
   popq %rdi     # divisor
   popq %rax     # dividendo
   movq $0, %rdx # n�o pode esquecer de zerar %rdx quando n�o o usar.
   idiv %rdi     #  faz %rdx:%rax / %rdi
   push %rax     # empilha o resultado
.endm

# -----------------------------------------------------------------
#  INVR
# -----------------------------------------------------------------

.macro INVR
   popq %rax
   imul $-1, %rax
   push %rax
.endm

# -----------------------------------------------------------------
#  CONJ (E)
# -----------------------------------------------------------------

.macro CONJ
   popq %rax
   popq %rbx
   and  %rax, %rbx
   push %rbx
.endm

# -----------------------------------------------------------------
#  DISJ (OU)
# -----------------------------------------------------------------

.macro DISJ
   popq %rax
   popq %rbx
   or   %rax, %rbx
   push %rbx
.endm

# -----------------------------------------------------------------
#  NEGA (not)
# -----------------------------------------------------------------

.macro NEGA
   popq %rax
   movq $1, %rbx
   subq %rax, %rbx
   movq %rbx, %rax
   push %rax
.endm

# -----------------------------------------------------------------
#  CMME
# -----------------------------------------------------------------

.macro CMME
   popq %rax
   popq %rbx
   call _cmme
   pushq %rcx
.endm

_cmme:
   cmpq %rax,  %rbx
   jl _cmme_true
   movq $0, %rcx
   ret
_cmme_true:
   movq $1, %rcx
   ret


# -----------------------------------------------------------------
#  CMMA
# -----------------------------------------------------------------

.macro CMMA
   popq %rax
   popq %rbx
   call _cmma
   pushq %rcx
.endm

_cmma:
   cmpq %rax,  %rbx
   jg _cmma_true
   movq $0, %rcx
   ret
_cmma_true:
   movq $1, %rcx
   ret


# -----------------------------------------------------------------
#  CMIG
# -----------------------------------------------------------------

.macro CMIG
   popq %rax
   popq %rbx
   call _cmig
   pushq %rcx
.endm

_cmig:
   cmpq %rax,  %rbx
   je _cmig_true
   movq $0, %rcx
   ret
_cmig_true:
   movq $1, %rcx
   ret

# -----------------------------------------------------------------
#  CMDG
# -----------------------------------------------------------------

.macro CMDG
   popq %rax
   popq %rbx
   call _cmdg
   pushq %rcx
.endm

_cmdg:
   cmpq %rax,  %rbx
   jne _cmdg_true
   movq $0, %rcx
   ret
_cmdg_true:
   movq $1, %rcx
   ret

# -----------------------------------------------------------------
#  CMEG
# -----------------------------------------------------------------

.macro CMEG
   popq %rax
   popq %rbx
   call _cmeg
   pushq %rcx
.endm

_cmeg:
   cmpq %rax,  %rbx
   jle _cmle_true
   movq $0, %rcx
   ret
_cmle_true:
   movq $1, %rcx
   ret


# -----------------------------------------------------------------
#  CMAG
# -----------------------------------------------------------------

.macro CMAG
   popq %rax
   popq %rbx
   call _cmag
   pushq %rcx
.endm

_cmag:
   cmpq %rax,  %rbx
   jge _cmge_true
   movq $0, %rcx
   ret
_cmge_true:
   movq $1, %rcx
   ret



# -----------------------------------------------------------------
# CHPR p,m { M[s+1]:=i+1; M[s+2]:=m; s:= s+2;  i:=p}
#
# Alterado para: CHPR p,m { M[s+1]:=m; M[s+2]:=i+1; s:= s+2;  i:=p}
#
# CHPR - A implementa��o de chamadas de procedimento � diferente da
# proposta original do livro. O problema � como guardar o ER e depois
# disso guardar k. � poss�vel fazer, por�m fica muito complicado (at�
# na volta do procedimento). Por isso, optei por fazer uma
# implementa��o diferente. Primeiro vai "k" e depois "ER". Isso
# implica em altera��es na implementa��o de ENPR, RTPR e DSVR - mas
# n�o no n�vel de gera��o de comandos. Os mesmos comandos MEPA
# funcionam aqui igual ao que funcionariam na id�ia original (exceto
# pela inver��o de k e ER, evidentemente).
# -----------------------------------------------------------------

.macro CHPR rot k
   pushq $\k
   call \rot
.endm


# -----------------------------------------------------------------
#
# ENPR k { s++; M[s]:=D[k]; D[k]:=s+1 }
#
# -----------------------------------------------------------------

.macro ENPR k
   movq $\k, %rdi
   movq D(,%rdi,4), %rax
   pushq %rax
   movq %rsp, %rax
   subq $4, %rax
   movq %rax, D(,%rdi,4)
.endm

# -----------------------------------------------------------------
# original: RTPR k,n { D[k]:=M[s]; i:=M[s-2];  s:=s-(n+3) }
# adaptado: RTPR k,n { D[k]:=pop;  i:=pop; lixo:=pop; s:=s-n }
# -----------------------------------------------------------------

.macro RTPR k n
   popq %rax # D[k] salvo
   popq %rbx # ER. Tem que salvar enquanto libera o resto da pilha
   popq %rcx # k do chamador (a ser jogado fora)

   movq $\k, %rdi
   movq %rax, D(,%rdi,4)

   movq $\n, %rax
   imul $4, %rax
   addq %rax, %rsp # esp <- esp - rax
   pushq %rbx      # restaura ER para poder fazer "i=M[s-1]"="ret"
   ret
.endm


# -----------------------------------------------------------------
#  Macros para depura��o
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Imprime tracos para indicar passagem
# -----------------------------------------------------------------

.macro IMPRQQ
  pushq $strTR
  call printf
  addq $4, %rsp
.endm



# -----------------------------------------------------------------
#  impime_RA
#       k = nivel lexico do ra
#       n = numero de parametros
#       v = numero de vars simples
# -----------------------------------------------------------------
 .macro imprime_RA k,n,v
RT:       pushq $\k
    pushq $\n
    pushq $\v
    call _imprime_RA
 .endm

 _imprime_RA:
   popq %rbx  # ER
   popq %rcx  # v
   popq %rdx  # n
   popq %rdi  # k
   movq D(,%rdi,4), %rax
   pushq $strIniRA
   call printf
   addq $4, %rsp

_impr_vars_locais:
   cmpq $0, %rcx
   jge _fim_vars_locais
   pushq (%rax)
   pushq $strHEX
   call printf
   addq $8, %rsp
_fim_vars_locais:
   push %rbx
   ret



# *****************************************************************
# FIM macros
# *****************************************************************



.section .data
.equ TAM_D, 10
.lcomm D TAM_D


entr: .int 0
strNumOut: .string "%d\n"
strNumIn: .string "%d"
strIniRA: .string "----- strIniRA  --------\n"
strTR: .string "-----\n"
strHEX:   .string "%X\n"


.section .text
.equ FIM_PGMA, 1
.equ SYSCALL, 0x80

.globl _start
_start:

.include "MEPA"
