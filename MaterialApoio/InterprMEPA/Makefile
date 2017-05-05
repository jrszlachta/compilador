simulaMepa: lex.yy.c y.tab.c simulaMepa.o simulaMepa.h interpretaMEPA.o
	gcc lex.yy.c simulaMepa.tab.c simulaMepa.o interpretaMEPA.o -o simulaMepa -ll -ly -lc

lex.yy.c: simulaMepa.l simulaMepa.h
	flex simulaMepa.l

y.tab.c: simulaMepa.y simulaMepa.h
	bison simulaMepa.y -d -v

simulaMepa.o : simulaMepa.h simulaMepaF.c
	gcc -c simulaMepaF.c -o simulaMepa.o

interpretaMEPA.o : simulaMepa.h interpretaMEPA.c
	gcc -c interpretaMEPA.c -o interpretaMEPA.o

clean : 
	rm -f simulaMepa.tab.* lex.yy.c *.output *.o
