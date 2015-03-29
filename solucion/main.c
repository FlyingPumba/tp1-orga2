#include "altaLista.h"
#include <stdio.h>

/** Funciones auxiliares **/
extern unsigned char string_longitud( char *s );
//extern char *string_copiar( char *s );

/** Funciones de estudiante **/
extern estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
extern void estudianteBorrar( estudiante *e );
extern bool menorEstudiante( estudiante *e1, estudiante *e2 );
extern void estudianteConFormato( estudiante *e, tipoFuncionModificarString f );
extern void estudianteImprimir( estudiante *e, FILE *file );

/*char *string_copiar( char *s ) {
	int n = string_longitud(s);
	char* nuevo = malloc(n);
	for (int i = 0; i < n; i++) {
		nuevo[i] = s[i];
	}
	return nuevo;
}*/

int main (void){
	// probando funciones auxiliares
	unsigned char a = string_longitud("abcd");
	unsigned char b = string_longitud("");
	printf("%d, %d\n", a, b);

	char *c = string_copiar("abcd");
	char *d = string_copiar("");
	printf("%s, %s\n", c, d);

	estudiante* e = estudianteCrear("Ivan", "ASDF", 21);
	return 0;
}
