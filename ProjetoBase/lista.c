#include <malloc.h>
#include "lista.h"

unsigned int tamanho_lista(lista l) {return l->tamanho;}
no primeiro_no(lista l) {return l->primeiro;}
no proximo_no(no n) {return n->proximo;}
void *conteudo(no n) {return n->conteudo;}

lista constroi_lista(void){
	lista l = malloc(sizeof(struct lista));
	if (!l) return NULL;
	l->primeiro = NULL;
	l->ultimo = NULL;
	l->tamanho = 0;
	return l;
}

int destroi_lista(lista l, int destroi(void *)) {
	no p;
	int ok = 1;
	while( (p = primeiro_no(l)) ) {
		l->primeiro = proximo_no(p);
		if (destroi) ok &= destroi(conteudo(p));
		free(p);
	}
	free(l);
	return ok;
}

no insere(void *conteudo, lista l) {
	no novo = malloc(sizeof(struct no));
	if (!novo) return NULL;
	novo->conteudo = conteudo;
	novo->proximo = primeiro_no(l);
	++l->tamanho;
	return l->primeiro = novo;
}

int desempilha(struct lista *l, int destroi(void *)) {
	int r;
	no rno = primeiro_no(l);
	l->primeiro = rno->proximo;
	if (destroi != NULL) {
		r = destroi(conteudo(rno));
	}
	free(rno);
	l->tamanho--;

}

int remove_no(struct lista *l, struct no *rno, int destroi(void *)) {
	int r = 1;
	if (l->primeiro == rno) {
		l->primeiro = rno->proximo;
		if (destroi != NULL) {
			r = destroi(conteudo(rno));
		}
		free(rno);
		l->tamanho--;
		return r;
	}
	for (no n = primeiro_no(l); n->proximo; n = proximo_no(n)) {
		if (n->proximo == rno) {
			n->proximo = rno->proximo;
			if (destroi != NULL) {
				r = destroi(conteudo(rno));
			}
			free(rno);
			l->tamanho--;
			return r;
		}
	}
	return 0;
}
