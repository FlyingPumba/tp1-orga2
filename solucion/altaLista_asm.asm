
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
	estudianteCrear:
		push rbp
		mov rbp, rsp
        push rbx
        push r12
        push r13
        push r14
		; ****************
		mov r12, rdi ; r12 <- *nombre
		mov r13, rsi ; r13 <- *grupo
		mov r14, rdx ; r14 <- edad
		mov rdi, ESTUDIANTE_SIZE
		call malloc  ; pido memoria para un nuevo estudiante
		mov rbx, rax ; rbx <- dir para el nuevo estudiante
		mov rdi, r14 ; rdi <- edad
		mov [rbx + OFFSET_EDAD], edi ; copio la edad a la nueva dir
		mov rdi, r12 ; rdi <- *nombre
		call string_copiar
		mov [rbx + OFFSET_NOMBRE], rax ; copio el nuevo *nombre a la nueva dir
		mov rdi, r13 ; rdi <- *grupo
		call string_copiar
		mov [rbx + OFFSET_GRUPO], rax ; copio el nuevo *grupo a la nueva dir
		; ****************
		mov rax, rbx
        pop r14
        pop r13
        pop r12
        pop rbx
		pop rbp
		ret

	; void estudianteBorrar( estudiante *e );
	estudianteBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 8
        push rbx
		; ****************
		mov rbx, rdi ; rbx <- *e
		mov rdi, [rdi + OFFSET_NOMBRE]
		call free ; libero la memoria que use para copiar el nombre
		mov rdi, [rbx + OFFSET_GRUPO]
		call free ; libero la memoria que use para copiar el grupo
		mov rdi, rbx
		call free ; libero la memoria que use almacenar la estructura estudiante
		; ****************
        pop rbx
		add rsp, 8
		pop rbp
		ret

	; bool menorEstudiante( estudiante *e1, estudiante *e2 )
	menorEstudiante:
		push rbp
		mov rbp, rsp
        push r12
        push r13
		; ****************
		mov r12, rdi ; r12 <- *e1
		mov r13, rsi ; r13 <- *e2
		mov rdi, [rdi + OFFSET_NOMBRE] ; rdi <- e1.nombre
		mov rsi, [rsi + OFFSET_NOMBRE] ; rsi <- e2.nombre
		call string_menor
		cmp rax, TRUE
		je menorEstudiante_true ; e1.nombre < e2.nombre
		mov rdi, [r12 + OFFSET_NOMBRE]
		mov rsi, [r13 + OFFSET_NOMBRE]
		call string_iguales
		cmp rax, FALSE
		je  menorEstudiante_false ; e1.nombre > e2.nombre
		mov edi, [r12 + OFFSET_EDAD]
		mov esi, [r13 + OFFSET_EDAD]
		cmp edi, esi
		jle menorEstudiante_true ;  e1.nombre == e2.nombre y  e1.edad <= e2.edad
		jmp menorEstudiante_false
	menorEstudiante_true:
		mov rax, QWORD TRUE
		jmp fin_menorEstudiante
	menorEstudiante_false:
		mov rax, QWORD FALSE
		; ****************
	fin_menorEstudiante:
        pop r13
        pop r12
		pop rbp
		ret

	; void estudianteConFormato( estudiante *e, tipoFuncionModificarString f )
	estudianteConFormato:
		push rbp
		mov rbp, rsp
        push rbx
        push r12
		; ****************
		mov rbx, rdi ; rbx <- *e
		mov r12, rsi ; r12 <- f
		mov rdi, [rdi + OFFSET_NOMBRE]
		call r12 ; modifico e.nombre llamando a f
		mov rdi, [rbx + OFFSET_GRUPO]
		call r12 ; modifico e.grupo llamando a g
		; ****************
        pop r12
        pop rbx
		pop rbp
		ret

	; void estudianteImprimir( estudiante *e, FILE *file )
	estudianteImprimir:
		push rbp
		mov rbp, rsp
        push rbx
        push r12
		; ****************
		mov rbx, rdi ; rbx <- *e
		mov r12, rsi ; r12 <- *file
		mov rdi, r12 ; empiezo a poner parametros para hacer llamada fprintf (file, formato_estudiante_imprimir, e.nombre, e.grupo, e.edad);
		mov rsi, formato_estudiante_imprimir
		mov rdx, [rbx + OFFSET_NOMBRE]
		mov rcx, [rbx + OFFSET_GRUPO]
		xor rax, rax
		mov eax, [rbx + OFFSET_EDAD]
		mov r8, rax
		xor rax, rax ; en rax cantidad de floats a imprimir
		call fprintf
		; ****************
        pop r12
        pop rbx
		pop rbp
		ret

;/** FUNCIONES DE ALTALISTA Y NODO **/
;--------------------------------------------------------------------------------------------------------

	; nodo *nodoCrear( void *dato )
	nodoCrear:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		push rbx
		; ****************
		mov rbx, rdi ; rbx <- *dato
		mov rdi, NODO_SIZE
		call malloc ; pido memoria para un nuevo nodo
		mov QWORD [rax + OFFSET_SIGUIENTE], NULL ; NULL para nodo.siguiente
		mov QWORD [rax + OFFSET_ANTERIOR], NULL ; NULL para nodo.anterior
		mov [rax + OFFSET_DATO], rbx ; copio el puntero al dato
		; ****************
		pop rbx
		add rsp, 8
		pop rbp
		ret

	; void nodoBorrar( nodo *n, tipoFuncionBorrarDato f )
	nodoBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 8
        push rbx
		; ****************
		mov rbx, rdi ; rbx <- *n
		mov rdi, [rdi + OFFSET_DATO]
		call rsi ; libero la memoria que use para el dato
		mov rdi, rbx
		call free ; libero la memoria que use almacenar la estructura nodo
		; ****************
        pop rbx
		add rsp, 8
		pop rbp
		ret

	; altaLista *altaListaCrear( void )
	altaListaCrear:
		push rbp
		mov rbp, rsp
		; ****************
		mov rdi, ALTALISTA_SIZE
		call malloc ; pido memoria para una nueva lista
		mov QWORD [rax + OFFSET_PRIMERO], NULL ; NULL para lista.primero
		mov QWORD [rax + OFFSET_ULTIMO], NULL ; NULL para lista.ultimo
		; ****************
		pop rbp
		ret

	; void altaListaBorrar( altaLista *l, tipoFuncionBorrarDato f )
	altaListaBorrar:
		push rbp
		mov rbp, rsp
		sub rsp, 8
        push rbx
        push r12
        push r13
		; ****************
		mov rbx, rdi ; rbx <- *l
		mov r12, [rdi + OFFSET_PRIMERO] ; r12 <- el primer nodo de la lista
		mov r13, rsi ; r13 <- funcion para imprimir dato
		cmp r12, NULL; verifico si la lista esta vacia
		je altaListaBorrar_fin
	altaListaBorrar_ciclo:
		mov rdi, [r12 + OFFSET_DATO]
		call r13 ; borro el dato
		mov rdi, r12
		mov r12, [r12 + OFFSET_SIGUIENTE] ; me guardo el puntero al siguiente nodo
		call free ; borro el nodo
		cmp r12, NULL; verifico si llegamos al final de la lista
		je altaListaBorrar_fin
		jmp altaListaBorrar_ciclo
	altaListaBorrar_fin:
		mov rdi, rbx
		call free ; borro la lista
		; ****************
        pop r13
        pop r12
        pop rbx
		add rsp, 8
		pop rbp
		ret

	; void altaListaImprimir( altaLista *l, char *archivo, tipoFuncionImprimirDato f )
	altaListaImprimir:
		push rbp
		mov rbp, rsp
		sub rsp, 8
		push rbx
		push r12
		push r13
		; ****************
		mov rbx, [rdi + OFFSET_PRIMERO] ; rbx <- el primer nodo de la lista
		mov r12, rdx ; r12 <- funcion para imprimir dato
		mov rdi, rsi ; rdi <- *archivo
		mov rsi, fopen_append ; rsi <- "a+" (append)
		call fopen ; abro el archivo
		mov r13, rax ; r13 <- *file
		cmp rbx, NULL; verifico si la lista esta vacia
		je altaListaImprimir_vacia
	altaListaImprimir_ciclo: ; rdi esta en nodo_actual
		mov rdi, [rbx + OFFSET_DATO] ; rdi <- nodo_actual.dato
		mov rsi, r13 ; rsi <- *file
		call r12 ; call f_imprimir
		cmp QWORD [rbx + OFFSET_SIGUIENTE], NULL; verifico si llegamos al final de la lista
		je altaListaImprimir_fin
		mov QWORD rbx, [rbx + OFFSET_SIGUIENTE] ; rbx <- nodo_actual.siguiente
		jmp altaListaImprimir_ciclo
	altaListaImprimir_vacia:
		xor rax, rax ; en rax cantidad de floats a imprimir
		mov rdi, r13 ; rdi <- *file
		mov rsi, formato_lista_vacia ; rsi <- "<vacia>"
		call fprintf
	altaListaImprimir_fin:
		mov rdi, r13 ; rdi <- *file
		call fclose ; cierro el archivo
		; ****************
		pop r13
        pop r12
        pop rbx
		add rsp, 8
		pop rbp
		ret

;/** FUNCIONES AVANZADAS **/
;----------------------------------------------------------------------------------------------

	; float edadMedia( altaLista *l )
	edadMedia:
		push rbp
		mov rbp, rsp
		; ****************
		mov rdi, [rdi + OFFSET_PRIMERO] ; puntero al primer nodo
		xor rax, rax ; limpio rax para usarlo como sumador
		xor rcx, rcx ; limpio rcx para usarlo como contador
		cmp rdi, NULL
		je edadMedia_vacia
	edadMedia_ciclo:
		cmp rdi, NULL
		je edadMedia_promedio
		mov rsi, [rdi + OFFSET_DATO]
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
		pop rbp
		ret

	; void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f )
	insertarOrdenado:
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		; ****************
		mov rbx, rdi ; rbx <- *l
		mov r12, rsi ; r12 <- *dato
		mov r13, rdx ; r13 <- f_comparar
		mov r14, [rbx + OFFSET_PRIMERO] ; r14 <- puntero al primer nodo
		cmp r14, NULL
		je insertarOrdenado_al_final ; l->primero == NULL
		; empezamos en l->principio
		; y avanzamos hasta que last == NULL o f_comparar(dato, last->dato) == TRUE
	insertarOrdenado_ciclo:
		cmp QWORD r14, NULL; last == NULL ?
		je insertarOrdenado_fin_ciclo
		mov rsi, [r14 + OFFSET_DATO] ; rdi <- last_nodo_aux.dato
		mov rdi, r12 ; rsi <- *dato
		call r13 ; call f_comparar
		cmp rax, TRUE ; f_comparar(dato, last->dato) == TRUE ?
		je insertarOrdenado_fin_ciclo
		; si llegamos aca, todavia tenemos que seguir avanzando
		mov r14, [r14 + OFFSET_SIGUIENTE] ; r14 <- last.siguiente
		jmp insertarOrdenado_ciclo
	insertarOrdenado_fin_ciclo:
		cmp QWORD r14, NULL ; last == NULL ?
		je insertarOrdenado_al_final ; entonces llegamos al final de la lista
		cmp QWORD [r14 + OFFSET_ANTERIOR], NULL ; last->anterior == NULL ?
		je insertarOrdenado_al_principio ; entonces tenemos que insertar al principio
		jmp insertarOrdenado_al_medio ; sino no pasa nada de esto, hay que insertar en el medio
	insertarOrdenado_al_final:
		mov rdi, rbx ; rdi <- *l
		mov rsi, r12 ; rsi <- *dato
		call insertarAtras
		jmp insertarOrdenado_fin
	insertarOrdenado_al_principio:
		mov rdi, rbx ; rdi <- *l
		mov rsi, r12 ; rsi <- *dato
		call insertarAdelante
		jmp insertarOrdenado_fin
	insertarOrdenado_al_medio:
		mov rdi, r12 ; rdi <- *dato
		call nodoCrear ; creo un nuevo nodo con el dato
		; arreglo hacia atras
		mov rsi, [r14 + OFFSET_ANTERIOR] ; rsi <- last.anterior
		mov [rsi + OFFSET_SIGUIENTE], rax ; rsi.siguiente <- nuevo
		mov [rax + OFFSET_ANTERIOR], rsi ; nuevo.anterior <- rsi
		; arreglo hacia adelante
		mov [r14 + OFFSET_ANTERIOR], rax ; last.anterior <- nuevo
		mov [rax + OFFSET_SIGUIENTE], r14 ; nuevo.anterior <- rsi
		; ****************
	insertarOrdenado_fin:
		pop r14
		pop r13
        pop r12
        pop rbx
		pop rbp
		ret

	; void filtrarAltaLista( altaLista *l, tipoFuncionCompararDato f, void *datoCmp )
	filtrarAltaLista:
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		; ****************
		mov rbx, rdi ; rbx <- *l
		mov r12, rdx ; r12 <- *dato
		mov r13, rsi ; r13 <- f_comparar
		mov r14, [rbx + OFFSET_PRIMERO] ; r14 <- puntero al primer nodo
		cmp QWORD r14, NULL
		je filtrarAltaLista_fin ; la lista esta vacia, no hay nada que filtrar
		; empezamos en l->principio
		; y avanzamos hasta que last == NULL
	filtrarAltaLista_ciclo:
		cmp QWORD r14, NULL; last == NULL ?
		je filtrarAltaLista_fin
		mov rdi, [r14 + OFFSET_DATO] ; rdi <- last_nodo_aux.dato
		mov rsi, r12 ; rsi <- *dato
		call r13; f_comparar(last->dato, dato) == TRUE ?
		cmp rax, TRUE ; si da TRUE, lo dejamos como esta y avanzamos
		je filtrarAltaLista_ciclo_avanzar
		mov rdx, [r14 + OFFSET_ANTERIOR]
		mov rcx, [r14 + OFFSET_SIGUIENTE]
		cmp rdx, NULL
		je actual_es_primer_elemento_en_lista
		cmp rcx, NULL
		je actual_es_ultimo_elemento_en_lista
		mov [rdx + OFFSET_SIGUIENTE], rcx ; actual.anterior.siguiente <- actual.siguiente
		mov [rcx + OFFSET_ANTERIOR], rdx ; actual.siguiente.anterior <- actual.anterior
		jmp borrar_actual
	actual_es_ultimo_elemento_en_lista:
		mov [rbx + OFFSET_ULTIMO], rdx ; lista.ultimo <- actual.anterior
		mov QWORD [rdx + OFFSET_SIGUIENTE], NULL ; actual.anterior.siguiente <- NULL
		jmp borrar_actual
	actual_es_primer_elemento_en_lista:
		cmp rcx, NULL
		je actual_es_unico_elemento_en_lista
		mov [rbx + OFFSET_PRIMERO], rcx ; lista.primero <- actual.siguiente
		mov QWORD [rcx + OFFSET_ANTERIOR], NULL ; actual.siguiente.anterior <- NULL
		jmp borrar_actual
	actual_es_unico_elemento_en_lista:
		mov QWORD [rbx + OFFSET_PRIMERO], NULL ; lista.primero <- NULL
		mov QWORD [rbx + OFFSET_ULTIMO], NULL ; lista.ultimo <- NULL
	borrar_actual:
		mov rdi, r14 ; rdi <- last
		mov r14, rcx ; r14 <- last.siguiente
		mov rsi, estudianteBorrar
		call nodoBorrar
		jmp filtrarAltaLista_ciclo
	filtrarAltaLista_ciclo_avanzar:
		mov r14, [r14 + OFFSET_SIGUIENTE] ; r14 <- actual.siguiente
		jmp filtrarAltaLista_ciclo
		; ****************
	filtrarAltaLista_fin:
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

	;/** FUNCIONES AUXILIARES **/
;----------------------------------------------------------------------------------------------

	; unsigned char string_longitud( char *s )
	string_longitud:
		push rbp
		mov rbp, rsp
		; ****************
		xor rax, rax ; limpio rax para usarlo como contador
	ciclo_string_longitud:
		cmp BYTE [rdi], 0x0 ; verifico si ya termino el string o no
		je fin_string_longitud ; si termino, voy al fin
		add al, 1 ; incremento el contador. Uso AL porque la longitud de s puede ser a lo sumo de 1 Byte
		add rdi, OFFSET_CHAR ; paso al siguiente char del string
		jmp ciclo_string_longitud
		; ****************
	fin_string_longitud:
		pop rbp
		ret

	; char *string_copiar( char *s )
	string_copiar:
		push rbp
		mov rbp, rsp
        sub rsp, 8
        push rbx
        push r12
        push r13
		; ****************
		mov rbx, rdi ; rbx <- *s
		call string_longitud ; rax <- len(s)
		add al, 1 ; incremento en 1 para tener en cuenta la terminacion en NULL
		mov r13, rax ; r13 <- len(s)
		mov rdi, rax ; pido len(s) bytes
		call malloc ; pido memoria para copiar el string (1 byte para cada char en s)
		mov r12, rax ; r12 <- nueva dir para el string
		xor rcx, rcx ; limpio rcx porque lo voy a usar para indexar el string; i <- 0
	ciclo_string_copiar:
		cmp rcx, r13 ; mientras i < len(s)
		je fin_string_copiar
		mov rdi, rbx
		add rdi, rcx ; rdi <- *s + i
		mov rax, r12
		add rax, rcx ; rax <- *nueva + i
		mov dl, BYTE [rdi]
		mov BYTE [rax], dl ; copio un char
		add BYTE cl, OFFSET_CHAR ; incremento i en 1
		jmp ciclo_string_copiar
	fin_string_copiar:
		; ****************
		mov rax, r12
        pop r13
        pop r12
        pop rbx
        add rsp, 8
		pop rbp
		ret

	; bool string_menor( char *s1, char *s2 )
	string_menor:
		push rbp
		mov rbp, rsp
		; ****************
		xor rax, rax ; limpio rax para usarlo como indice de los strings
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
	fin_string_menor:
		; ****************
		pop rbp
		ret

	; void insertarAdelante( altaLista *l, void *dato )
	insertarAdelante:
		push rbp
		mov rbp, rsp
		sub rsp, 8
        push rbx
		; ****************
		mov rbx, rdi ; rbx <- *lista
		mov rdi, rsi ; rdi <- *dato
		call nodoCrear ; deja en rax la dir del nuevo nodo
		cmp QWORD [rbx + OFFSET_PRIMERO], NULL ; lista.primero == NULL ?
		je insertarAdelante_vacia ; lista.primero == NULL
		jmp insertarAdelante_no_vacia ; lista.primero != NULL
	insertarAdelante_vacia:
		mov [rbx + OFFSET_ULTIMO], rax ; lista.ultimo <- nuevoNodo;
		jmp insertarAdelante_fin
	insertarAdelante_no_vacia:
		mov rdi, [rbx + OFFSET_PRIMERO] ; rdi <- lista.primero
		mov [rax + OFFSET_SIGUIENTE], rdi ; nuevoNodo.siguiente <- lista.primero
		mov [rdi + OFFSET_ANTERIOR], rax ; l.primero.anterior <- nuevoNodo;
	insertarAdelante_fin:
		mov [rbx + OFFSET_PRIMERO], rax ; lista.primero <- nuevoNodo
		; ****************
		pop rbx
		add rsp, 8
		pop rbp
		ret
