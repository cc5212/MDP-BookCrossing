# Proyecto MDP (2020-1)
> Grupo 20
> - Sebastián Aguilera
> - Bryan Ortiz
> - Cinthya Robles

En este proyecto se trabajará con el [Book-Crossing Dataset](http://www2.informatik.uni-freiburg.de/~cziegler/BX/), compuesto por 3 relaciones:
1. **BX-Users**: Contiene a los usuarios, anonimizados y mapeados a llaves enteras, en (`User-ID`). También cuenta con los campos (`Location`, `Age`) si es que esta información fue proveída por el usuario, de otro modo, serán valores NULL.

2. **BX-Books**: Los libros son identificados por su respectivo ISBN. Los ISBN inválidos fueron removidos del dataset. Adicionalmente, cada libro cuenta con (`Book-Title`, `Book-Author`, `Year-Of-Publication`, `Publisher`), obtenida desde Amazon Web Services (si la autoría es compartida, solo se menciona uno de los autores). También se disponen URLs que referencian la portada del libro, apareciendo en 3 diferentes tamaños (`Image-URL-S`, `Image-URL-M`, `Image-URL-L`).

3. **BX-Book-Ratings**: Contiene la información del *rating* del libro (`Book-Rating`) expresado en una escala de 1 a 10 (mayores valores denotan mejor evaluación). Algunos usuarios realizaron una evaluación implícita, representada por un 0.

El objetivo es crear un *script* en Apache Pig, que permita obtener el **top 100** de autores basados en el promedio de los ratings de sus libros, generando tuplas del estilo:

`position ## author ## <bestscoredbooks> ## bestscore ## average_score ## number_of_votes`

Añadiendo la posibilidad de separar este análisis por ubicación geográfica de ser posible.
