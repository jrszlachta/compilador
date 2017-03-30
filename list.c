#include <stdio.h>
#include <stdlib.h>
#include "list.h"

//---------------------------------------------------------------------------
// nó de lista encadeada cujo conteúdo é um void *

struct node {

  void *value;
  node next;
};
//---------------------------------------------------------------------------
// lista encadeada

struct list {

  unsigned int size;
  int padding; // só pra evitar warning
  node first;
};
//---------------------------------------------------------------------------
// devolve o número de nós da lista l

unsigned int list_size(list l) { return l->size; }

//---------------------------------------------------------------------------
// devolve o first nó da lista l,
//      ou NULL, se l é vazia

node list_first(list l) { return l->first; }

//---------------------------------------------------------------------------
// devolve o conteúdo do nó n
//      ou NULL se n = NULL

void *list_value(node n) { return n->value; }

//---------------------------------------------------------------------------
// devolve o sucessor do nó n,
//      ou NULL, se n for o último nó da lista

node list_next(node n) { return n->next; }

//---------------------------------------------------------------------------
// cria uma lista vazia e a devolve
//
// devolve NULL em caso de falha

list list_new(void) {

  list l = malloc(sizeof(struct list));

  if ( ! l )
    return NULL;

  l->first = NULL;
  l->size = 0;

  return l;
}
//---------------------------------------------------------------------------
// desaloca a lista l e todos os seus nós
//
// se destroi != NULL invoca
//
//     destroi(value(n))
//
// para cada nó n da lista.
//
// devolve 1 em caso de sucesso,
//      ou 0 em caso de falha

int list_free(list l, int destroy(void *)) {

  node p;
  int ok=1;

  while ( (p = list_first(l)) ) {

    l->first = list_next(p);

    if ( destroy )
      ok &= destroy(list_value(p));

    free(p);
  }

  free(l);

  return ok;
}
//---------------------------------------------------------------------------
// insere um novo nó na lista l cujo conteúdo é p
//
// devolve o no recém-criado
//      ou NULL em caso de falha

node list_push(void *value, list l) {

  node novo = malloc(sizeof(struct node));

  if ( ! novo )
    return NULL;

  novo->value = value;
  novo->next = list_first(l);
  ++l->size;

  return l->first = novo;
}

//------------------------------------------------------------------------------
// remove o elemento do topo da lista L
//
// devolve NULL em caso de falha

node list_pop(list l)
{
  if (list_size(l)>0)
  {
    node n = list_first(l);
    if (l->first == n)
    {
  		l->first = n->next;
  		l->size--;
  		return n;
  	}
  	for (node n1 = list_first(l); n1->next; n1 = list_next(n1))
    {
  		if (n1->next == n) {
  			n1->next = n->next;
  			l->size--;
  			return n;
  		}
  	}
  }
  return NULL;
}

//------------------------------------------------------------------------------
// remove o no de endereço rno de l
// se destroi != NULL, executa destroi(value(rno))
// devolve 1, em caso de sucesso
//         0, se rno não for um no de l

int list_remove(struct list *l, struct node *rno, int destroy(void *)) {
	int r = 1;
	if (l->first == rno) {
		l->first = rno->next;
		if (destroy != NULL) {
			r = destroy(list_value(rno));
		}
		free(rno);
		l->size--;
		return r;
	}
	for (node n = list_first(l); n->next; n = list_next(n)) {
		if (n->next == rno) {
			n->next = rno->next;
			if (destroy != NULL) {
				r = destroy(list_value(rno));
			}
			free(rno);
			l->size--;
			return r;
		}
	}
	return 0;
}
