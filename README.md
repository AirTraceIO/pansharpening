## Cómo pasar de una compra confirmada a una imagen pansharpened:

### Requisitos:
1. Se dispone de la id del pedido (order) que se confirmó para hacer la compra
2. La compra debe haberse completado (OrderStatus DONE)
3. Se debe haber descargado el archivo zip que contiene la compra

### Pasos:
1. Obtener la **delivery_id**:  
Cada pedido confirmado tiene una id de envío (delivery_id):
Usamos el siguiente endpoint para obtener las ids de envío asociadas a nuestro pedido. Sólo recibimos una:
https://docs.sentinel-hub.com/api/latest/reference/#tag/dataimport_delivery/operation/dataImport_getOrderDeliveries

> Alternativamente, el nombre del archivo zip descargado es la **delivery_id**

2. Obtener la **tile_id**:
Cada petición consiste en una *tile*, una *tile* es el conjunto de todas las bandas de una imagen, su información geográfica y sus metadatos (fecha, etc.).
Usamos el siguiente endpoint para obtener las tiles asociadas con un envío. De nuevo, sólo recibimos una:
https://docs.sentinel-hub.com/api/latest/reference/#tag/dataimport_tile_delivery/operation/dataImport_getTileDeliveries

3. Obtener la **fecha de imagen** de la tile:
En este endpoint, es el campo "sensingTime":
https://docs.sentinel-hub.com/api/latest/reference/#tag/byoc_tile/operation/getByocCollectionTileById

4. Crear una petición de SentinelHub dirigida a la tile objetivo:
Mediante el siguiente endpoint: https://docs.sentinel-hub.com/api/latest/reference/#tag/dataimport_delivery/operation/dataImport_getOrderDeliveries  
Se debe incluir en la petición:   
    1. El contenido de **evalscript.js** adjunto, pasado como una cadena en el campo "evalscript"
    2. La bounding box de la tile en el campo input.bounds 
    3. La id de la colección donde se encuentra la tile y la **fecha de imagen** previa en el campo input.data
    4. La resolución_x y la resolución_y, ambas puestas a 2 en el campo output.
    5. El formato de salida (TIFF) en el campo output  

    La petición responderá con el ***archivo TIFF*** de la tile.
    La imagen resultado sserá almacenada y referenciada a partir de ahora como SOURCE.TIF

5. Extraer las imágenes del archivo de compra:
El archivo de compra es un archivo zip dónde están almacenadas la imagen pancromática y multiespectral resultado de la compra.
Las imágenes son **el único archivo en formato .TIF** que se encuentra en la respectiva subcarpeta del archivo ZIP:  
    * {maxar_id}_MUL para la imagen multiespectral
    * {maxar_id}_PAN para la imagen pancromática

    dónde **maxar_id** es el prefijo del nombre de todos los archivos en el fichero .zip

6. Ejecutar el script de bash **otb.sh** adjunto:  
Las imágenes extraídas del fichero de compra serán referenciadas como:
    * PAN.TIF en el caso de la imagen pancromática
    * SUBJECT.TIF en el caso de la imagen multiespectral  
  


> En el paso 4 se obtiene la imagen SOURCE.TIF



* El script otb.sh recive 3 argumentos, correspondientes a los paths de las 3 imágenes creadas:  
    1. SOURCE_IMAGE_PATH 
    2. PAN_IMAGE_PATH 
    3. SUBJECT_IMAGE_PATH

    El script usa utilidades de otb para:  
    1. Obtener las medias de canales de la imagen SOURCE
    2. Obtener las medias de canales de la imagen SUBJECT
    3. Obtener los factores de calibración a partir e las medias computadas
    4. Calibrar la imagen SUBJECT para obtener una imagen multiespectral con colores calibrados
    5. Superponer la imagen multiespectral (resampling) para que alcance el tamaño de la pancromática
    6. Efectuar Pansharpening con esta imagen y la imagen PAN usando (por defecto) bayes, creando la imagen resultado PRODUCT.TIF
    7. Borrar las imágenes intermedias (No las iniciales [SOURCE, PAN, SUBJECT])

El resultado de ejecutar este script es la imagen PRODUCT.TIF, pansharpened, y con valores en el dominio uint16.

### Postprocesado

Para obtener una imagen presentable se deben normalizar los valores de pixel dividiendo entre 2047 o 1023.  
Dividir entre 1023 genera una imagen más brillante mientras que dividir entre 2047 genera una imagen con menor pérdida de información.

Una vez se han dividido los valores de pixel, se descartan todos los valores fuera del rango [0, 1], clipeando los valores de pixel a este dominio.

Si el visualizador requiere imágenes en uint8, simplemente se multiplican los valores por 255 y se truncan los decimales con floor.

---

_Última actualización: 04/03/2024_

Documento redactado por Antonio Ayllón Bermejo

