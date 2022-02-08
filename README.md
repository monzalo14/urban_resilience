# Resiliencia Urbana

## Extracción

Quickstart:
```
PYTHONPATH="." python urban_resilience/extraction/extract.py
```

## Modelado

Quickstart:
En la carpeta raíz del proyecto, ejecutar:
```
docker run -it --rm -v `pwd`/data/latest:/data -v `pwd`/models:/models -v `pwd`/output/:/output urban_resilience:latest
```

### Algunas notas

- Actualmente, el módulo de extracción está configurado para obtener fuentes de datos desde el [Portal de Datos Abiertos de la CDMX](https://datos.cdmx.gob.mx/).

- Las fuentes de datos se configuran mediante el archivo `urban_resilience/configs/sources.yaml`. Sólo necesitamos agregar un nombre para el conjunto de datos, su ID en el portal de CKAN y el formato en el que buscamos descargarlo, así como muestra el ejemplo.

- Los formatos actualmente soportados por la extracción son JSON y CSV. Decidí privilegiar JSON porque viene al menos con un diccionario de datos. La extracción ya toma un archivo JSON y lo transforma a CSV de forma automática, entonces no deberíamos tener problema.

- El módulo de extracción obtiene los datos, los guarda en un archivo temporal y luego versiona ese archivo temporal en dos carpetas: `versions` y `latest`. Esto lo hago con la finalidad de tener trazabilidad de datos en caso de que la fuente de origen se actualice, pero sin mucho problema se puede parametrizar eso para que no tengan mil copias de los mismos datos en carpetas por día.
