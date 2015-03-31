
; ESTUDIANTE
	global estudianteCrear
	global estudianteBorrar
	global menorEstudiante
	global estudianteConFormato
	global estudianteImprimir

; ALTALISTA y NODO
	global nodoCrear
	global nodoBorrar
	global altaListaCrear
	global altaListaBorrar
	global altaListaImprimir

; AVANZADAS
	global edadMedia
	global insertarOrdenado
	global filtrarAltaLista

; AUXILIARES
	global string_longitud
	global string_copiar
	global string_menor
	global insertarAdelante

; YA IMPLEMENTADAS EN C
	extern string_iguales
	extern insertarAtras
	extern malloc
	extern free
	extern fprintf
	extern fopen
	extern fclose

; /** DEFINES **/
	%define NULL 	0
	%define TRUE 	1
	%define FALSE 	0

	%define ALTALISTA_SIZE     		16
	%define OFFSET_PRIMERO 			0
	%define OFFSET_ULTIMO  			8

	%define NODO_SIZE     			24
	%define OFFSET_SIGUIENTE   		0
	%define OFFSET_ANTERIOR   		8
	%define OFFSET_DATO 			16

	%define ESTUDIANTE_SIZE  		20
	%define OFFSET_NOMBRE 			0
	%define OFFSET_GRUPO  			8
	%define OFFSET_EDAD 			16

	%define OFFSET_CHAR 			1

section .rodata


section .data

	formato_estudiante_imprimir: DB "%s", 10, 9, "%s", 10, 9, "%d", 10, 0
	fopen_append: DB "a+", 0
	formato_lista_vacia: DB "<vacia>", 10, 0

section .text

;/** FUNCIONES OBLIGATORIAS DE ESTUDIANTE **/
;---------------------------------------------------------------------------------------------------------------

	; estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
	%define dir_nueva [rbp-8]
	%define nombre [rbp-16]
	%define edad [rbp-24]
	%define grupo [rbp-32]
	estudianteCrear:
		push rbp
		mov rbp, rsp
		sub rsp, 32
		; ****************
		mov nombre, QWORD rdi ; salvo los parametros antes de hacer la llamada a malloc
		mov grupo, QWORD rsi
		mov edad, rdx

		mov rdi, ESTUDIANTE_SIZE ; pido memoria para un nuevo estudiante_t
		call malloc
		mov dir_nueva, rax

		mov edi, DWORD edad
		mov [rax + OFFSET_EDAD], edi ; copio la edad

		mov rdi, QWORD nombre
		call string_copiar
		mov rdi, dir_nueva
		mov [rdi + OFFSET_NOMBRE], rax ; copio el nombre

		mov rdi, QWORD grupo
		call string_copiar
		mov rdi, dir_nueva
		mov [rdi + OFFSET_GRUPO], rax ; copio el grupo
		; ****************
		mov rax, dir_nueva
		add rsp, 32
		pop rbp
		ret

	; void estudianteBorrar( estudiante *e );
	%define dir_borrar [rbp-8]
	estudianteBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		; ****************
		mov dir_borrar, rdi ; guardo dir a borrar

		mov rdi, [rdi + OFFSET_NOMBRE]
		call free ; libero la memoria que use para copiar el nombre

		mov rdi, dir_borrar
		mov rdi, [rdi + OFFSET_GRUPO]
		call free ; libero la memoria que use para copiar el grupo

		mov rdi, dir_borrar
		call free ; libero la memoria que use almacenar la estructura estudiante
		; ****************
		add rsp, 8
		pop rbp
		ret

	; bool menorEstudiante( estudiante *e1, estudiante *e2 ){
	%define e1 [rbp-8]
	%define e2 [rbp-16]
	menorEstudiante:
		push rbp
		mov rbp, rsp
		sub rsp, 16
		; ****************
		mov e1, rdi
		mov e2, rsi

		mov rdi, [rdi + OFFSET_NOMBRE]
		mov rsi, [rsi + OFFSET_NOMBRE]
		call string_menor

		cmp rax, TRUE
		je menorEstudiante_true ; e1.nombre < e2.nombre

		mov rdi, e1
		mov rsi, e2
		mov rdi, [rdi + OFFSET_NOMBRE]
		mov rsi, [rsi + OFFSET_NOMBRE]

		call string_iguales
		cmp rax, FALSE
		je  menorEstudiante_false ; e1.nombre > e2.nombre

		mov rdi, e1
		mov rsi, e2
		mov edi, [rdi + OFFSET_EDAD]
		mov esi, [rsi + OFFSET_EDAD]

		cmp edi, esi
		jg menorEstudiante_false ;  e1.nombre == e2.nombre y  e1.edad > e2.edad
	menorEstudiante_true:
		mov rax, QWORD TRUE
		jmp fin_menorEstudiante
	menorEstudiante_false:
		mov rax, QWORD FALSE
		; ****************
	fin_menorEstudiante:
		add rsp, 16
		pop rbp
		ret

	; void estudianteConFormato( estudiante *e, tipoFuncionModificarString f )
	%define e [rbp-8]
	%define f [rbp-16]
	estudianteConFormato:
		push rbp
		mov rbp, rsp
		sub rsp, 16
		; ****************
		mov e, rdi
		mov f, rsi

		mov rdi, [rdi + OFFSET_NOMBRE]
		call f

		mov rdi, e
		mov rdi, [rdi + OFFSET_GRUPO]
		call f
		; ****************
		add rsp, 16
		pop rbp
		ret

	; void estudianteImprimir( estudiante *e, FILE *file )
	%define e [rbp-8]
	%define file [rbp-16]
	estudianteImprimir:
		push rbp
		mov rbp, rsp
		sub rsp, 16
		; ****************
		mov e, rdi
		mov file, rsi

		;fprintf (file, formato_estudiante_imprimir, e.nombre, e.grupo, e.edad);
		mov rdi, file
		mov rsi, formato_estudiante_imprimir
		mov rdx, e
		mov rdx, [rdx + OFFSET_NOMBRE]
		mov rcx, e
		mov rcx, [rcx + OFFSET_GRUPO]
		mov r8, e
		mov eax, [r8 + OFFSET_EDAD]
		xor r8, r8
		mov r8, rax
		xor rax, rax ; en rax cantidad de floats a imprimir
		call fprintf
		; ****************
		add rsp, 16
		pop rbp
		ret

;/** FUNCIONES DE ALTALISTA Y NODO **/
;--------------------------------------------------------------------------------------------------------

	; nodo *nodoCrear( void *dato )
	%define dato [rbp-8]
	nodoCrear:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		; ****************
		mov dato, QWORD rdi ; salvo los parametros antes de hacer la llamada a malloc

		mov rdi, NODO_SIZE ; pido memoria para un nuevo nodo_t
		call malloc

		mov rdi, rax
		mov QWORD [rdi + OFFSET_SIGUIENTE], NULL ; NULL para *siguiente
		mov QWORD [rdi + OFFSET_ANTERIOR], NULL ; NULL para *anterior
		mov QWORD rcx, dato
		mov [rdi + OFFSET_DATO], rcx ; copio el puntero al dato
		; ****************
		add rsp, 8
		pop rbp
		ret

	; void nodoBorrar( nodo *n, tipoFuncionBorrarDato f )
	%define dir_borrar [rbp-8]
	nodoBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		; ****************
		mov dir_borrar, rdi ; guardo dir a borrar

		mov rdi, [rdi + OFFSET_DATO]
		call rsi ; libero la memoria que use para el dato

		mov rdi, dir_borrar
		call free ; libero la memoria que use almacenar la estructura nodo
		; ****************
		add rsp, 8
		pop rbp
		ret

	; altaLista *altaListaCrear( void )
	altaListaCrear:
		push rbp
		mov rbp, rsp
		; ****************
		mov rdi, ALTALISTA_SIZE ; pido memoria para un nuevo nodo_t
		call malloc

		mov rdi, rax
		mov QWORD [rdi + OFFSET_PRIMERO], NULL ; NULL para *primero
		mov QWORD [rdi + OFFSET_ULTIMO], NULL ; NULL para *ultimo
		; ****************
		pop rbp
		ret

	; void altaListaBorrar( altaLista *l, tipoFuncionBorrarDato f )
	%define dir_lista [rbp-8]
	%define nodo_actual [rbp-16]
	%define f_borrar [rbp-24]
	altaListaBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 24
		; ****************
		mov dir_lista, rdi ; guardo la dir de la lista
		mov rdi, [rdi + OFFSET_PRIMERO]
		mov nodo_actual, rdi ; guardo el primer nodo de la lista
		mov f_borrar, rsi ; guardo funcion para imprimir dato

		mov rdi, nodo_actual
		cmp rdi, NULL; verifico si la lista esta vacia
		je altaListaBorrar_fin

	altaListaBorrar_ciclo: ; rdi esta en nodo_actual
		mov rdi, [rdi + OFFSET_DATO]
		call f_borrar ; borro el dato

		mov rsi, nodo_actual
		mov rdi, nodo_actual
		mov rsi, [rsi + OFFSET_SIGUIENTE] ; me guardo el puntero al siguiente nodo
		mov nodo_actual, rsi

		call free ; borro el nodo

		mov rdi, nodo_actual
		cmp rdi, NULL; verifico si llegamos al final de la lista
		je altaListaBorrar_fin
		jmp altaListaBorrar_ciclo

	altaListaBorrar_fin:
		mov rdi, dir_lista
		call free ; borro la lista
		; ****************
		add rsp, 24
		pop rbp
		ret

	; void altaListaImprimir( altaLista *l, char *archivo, tipoFuncionImprimirDato f )
	%define nodo_actual [rbp-8]
	%define file [rbp-16]
	%define f_imprimir [rbp-24]
	altaListaImprimir:
		push rbp
		mov rbp, rsp
		sub rsp, 24
		; ****************
		mov rdi, [rdi + OFFSET_PRIMERO]
		mov nodo_actual, rdi ; guardo el primer nodo de la lista
		mov f_imprimir, rdx ; guardo funcion para imprimir dato

		mov rdi, rsi
		mov rsi, fopen_append
		call fopen
		mov file, rax ; guardo puntero a file

		mov rdi, nodo_actual
		cmp rdi, NULL; verifico si la lista esta vacia
		je altaListaImprimir_vacia

	altaListaImprimir_ciclo: ; rdi esta en nodo_actual
		mov rdi, [rdi + OFFSET_DATO]
		mov rsi, file
		call f_imprimir

		mov rdi, nodo_actual
		mov rdi, [rdi + OFFSET_SIGUIENTE]
		cmp rdi, NULL; verifico si llegamos al final de la lista
		je altaListaImprimir_fin
		mov nodo_actual, rdi
		jmp altaListaImprimir_ciclo
	altaListaImprimir_vacia:
		xor rax, rax ; en rax cantidad de floats a imprimir
		mov rdi, file
		mov rsi, formato_lista_vacia
		call fprintf
		; ****************
	altaListaImprimir_fin:
		mov rdi, file
		call fclose ; cierro el archivo
		add rsp, 24
		pop rbp
		ret


;/** FUNCIONES AVANZADAS **/
;----------------------------------------------------------------------------------------------

	; float edadMedia( altaLista *l )
	%define last_nodo_aux [rbp-8]
	edadMedia:
		push rbp
		mov rbp, rsp
		sub rsp, 24
		; ****************
		mov rdi, [rdi + OFFSET_PRIMERO] ; puntero al primer nodo
		xor rax, rax ; limpio rax para usarlo como sumador
		xor rcx, rcx ; limpio rcx para usarlo como contador

		cmp rdi, NULL
		je edadMedia_vacia
	edadMedia_ciclo:
		cmp rdi, NULL
		je edadMedia_promedio

		mov rsi, rdi
		mov rsi, [rsi + OFFSET_DATO]
		mov esi, [rsi + OFFSET_EDAD]
		add eax, esi
		add rcx, QWORD 1

		mov rdi, [rdi + OFFSET_SIGUIENTE]
		jmp edadMedia_ciclo
	edadMedia_promedio:
		movq xmm0, rax
		movq xmm1, rcx
		divss xmm0, xmm1 ; rax / rcx
		jmp edadMedia_fin
	edadMedia_vacia:
		xor rax, rax
		movq xmm0, rax  ; return 0 if list if empty
		; ****************
	edadMedia_fin:
		add rsp, 24
		pop rbp
		ret

	; void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f )
	%define dir_lista [rbp-8]
	%define dato [rbp-16]
	%define f_comparar [rbp-24]
	%define last_nodo_aux [rbp-32]
	insertarOrdenado:
		push rbp
		mov rbp, rsp
		sub rsp, 32
		; ****************
		mov dir_lista, rdi
		mov dato, rsi
		mov f_comparar, rdx

		mov rdi, dir_lista
		mov rdi, [rdi + OFFSET_PRIMERO] ; puntero al primer nodo
		cmp rdi, NULL
		je insertarOrdenado_al_final ; l->primero == NULL
		; l->primero != NULL
		mov last_nodo_aux, rdi
		; empezamos en l->principio
		; y avanzamos hasta que last == NULL o f_comparar(last->dato, dato) == FALSE
	insertarOrdenado_ciclo:
		cmp QWORD last_nodo_aux, NULL; last == NULL ?
		je insertarOrdenado_fin_ciclo
		mov rdi, last_nodo_aux
		mov rdi, [rdi + OFFSET_DATO] ; rdi = last_nodo_aux->dato
		mov rsi, dato
		call f_comparar; f_comparar(last->dato, dato) == FALSE ?
		cmp rax, FALSE
		je insertarOrdenado_fin_ciclo
		; si llegamos aca, todavia tenemos que seguir avanzando
		mov rdi, last_nodo_aux
		mov rdi, [rdi + OFFSET_SIGUIENTE]
		mov last_nodo_aux, rdi; last_nodo_aux = last_nodo_aux->siguiente
		jmp insertarOrdenado_ciclo
	insertarOrdenado_fin_ciclo:
		cmp QWORD last_nodo_aux, NULL ; last == NULL ?
		je insertarOrdenado_al_final ; entonces llegamos al final de la lista
		mov rsi, last_nodo_aux
		cmp QWORD [rsi + OFFSET_ANTERIOR], NULL ; last->anterior == NULL ?
		je insertarOrdenado_al_principio ; entonces tenemos que insertar al principio
		jmp insertarOrdenado_al_medio ; sino no pasa nada de esto, hay que insertar en el medio
	insertarOrdenado_al_final:
		mov rdi, dir_lista
		mov rsi, dato
		call insertarAtras
		jmp insertarOrdenado_fin
	insertarOrdenado_al_principio:
		mov rdi, dir_lista
		mov rsi, dato
		call insertarAdelante
		jmp insertarOrdenado_fin
	insertarOrdenado_al_medio:
		mov rdi, dato
		call nodoCrear ; creo un nuevo nodo con el dato
		mov rdi, last_nodo_aux
		; arreglo hacia atras
		mov rsi, [rdi + OFFSET_ANTERIOR] ; rsi: last->anterior
		mov [rsi + OFFSET_SIGUIENTE], rax ; rsi->siguiente = nuevo
		mov [rax + OFFSET_ANTERIOR], rsi ; nuevo->anterior = rsi
		; arreglo hacia adelante
		mov [rdi + OFFSET_ANTERIOR], rax ; last->anterior = nuevo
		mov [rax + OFFSET_SIGUIENTE], rdi ; nuevo->anterior = rsi
		; ****************
	insertarOrdenado_fin:
		add rsp, 32
		pop rbp
		ret

	; void filtrarAltaLista( altaLista *l, tipoFuncionCompararDato f, void *datoCmp )
	%define dir_lista [rbp-8]
	%define dato_comparar [rbp-16]
	%define f_comparar [rbp-24]
	%define last_nodo_aux [rbp-32]
	filtrarAltaLista:
		push rbp
		mov rbp, rsp
		sub rsp, 32
		; ****************
		mov dir_lista, rdi
		mov f_comparar, rsi
		mov dato_comparar, rdx

		mov rdi, dir_lista
		mov rdi, [rdi + OFFSET_PRIMERO] ; puntero al primer nodo
		cmp QWORD rdi, NULL
		je filtrarAltaLista_fin ; la lista esta vacia, no hay nada que filtrar

		mov last_nodo_aux, rdi
		; empezamos en l->principio
		; y avanzamos hasta que last == NULL
	filtrarAltaLista_ciclo:
		cmp QWORD last_nodo_aux, NULL; last == NULL ?
		je filtrarAltaLista_fin

		mov rdi, last_nodo_aux
		mov rdi, [rdi + OFFSET_DATO] ; rdi = last_nodo_aux->dato
		mov rsi, dato_comparar
		call f_comparar; f_comparar(last->dato, dato) == TRUE ?
		cmp rax, TRUE ; si da TRUE, lo dejamos como esta y avanzamos
		je filtrarAltaLista_ciclo_avanzar

		mov rdi, last_nodo_aux
		mov rdx, [rdi + OFFSET_ANTERIOR]
		mov rcx, [rdi + OFFSET_SIGUIENTE]

		cmp rdx, NULL
		je actual_es_primer_elemento_en_lista
		cmp rcx, NULL
		je actual_es_ultimo_elemento_en_lista

		mov [rdx + OFFSET_SIGUIENTE], rcx
		mov [rcx + OFFSET_ANTERIOR], rdx
		jmp borrar_actual
	actual_es_ultimo_elemento_en_lista:
		mov r8, dir_lista
		mov [r8 + OFFSET_ULTIMO], rdx
		mov QWORD [rdx + OFFSET_SIGUIENTE], NULL
		jmp borrar_actual
	actual_es_primer_elemento_en_lista:
		cmp rcx, NULL
		je actual_es_unico_elemento_en_lista
		mov r8, dir_lista
		mov [r8 + OFFSET_PRIMERO], rcx
		mov QWORD [rcx + OFFSET_ANTERIOR], NULL
		jmp borrar_actual
	actual_es_unico_elemento_en_lista:
		mov r8, dir_lista
		mov QWORD [r8 + OFFSET_PRIMERO], NULL
		mov QWORD [r8 + OFFSET_ULTIMO], NULL
	borrar_actual:
		mov rdi, last_nodo_aux
		mov last_nodo_aux, rcx
		mov rsi, estudianteBorrar
		call nodoBorrar
		jmp filtrarAltaLista_ciclo
	filtrarAltaLista_ciclo_avanzar:
		mov rdi, last_nodo_aux
		mov rdi, [rdi + OFFSET_SIGUIENTE]
		mov last_nodo_aux, rdi; last_nodo_aux = last_nodo_aux->siguiente
		jmp filtrarAltaLista_ciclo
		; ****************
	filtrarAltaLista_fin:
		add rsp, 32
		pop rbp
		ret

	;/** FUNCIONES AUXILIARES **/
;----------------------------------------------------------------------------------------------

	; unsigned char string_longitud( char *s )
	string_longitud:
		push rbp
		mov rbp, rsp
		; ****************
		xor rax, rax ; limpio rax
	ciclo_string_longitud:
		cmp BYTE [rdi], 0x0 ; verifico si ya termino el string o no
		je fin_string_longitud ; si termino, voy al fin
		add al, 1 ; incremento el contados. Uso AL porque la longitud de s puede ser a lo sumo de 1 Byte
		add rdi, OFFSET_CHAR ; paso al siguiente char del string
		jmp ciclo_string_longitud
		; ****************
	fin_string_longitud:
		add al, 1 ; incremento en 1 para tener en cuenta la terminacion en NULL
		pop rbp
		ret

	; char *string_copiar( char *s )
	%define dir_nueva [rbp-8]
	%define dir_orig [rbp-16]
	%define len [rbp-24]
	string_copiar:
		push rbp
		mov rbp, rsp
		sub rsp, 24
		; ****************
		mov dir_orig, rdi ; dir_orig <- &s
		call string_longitud ; al <- len(s)
		mov BYTE len, al ; len <- len(s)

		mov rdi, rax ; pido len(s) bytes
		call malloc ; give me some mem ! (1 byte para cada char en s)
		mov dir_nueva, rax

		xor rcx, rcx ; limpio rcx porque lo voy a usar para indexar el string; i <- 0

	ciclo_string_copiar:
		cmp BYTE cl, len ; mientras i < len(s)
		je fin_string_copiar

		mov rdi, dir_orig
		add di, cx ; rdi <- *s + i

		mov rax, dir_nueva
		add al, cl ; rax <- *nueva + i

		mov dl, BYTE [rdi]
		mov BYTE [rax], dl ; copio un char

		add BYTE cl, OFFSET_CHAR ; incremento i en 1

		jmp ciclo_string_copiar
		; ****************
	fin_string_copiar:
		mov rax, dir_nueva
		add rsp, 24
		pop rbp
		ret

	; bool string_menor( char *s1, char *s2 )
	string_menor:
		push rbp
		mov rbp, rsp
		; ****************
		xor rax, rax ; limpio rax
	ciclo_string_menor:
		cmp BYTE [rsi], 0x0 ; verifico si termino s2
		je string_menor_false ; si termino, voy al fin
		cmp BYTE [rdi], 0x0 ; verifico si termino s1
		je string_menor_true ; si termino, voy al fin

		mov cl, BYTE [rsi]
		cmp BYTE [rdi], cl
		jl string_menor_true ; s1[i] > s2[i]
		jg string_menor_false ; s1[i] < s2[i]

		add al, 1 ; incremento el contados. Uso AL porque la longitud de s puede ser a lo sumo de 1 Byte
		add rdi, OFFSET_CHAR ; paso al siguiente char del string
		add rsi, OFFSET_CHAR ; paso al siguiente char del string
		jmp ciclo_string_menor

	string_menor_true:
		mov rax, QWORD TRUE
		jmp fin_string_menor
	string_menor_false:
		mov rax, QWORD FALSE
		; ****************
	fin_string_menor:
		pop rbp
		ret

	; void insertarAdelante( altaLista *l, void *dato )
	%define dir_lista [rbp-8]
	insertarAdelante:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		; ****************
		mov dir_lista, rdi

		mov rdi, rsi
		call nodoCrear ; deja en rax la dir del nuevo nodo

		mov rdi, dir_lista
		mov rdi, [rdi + OFFSET_PRIMERO] ; puntero al primer nodo
		cmp rdi, NULL
		je insertarAdelante_vacia ; l->primero == NULL
		jmp insertarAdelante_no_vacia ; l->primero != NULL
	insertarAdelante_vacia:
		mov rdi, dir_lista
		mov [rdi + OFFSET_ULTIMO], rax ; l->ultimo = nuevoNodo;
		jmp insertarAdelante_fin
	insertarAdelante_no_vacia:
		mov [rax + OFFSET_SIGUIENTE], rdi ; (nuevoNodo)->siguiente = l->primero;
		mov [rdi + OFFSET_ANTERIOR], rax ; (l->primero)->anterior = nuevoNodo;
	insertarAdelante_fin:
		mov rdi, dir_lista
		mov [rdi + OFFSET_PRIMERO], rax ; l->primero = nuevoNodo
		; ****************
		add rsp, 8
		pop rbp
		ret
