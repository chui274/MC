/*
 Copyright (C) Sofía Fernández Moreno
 Asignatura: Modelos de Computación
 Curso: 2015/2016
 */
			/*Sección de Declaraciones*/

%{
	#include "stdio.h"



// incluye la apertura del body
void escribir_header (FILE *fp);
// etiqueta holamundo
void escribir_hola (FILE *fp);

// etiqueta de cierre del body
void escribir_final (FILE *fp);

FILE *fp_salida = NULL;


int lineas = 0;


%}


numero [0-9]
todosLosNumeros {numero}+"."{numero}+|{numero}+

comando "auto"|"break"|"case"|"const"|"continue"|"default"|"do"|"else"|"if"|"else if"|"enum"|"extern"|"for"|"goto"|"register"|"return"|"signed"|"sizeof"|"static"|"typedef"|"union"|"unsigned"|"volatile"|"while"
tipodedato "char"|"int"|"long"|"short"|"float"|"double"|"void"
includes "#"[a-zA-Z]+
librerias "<"[a-z]+("."[a-zA-Z]+|"")">"

operadorBASICO ("+"|"-"|"*"|"/"|"%")|"="|("+"|"-"|"*"|"/"|"%")"="|"++"|"--"
comparadores "<"|">"|">="|"<="|"!="|"=="|"!"|"&&"|"||"
operador ">>"|">>="|"<<"|"<<="|"~"|"&"|"&="|"|"|"|="|"^"|"^="
operadorTERNARIO ":"|"?"
todosLosOperadores {operadorBASICO}|{comparadores}|{operador}|{operadorTERNARIO}

separadores "{"|"}"|"["|"]"|"("|")"|";"|","
variables ([a-zA-Z]|"_")([a-zA-Z0-9]|"_")*
funciontestA ({variables}" "*"(")|^({comando}" "*"(")
funciontest {variables}" "*"("
funciontestComando {comando}" "*"("
espacio "\\""\""|"\\""n"
otroscaracteres "."|" "|"'"|"#"|"?"|":"|"\\"|"@"

caracteres "'"({espacio}|[a-zA-Z0-9]|{otroscaracteres}|{separadores}|{todosLosOperadores}|{variables}|{comando}|{tipodedato}|{librerias}|{includes}|{todosLosNumeros})*"'"
strings "\""({espacio}|[a-zA-Z0-9]|{otroscaracteres}|{separadores}|{todosLosOperadores}|{variables}|{comando}|{tipodedato}|{librerias}|{includes}|{todosLosNumeros})*"\""
todasLasCadenas {strings}|{caracteres}

commentariobarra "//"+([a-zA-Z0-9]|({numero}|{comando}|{tipodedato}|{includes}|{librerias}|{operadorBASICO}|{comparadores}|{operador}|{operadorTERNARIO}|{todosLosOperadores}|{separadores}|{variables}|{todosLosNumeros}|{espacio}|{otroscaracteres}|{caracteres}|{strings}|{todasLasCadenas}|" "|[\t]))*
commentarioasterisco "/*"([^*]|\*+[^*/])*\*+"/"
comentarios {commentariobarra}|{commentarioasterisco}


%%

		/*----- Sección de Reglas ----------------*/ 

[\t] {
	// Prioridad a los tabuladores sobre todas las cosas
	fprintf(fp_salida,"&#09;");
	}
[\n] {
	// Después a los saltos de línea
	lineas++;
	fprintf(fp_salida,"<SPAN CLASS='numerodelinea'>%d</SPAN><br />", lineas);
	}

<<EOF>> {
	// Fin del archivo (Para leer y poner el ultimo numero de linea), nota, todos los numeros de linea usan CSS para acomodarse a la izquierda
	fprintf(fp_salida,"<SPAN CLASS='numerodelinea'>%d</SPAN><br />", ++lineas);
	yyterminate(); // Si no ponemos esto, creo un archivo sin fin
	// http://flex.sourceforge.net/manual/EOF.html#EOF
}

" "	{
	// Espacio HTML, salto de línea, es decir, para forzar espacios en blanco
		fprintf(fp_salida,"&nbsp;");
	}


{comentarios} {
	// Comentarios de una linea // /**/ y multilinea
	// Si el comentario es multilinea /**/ lo muestra todo en la misma linea dentro del SPAN
	fprintf(fp_salida,"<SPAN CLASS='comentario'>%s</SPAN>",yytext);
	}

{todosLosNumeros} {
	// Decimales y enteros
	fprintf(fp_salida,"<SPAN CLASS='numero'>%s</SPAN>",yytext);
	}


{comando} {
	// comando
	fprintf(fp_salida, "<SPAN CLASS='reservada'>%s</SPAN>", yytext );
	}

{funciontestComando} {
	// PRUEBA
	// NOTA: MAIN NO ES RESERVADA
	// http://crasseux.com/books/ctutorial/Reserved-words-in-C.html
	char * cadena_aux = strndup(yytext,strlen(yytext)-1);
	fprintf(fp_salida,"<SPAN CLASS='reservada'>%s</SPAN><SPAN CLASS='separador'>&nbsp;(</SPAN>",cadena_aux);
	free(cadena_aux); //Liberar memoria
	}
{funciontest} {
	// Similar a las librerías, en este caso detectamos lo que esté antes de un "(" y lo sustituimos explicitamente por un parentesis
	char * cadena_aux = strndup(yytext,strlen(yytext)-1);
	fprintf(fp_salida,"<SPAN CLASS='funcion'>%s</SPAN><SPAN CLASS='separador'>&nbsp;(</SPAN>",cadena_aux);
	free(cadena_aux); //Liberar memoria
	}
{tipodedato} {
	// Tipos de datos & sizeof()
	fprintf(fp_salida,"<SPAN CLASS='tipodedato'>%s</SPAN>",yytext);
	}

{todasLasCadenas} {
	// Cadenas
	fprintf(fp_salida,"<SPAN CLASS='cadena'>%s</SPAN>",yytext);
	}


{includes} {
	// Includes
	fprintf(fp_salida,"<SPAN CLASS='include'>%s</SPAN>",yytext);
	}
		
{librerias} {
	
	 	char * cadena_aux = strndup(yytext+1,strlen(yytext)-2);
		fprintf(fp_salida,"<SPAN CLASS='includecustom'>&lt;%s&gt;</SPAN>",cadena_aux);
		free(cadena_aux); //Liberar memoria
	}


{separadores} {
	// Separadores
	fprintf(fp_salida,"<SPAN CLASS='separador'>%s</SPAN>", yytext );
	}



{variables} {
	// Nombres de variables y nombres de funciones
	fprintf(fp_salida,"<SPAN CLASS='variable'>%s</SPAN>",yytext);
	}

{todosLosOperadores} {
	// Operadores
	fprintf(fp_salida,"<SPAN CLASS='operador'>%s</SPAN>", yytext ); 
	}


%%



/*----- Sección de Procedimientos ----------------*/ 

// incluye la apertura del body
void escribir_header (FILE *fp) {
    fprintf(fp, "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">");
    fprintf(fp, "\n<HTML>\n\t<HEAD>");
    fprintf(fp, "\n\t<META http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
    fprintf(fp, "\n\t<LINK href=\"colores.css\" rel=\"stylesheet\" type=\"text/css\">");
    fprintf(fp, "\n\t</HEAD>\n\t<BODY>");
}

// etiqueta holamundo
void escribir_hola (FILE *fp) {
    fprintf(fp, "\n\t\t<SPAN>Hola mundo!</SPAN>");
    
}


// etiqueta de cierre del body
void escribir_final (FILE *fp) {
    fprintf(fp, "\n\t</BODY>\n</HTML>");
    
}
int main (int nargs, char ** args) {

	//Para leer el nombre del archivo de entrada en la consola
	//Nota: *(args+1) es el primer argumento
	 if (nargs < 2) {
	 	printf("Error: faltan argumentos\n");
	 	return -1;
	 }

	FILE *fp;
	fp = fopen(*(args+1), "r"); //Usando un archivo leido desde la consola
	fp_salida = fopen("fichero.html", "w"); //El archivo de salida es fichero.html

	if (fp == NULL || fp_salida == NULL) {
		printf("\n*Error de archivos.\n\n");
		return -1;
	}


	escribir_header (fp_salida);	
	yyin = fp;
	yylex(); //Correr LEX
	escribir_final (fp_salida);	

	return 0;
}



