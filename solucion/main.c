#include "altaLista.h"
#include <stdio.h>

/** Funciones auxiliares **/
extern unsigned char string_longitud( char *s );
extern char *string_copiar( char *s );
extern bool string_menor( char *s1, char *s2 );

/** Funciones de estudiante **/
extern estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
extern void estudianteBorrar( estudiante *e );
extern bool menorEstudiante( estudiante *e1, estudiante *e2 );
extern void estudianteConFormato( estudiante *e, tipoFuncionModificarString f );
extern void estudianteImprimir( estudiante *e, FILE *file );

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

	estudiante* e = estudianteCrear("Ivan", "ASDF", 21);
	printf("%s, %d - %s  \n", e->nombre, e->edad, e->grupo);
	estudianteBorrar(e);

	bool b1 = string_menor("merced", "mercurio");
	bool b2 = string_menor("perro", "zorro");
	bool b3 = string_menor("senior", "seniora");
	bool b4 = string_menor("caZa", "casa");
	bool b5 = string_menor("hola", "hola");
	printf("%d, %d, %d, %d, %d\n", b1, b2, b3, b4, b5);

	return 0;
}
