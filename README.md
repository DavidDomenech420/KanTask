# KanTask

Mi primer proyecto usando la tecnologia de Flutter y la base de datos Supabase.

La aplicacion esta compuesta por 3 pantallas diferentes (Login, Register y Home).

Al crear una cuenta aprovechamos las funciones que nos da supabase y hacemos dos funciones importantes:
1- Enviamos un correo para que nos confirmen que el correo introducido es del usuario y existe.
2- Desde Supabase creamos un trigger que detecte cuando se ha insertado un usuario nuevo y nos cree un tablero automaticamente que se llama Personal. Se hace desde Supabase para asi no tener que repetir codigo y funcione sin importar el metodo de registro.

Usamos el login utilizando el auth de supabase.

Una vez dentro de la aplicacion podemos añadir tableros nuevos, editar el nombre del que tenemos actualmente y añadir tareas nuevas.
Si solo tenemos un tablero el boton de eliminar esta desactivado para impedir que el usuario se quede sin tableros y puedan surgir errores en el programa.

Una vez se ha creado una tarea poder moverla por las columnas manteniendo pulsado y arrastrandola a la columna donde queremos que este. Podremos eliminar la tarea pulsando al boton de la basura y al pulsar en la tarea se podra editar.

Si eliminamos el tablero en el que estamos actualmente, se cambiara directamente al primer tablero que tengas.