# delfosti_scriptbd
base de datos para tracking de pedido

Nombre de la base de datos sugerida: DelfostiTrackBD

Credenciales usadas en el proyecto:
usuario: sa
Clabe: Defolsti01

se tienen las siguientes tablas

rol
puesto
usuario
estado_pedido
tipo_producto
unidad_medida
producto
pedido
detalle_pedido
token_usuario
log_errores



Se recomienda crear las tablas en el orden indicado en el presente archivo y el el script del proyecto, ya que las tablas con foreigns keys estan al final 
luego de las principales


Se tienen previamente cargada la informacion de las siguientes tablas para poder usar todas las opciones del sistema, como rol y puesto de usuarios
los esados del pedido, el tipo de producto y la unidad de medida que un producto puede tener

rol
puesto
estado_pedido
tipo_producto
unidad_medida

Para la prueba de la funcionalidad de la api, se ha cargado la informacion de algunos reparidores y vendedores, asi como tambien algunos productos de ejemplo
en las siguientes tablas
producto
usuario


se ha creado un objeto de tipo tabla DetallePedidoType basado en la tabla detalle de pedido, para poner la funcionalidad de creacion de pedido 


Se tienen los procedimientos almacenados para la funcionalidad de login, creacion de pedido y cambio de estado, para la creacion de pedido, se tiene un 
bloque try catch para el manejo de errores, ademas de usar una transaccion y rollback en caso de errores para asegurar la integridad de la informacion
