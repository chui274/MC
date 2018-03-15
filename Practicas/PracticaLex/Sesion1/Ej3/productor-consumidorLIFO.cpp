/*Ejercicio de SCD*/
/*Author: Sofía Fernández Moreno+*/
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <pthread.h> // Uso de hebras POSIX
#include <semaphore.h> // Uso de semáforos POSIX

using namespace std;

// Compilar con: g++ productor-consumidorLIFO.cpp -o productor-consumidorLIFO -lpthread


// Se usa una única variable entera no negativa
int primera_libre = 0; // índice en el vector de la primera celda libre (inicialmente 0). Se incrementa al escribir y decr. al leer.
const int num_items = 50;
const int tam_vec = 20;
int vector[tam_vec];

// Usar alguna/s variables adicionales que reflejen el estado de ocupación de dicho vector
// Estudiar si el acceso a dicha variable/s requiere o no requiere sincronización alguna entre el productor y el consumidor	

sem_t mutex,
	puede_producir,
	puede_consumir;

// Para producir un item de datos, la hebra productora invocará esta función
int producir_dato(){
	static int contador = 1;
	return contador++;
}

// Mientras que la hebra consumidora llama a esta otra para consumir un dato
void consumir_dato(int dato){
	sem_wait(&mutex);
	cout << "dato recibido: " << dato << endl;
	sem_post(&mutex);
}

void escribo_dato(int dato){
	sem_wait(&mutex);
	cout << "He escrito el dato " << dato << endl;
	sem_post(&mutex);
}

void * productor(void *){
	for (unsigned i=0; i<num_items; i++){
		int dato = producir_dato();
		sem_wait(&puede_producir);
		//Insertar dato en el vector
		vector[primera_libre] = dato;
		primera_libre++;
		escribo_dato(dato);
		sem_post(&puede_consumir);
		sem_wait(&mutex);
		cout << "Hay " << primera_libre << " entradas del vector ocupadas." << endl;
		cout << "Hay " << (tam_vec - primera_libre) << " entradas del vector libres." << endl; 
		sem_post(&mutex);
	}
	return NULL;
}

void * consumidor(void *){
	for (unsigned i=0; i<num_items; i++){
		int dato;
		sem_wait(&puede_consumir);
		primera_libre--;
		//Leer dato desde el vector intermedio
		dato = vector[primera_libre];
		consumir_dato(dato);
		sem_post(&puede_producir);
		sem_wait(&mutex);
		cout << "Hay " << primera_libre << " entradas del vector ocupadas." << endl;
		cout << "Hay " << (tam_vec - primera_libre) << " entradas del vector libres." << endl; 
		sem_post(&mutex);
	}
	return NULL;
}

int main(){
	// Creamos las hebras
	pthread_t hebra_productora, hebra_consumidora;
	
	// Inicializamos los semáforos
	sem_init(&mutex, 0, 1);
	sem_init(&puede_producir, 0, tam_vec);
	sem_init(&puede_consumir, 0, 0);
	
	// Inicializamos las hebras
	pthread_create(&hebra_productora, NULL, productor, NULL);
	pthread_create(&hebra_consumidora, NULL, consumidor, NULL);
	
	// Unimos las hebras
	pthread_join(hebra_productora, NULL);
	pthread_join(hebra_consumidora, NULL);
	
	cout << "Hebras terminadas. FIN" << endl;
	
	// Destruimos los semáforos
	sem_destroy(&mutex);
	sem_destroy(&puede_producir);
	sem_destroy(&puede_consumir);

}
