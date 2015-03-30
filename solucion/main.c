#include "altaLista.h"
#include <stdio.h>

/** Funciones auxiliares **/
extern unsigned char string_longitud( char *s );
extern char *string_copiar( char *s );
extern bool string_menor( char *s1, char *s2 );
extern bool menorEstudiante( estudiante *s1, estudiante *s2 );

/** Funciones de estudiante **/
extern estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
extern void estudianteBorrar( estudiante *e );
extern bool menorEstudiante( estudiante *e1, estudiante *e2 );
extern void estudianteConFormato( estudiante *e, tipoFuncionModificarString f );
extern void estudianteImprimir( estudiante *e, FILE *file );

/** Funciones de altaLista y nodo **/
extern nodo *nodoCrear( void *dato );
extern void nodoBorrar( nodo *n, tipoFuncionBorrarDato f );
extern altaLista *altaListaCrear( void );
extern void altaListaBorrar( altaLista *l, tipoFuncionBorrarDato f );
extern void altaListaImprimir( altaLista *l, char *archivo, tipoFuncionImprimirDato f );

/** Funciones Avanzadas **/

extern float edadMedia( altaLista *l );
extern void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f );
extern void filtrarAltaLista( altaLista *l, tipoFuncionCompararDato f, void *datoCmp );

// ejemplo de tipoFuncionModificarString
void  sinMayusculas( char* s) {
	int n = string_longitud(s);
	for(int i = 0; i<=n; i++){
		if(s[i] >= 65 && s[i]<=90) {
			s[i] = s[i] + 32;
		}
	}
}

void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f ) {
	if (l->primero == NULL) {
		nodo *nuevo = nodoCrear(dato);
		l->primero = nuevo;
		l->ultimo = nuevo;
	} else {
		nodo *last = l->primero;
		while (last != NULL && f(last->dato, dato)) {
			last = last->siguiente;
		}
		if (last == NULL) {
			// el nuevo nodo va al final de la lista
			insertarAtras(l, dato);
		} else if (last->anterior == NULL) {
			// el nuevo nodo va al principio de la lista
			insertarAdelante(l, dato);
		} else {
			// el nuevo nodo va adelante de *last
			nodo *nuevo = nodoCrear(dato);
			nodo *aux = last->anterior;
			// arreglo atras de nuevo
			aux->siguiente = nuevo;
			nuevo->anterior = aux;
			// arreglo adelante de nuevo
			last->anterior = nuevo;
			nuevo->siguiente = last;
		}
	}
}

void insertarAdelante( altaLista *l, void *dato ){
	nodo *nuevoNodo = nodoCrear( dato );
	nodo *primerNodo = l->primero;
	if( primerNodo == NULL )
		l->ultimo = nuevoNodo;
	else
		primerNodo->anterior = nuevoNodo;
		nuevoNodo->siguiente = primerNodo;
	l->primero = nuevoNodo;
}

int main (void){
	// probando funciones auxiliares
	unsigned char a = string_longitud("abcd");
	unsigned char b = string_longitud("");
	printf("%d, %d\n", a, b);

	char *c = string_copiar("abcd");
	char *d = string_copiar("");
	printf("%s, %s\n", c, d);
	free(c);
	free(d);

	bool b1 = string_menor("merced", "mercurio"); // true
	bool b2 = string_menor("perro", "zorro"); // true
	bool b3 = string_menor("senior", "seniora"); // true
	bool b4 = string_menor("caZa", "casa"); // true
	bool b5 = string_menor("hola", "hola"); // false
	printf("%d, %d, %d, %d, %d\n", b1, b2, b3, b4, b5);

	// probando funcinoes de estudiante
	estudiante* e1 = estudianteCrear("Ivan", "ASDF", 21);
	printf("%s, %d - %s  \n", e1->nombre, e1->edad, e1->grupo);

	estudiante* e2 = estudianteCrear("Ivan", "ASDF", 20);
	estudiante* e3 = estudianteCrear("Gabriel", "ASDF", 22);

	b1 = menorEstudiante(e1, e1); // true
	b2 = menorEstudiante(e1, e2); // false
	b3 = menorEstudiante(e1, e3); // false
	b4 = menorEstudiante(e3, e1); // true
	b5 = menorEstudiante(e2, e1); // true
	printf("%d, %d, %d, %d, %d\n", b1, b2, b3, b4, b5);

	estudianteBorrar(e2);

	estudianteConFormato(e1, (tipoFuncionModificarString) sinMayusculas);
	printf("%s, %d - %s  \n", e1->nombre, e1->edad, e1->grupo);

	estudianteImprimir(e3, stdout);
	estudianteBorrar(e3);

	// probando funciones de nodo
	nodo *n = nodoCrear(e1);
	void *dato = n->dato;
	estudiante *e_aux = (estudiante*)dato;
	printf("%s\n", e_aux->nombre);

	// no hace falta llamar a estudianteBorrar(e1); ya que lo hace nodoBorrar
	nodoBorrar(n, (tipoFuncionBorrarDato)estudianteBorrar);

	// probando funciones de altaLista
	altaLista *l = altaListaCrear();

	e1 = estudianteCrear("Ivan", "ASDF", 21);
	insertarOrdenado(l, e1, (tipoFuncionCompararDato) menorEstudiante);

	return 0;
}
