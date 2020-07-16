# Book-Crossing | MDP (2020-1)
> Grupo 20
> - Sebastián Aguilera
> - Bryan Ortiz
> - Cinthya Robles

> Análisis de los libros mejor valorados en la comunidad Book-Crossing (crawl hecho en 2004).

## Overview
> State what is the main goal of the project. State what sorts of question(s) you want to answer or what sort of system you want to build. (Questions may be non-technical -- e.g., is there a global correlation between coffee consumption and research output -- so long as they require data analysis or other technical solutions.)

El objetivo principal de este proyecto es crear un *script* en Apache Pig que permita obtener un ranking de autores, basados en el promedio de los ratings de sus libros, generando tuplas del estilo:

`position ## author ## <bestscoredbooks> ## bestscore ## average_score ## number_of_votes`

La posición en el ranking se decide primero por su `average_score` y, en caso de empate, por el `number_of_votes`. Sólo son considerados autores con más de 5 votos en total.

## Data
En este proyecto se trabajó con el [Book-Crossing Dataset](http://www2.informatik.uni-freiburg.de/~cziegler/BX/), de Institute für Informatik Freiburg. La razón de esta elección recae en que pareció interesante obtener algún top de libros o autores según su *rating* asignado. Cabe destacar que recién después de hacer el estudio, nos dimos cuenta que la data es muy antigua y por tanto desactualizada (pero la idea aplica a algún dataset más actual).

El dataset está compuesto por 3 relaciones:

1. **BX-Users (csv)**: Contiene a los usuarios, anonimizados y mapeados a llaves enteras, en (`User-ID`). También cuenta con los campos (`Location`, `Age`) si es que esta información fue proveída por el usuario, de otro modo, serán valores NULL. (278.859 records)

2. **BX-Books (csv)**: Los libros son identificados por su respectivo ISBN. Los ISBN inválidos fueron removidos del dataset. Adicionalmente, cada libro cuenta con (`Book-Title`, `Book-Author`, `Year-Of-Publication`, `Publisher`), obtenida desde Amazon Web Services (si la autoría es compartida, sólo se menciona uno de los autores). También se disponen URLs que referencian la portada del libro, apareciendo en 3 diferentes tamaños (`Image-URL-S`, `Image-URL-M`, `Image-URL-L`). (271.380 records)

3. **BX-Book-Ratings (csv)**: Contiene la información del *rating* del libro (`Book-Rating`). expresado en una escala de 1 a 10 (mayores valores denotan mejor evaluación). Algunos usuarios realizaron una evaluación implícita, representada por un 0. (1.149.780 records)

## Methods
> Detail the methods used during the project. Provide an overview of the techniques/technologies used, why you used them and how you used them. Refer to the source-code delivered with the project. Describe any problems you encountered.

Se utilizaron 3 principales herramientas para el flujo de procesamiento de datos:
- **Excel** para obtener una visualización rápida de con que contaba cada archivo.
- **Python** con la librería *Pandas* para el preprocesamiento de datos, los archivos venian en formato csv separados por ";" y columnas que no serían utilizadas (Como las URLs de **BX-Books**). Se eliminaron esas columnas, se cambiaron los separadores por *tabs* y los strings quedaron sin comillas.
- **PIG Latin** para el procesamiento de datos,  las principales operaciones fueron:
  1. Contar la cantidad de ratings y promedio de ratings de cada libro a a partir **BX-Books_Ratings**.  
    `book_id number_of_votes average_score`
  2. Generar una tabla a partir de **1** y **BX-Books**.  
    `book_id number_of_votes average_score author title year publisher`
  3. Obtener por autor: score maximo, promedio y suma de cantidad de votos a partir de **2**.  
    a: `author max_score` b: `author avergage_score` c: `author total_votes`
  4. Generar una tabla a aprtir de **3.a** y **BX-Books_Ratings** y concatenar los titulos con su año.  
    `book_id tittle_year publisher author max_score`
  5. Obtener una lista con los mejores libros de un autor a partir de **4**.  
    `author <bestscoredbooks>`
  6. A partir de **3** y **5** obtener lo propuesto sin ordenar.  
    `author ## <bestscoredbooks> ## bestscore ## average_score ## number_of_votes`
  7. Dado **6** Se ordena según el promedio de los scores y luego por cantidad de votos y se rankea.  
    `position ## author ## <bestscoredbooks> ## bestscore ## average_score ## number_of_votes`
  

## Results
> Detail the results of the project. Different projects will have different types of results; e.g., run-times or result sizes, evaluation of the methods you're comparing, the interface of the system you've built, and/or some of the results of the data analysis you conducted.

Después de procesar los datos con los métodos ya descritos se obtuvieron los siguientes resultados: el archivo final tiene una lista de 2183 autores, seguidos de una lista de sus libros y ordenados de acuerdo a las calificaciones de sus mejores libros. Los autores que lideran esta lista son Michiro Ueyema, Pamela E. Apkarian-Russel y Wataru Yoshizumi.

## Conclusion
> Summarise main lessons learnt. What was easy? What was difficult? What could have been done better or more efficiently?

El problema con los datos empleados es que los votos se concentran en muy pocos libros, es decir, gran parte de los votos (buenos o malos) va a los mismos títulos y autores, mientras que hay otros títulos y autores que tienen muy pocas valoraciones. Lo anterior indica que los resultados están sesgados por la popularidad de ciertos autores/títulos.


## Appendix
> You can use this for key code snippets that you don't want to clutter the main text.
