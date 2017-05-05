#ifndef _LISTA_H
#define _LISTA_H

// STRUCTS
typedef struct no *no;
typedef struct lista *lista;

struct no {
	void *conteudo;
	no proximo;
};

struct lista {
	unsigned int tamanho;
	no primeiro;
	no ultimo;
};

// PROTOTYPES
unsigned int tamanho_lista(lista l);
no primeiro_no(lista l);
no proximo_no(no n);
void *conteudo(no n);
lista constroi_lista(void);
int destroi_lista(lista l, int destroi(void *));
no insere(void *conteudo, lista l);
int desempilha(struct lista *l,int destroi(void *));
int remove_no(struct lista *l, struct no *rno, int destroi(void *));

#endif
