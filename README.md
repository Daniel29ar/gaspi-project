# gaspi-project
Aplicación construida con el siguiente comportamiento:
* Busqueda de productos mediante la digitacion de texto.
* Se tiene que almacenar las busquedas realizadas en memoria para que cuando el app se cierra y se vuelva a abrir estas se muestren por defecto o cuando el Search se encuente vacio.
* Consultar el API de walmart para poblar la tabla
    - https://axesso-walmart-data-service.p.rapidapi.com/wlm/walmart-search-by-keyword?keyword=[criterio]&page=[numeropagina]&sortBy=bestmatch
    - Considerando el header: x-rapidapi-key
* Se permite paginación al llegar al final de los elementos de la tabla
* Mediante el boton "Borrar" en la parte superior del app se puede eliminar las busquedas almacenadas en memoria.

IDE: Xcode 16.2
Swift Version: 6
iOS Version: 16.0 o superior
