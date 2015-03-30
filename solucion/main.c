#include "altaLista.h"
#include <stdio.h>

/** Funciones auxiliares **/
extern unsigned char string_longitud( char *s );
extern char *string_copiar( char *s );
extern bool string_menor( char *s1, char *s2 );
extern bool menorEstudiante( estudiante *s1, estudiante *s2 );
extern void insertarAdelante( altaLista *l, void *dato );

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

void funciones_auxiliares() {
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
}

void funciones_estudiante() {
	estudiante* e1 = estudianteCrear("Ivan", "ASDF", 21);
	printf("%s, %d - %s  \n", e1->nombre, e1->edad, e1->grupo);

	estudiante* e2 = estudianteCrear("Ivan", "ASDF", 20);
	estudiante* e3 = estudianteCrear("Gabriel", "ASDF", 22);

	bool b1 = menorEstudiante(e1, e1); // true
	bool b2 = menorEstudiante(e1, e2); // false
	bool b3 = menorEstudiante(e1, e3); // false
	bool b4 = menorEstudiante(e3, e1); // true
	bool b5 = menorEstudiante(e2, e1); // true
	printf("%d, %d, %d, %d, %d\n", b1, b2, b3, b4, b5);

	estudianteBorrar(e2);

	estudianteConFormato(e1, (tipoFuncionModificarString) sinMayusculas);
	printf("%s, %d - %s  \n", e1->nombre, e1->edad, e1->grupo);

	estudianteImprimir(e3, stdout);
	estudianteBorrar(e1);
	estudianteBorrar(e3);
}

void funciones_nodo() {
	estudiante* e1 = estudianteCrear("Ivan", "ASDF", 21);
	nodo *n = nodoCrear(e1);
	void *dato = n->dato;
	estudiante *e_aux = (estudiante*)dato;
	printf("%s\n", e_aux->nombre);

	// no hace falta llamar a estudianteBorrar(e1); ya que lo hace nodoBorrar
	nodoBorrar(n, (tipoFuncionBorrarDato)estudianteBorrar);
}

void funciones_lista() {
	altaLista *l = altaListaCrear();

	// l: <vacia>
	altaListaImprimir(l, "output.txt", (tipoFuncionImprimirDato) estudianteImprimir);

	estudiante* e1 = estudianteCrear("Ivan", "ASDF", 21);
	// l: e1
	insertarOrdenado(l, e1, (tipoFuncionCompararDato) menorEstudiante);

	estudiante* e2 = estudianteCrear("Gabriel", "OTRO", 21);
	// l: e2, e1
	insertarOrdenado(l, e2, (tipoFuncionCompararDato) menorEstudiante);

	estudiante* e3 = estudianteCrear("Ivan", "ASDF", 22);
	// l: e2, e1, e3
	insertarOrdenado(l, e3, (tipoFuncionCompararDato) menorEstudiante);

	altaListaImprimir(l, "output.txt", (tipoFuncionImprimirDato) estudianteImprimir);

	altaListaBorrar(l, (tipoFuncionBorrarDato) estudianteBorrar);
}

void funciones_avanzadas() {
	altaLista *l = altaListaCrear();
	estudiante* e1 = estudianteCrear("Ivan", "ASDF", 21);
	insertarOrdenado(l, e1, (tipoFuncionCompararDato) menorEstudiante);
	estudiante* e2 = estudianteCrear("Gabriel", "OTRO", 21);
	insertarOrdenado(l, e2, (tipoFuncionCompararDato) menorEstudiante);
	estudiante* e3 = estudianteCrear("Juan", "ASDF", 22);
	insertarOrdenado(l, e3, (tipoFuncionCompararDato) menorEstudiante);

	float prom = edadMedia(l);
	printf("%5.2f\n", prom);

	estudiante* e4 = estudianteCrear("Xilofon", "ASDF", 22);
	filtrarAltaLista(l, (tipoFuncionCompararDato) menorEstudiante, e4);
	// filtrar la lista por e4 deberia dejarla como estaba, ya que todos tiene nombre menor
	altaListaImprimir(l, "output.txt", (tipoFuncionImprimirDato) estudianteImprimir);

	e4 = estudianteCrear("Gaspar", "ASDF", 22);
	filtrarAltaLista(l, (tipoFuncionCompararDato) menorEstudiante, e4);
	// deberian quedar en la lista solo e2
	altaListaImprimir(l, "output.txt", (tipoFuncionImprimirDato) estudianteImprimir);

	e4 = estudianteCrear("Anabella", "ASDF", 22);
	filtrarAltaLista(l, (tipoFuncionCompararDato) menorEstudiante, e4);
	// ahora l deberia quedar vacia
	altaListaImprimir(l, "output.txt", (tipoFuncionImprimirDato) estudianteImprimir);
}

int main (void) {
	funciones_auxiliares();
	funciones_estudiante();
	funciones_nodo();
	funciones_lista();
	funciones_avanzadas();

	return 0;
}
