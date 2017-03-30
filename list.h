#ifndef _LIST_H
#define _LIST_H

//-----------------------------------------------------------------------------
// (apontador para) lista encadeada

typedef struct list *list;

//-----------------------------------------------------------------------------
// (apontador para) nó da lista encadeada cujo conteúdo é um void *

typedef struct node *node;

//------------------------------------------------------------------------------
// devolve o número de nós da lista l

unsigned int list_size(list l);

//------------------------------------------------------------------------------
// devolve o primeiro nó da lista l,
//      ou NULL, se l é vazia

node list_first(list l);

//------------------------------------------------------------------------------
// devolve o sucessor do nó n,
//      ou NULL, se n for o último nó da lista

node list_next(node n);

//------------------------------------------------------------------------------
// devolve o conteúdo do nó n
//      ou NULL se n = NULL

void *list_value(node n);
//------------------------------------------------------------------------------
// insere um novo nó na lista l cujo conteúdo é p
//
// devolve o no recém-criado
//      ou NULL em caso de falha

node list_push(void *conteudo, list l);

//------------------------------------------------------------------------------
// remove o elemento do topo da lista L
//
// devolve NULL em caso de falha

node list_pop(list l);



//------------------------------------------------------------------------------
// cria uma lista vazia e a devolve
//
// devolve NULL em caso de falha

list list_new(void);
//------------------------------------------------------------------------------
// desaloca a lista l e todos os seus nós
//
// se destroi != NULL invoca
//
//     destroi(conteudo(n))
//
// para cada nó n da lista.
//
// devolve 1 em caso de sucesso,
//      ou 0 em caso de falha

int list_free(list l, int destroy(void *));

//------------------------------------------------------------------------------
// remove o no de endereço rno de l
// se destroi != NULL, executa destroi(conteudo(rno))
// devolve 1, em caso de sucesso
//         0, se rno não for um no de l

int list_remove(struct list *l, struct node *rno, int destroy(void *));
#endif
