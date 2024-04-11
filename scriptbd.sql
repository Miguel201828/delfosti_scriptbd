use [master]

DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'DelfostiTrackBD')
BEGIN
    SET @SQL = N'USE [DelfostiTrackBD];

                 ALTER DATABASE DelfostiTrackBD SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                 USE [master];

                 DROP DATABASE DelfostiTrackBD;';
    EXEC (@SQL);
END;

CREATE DATABASE [DelfostiTrackBD];
GO

USE [DelfostiTrackBD];
GO

create table rol(
codigo_rol varchar(20) not null
, descripcion varchar(100) not null
, CONSTRAINT PK_Rol PRIMARY KEY (codigo_rol)
);
GO

create table puesto(
codigo_puesto varchar(20) not null
, descripcion varchar(100) not null
, CONSTRAINT PK_Puesto PRIMARY KEY (codigo_puesto)
);
GO

create table usuario(
codigo_trabajador varchar(20) not null
, nombre varchar(100) not null
, correo varchar(100) not null
, clave varchar(100) not null
, telefono varchar(15) not null
, codigo_puesto varchar(20) not null
, codigo_rol varchar(20) not null 
, CONSTRAINT PK_Usuario PRIMARY KEY (codigo_trabajador)
, CONSTRAINT FK_UsuarioPuesto FOREIGN KEY (codigo_puesto) REFERENCES puesto(codigo_puesto)
, CONSTRAINT FK_UsuarioRol FOREIGN KEY (codigo_rol) REFERENCES rol(codigo_rol)
);
GO



create table estado_pedido(
id_estado int identity(1,1) not null
, descripcion varchar(100) not null
, CONSTRAINT PK_EstadoPedido PRIMARY KEY (id_estado)
);
GO

create table tipo_producto(
id_tipo_producto varchar(20) not null
, descripcion varchar(100) not null
, CONSTRAINT PK_TipoProducto PRIMARY KEY (id_tipo_producto)
);
GO

create table unidad_medida(
id_unidad_medida varchar(20) not null
, descripcion varchar(100) not null
, CONSTRAINT PK_UnidadMedida PRIMARY KEY (id_unidad_medida)
);
GO

create table producto(
sku varchar(10) not null
, nombre varchar(100) not null
, id_tipo_producto varchar(20) not null 
, etiquetas varchar(max) not null
, precio decimal(16,4) not null
, id_unidad_medida varchar(20) not null 
, CONSTRAINT PK_Producto PRIMARY KEY (sku)
, CONSTRAINT FK_ProdTipoProd FOREIGN KEY (id_tipo_producto) REFERENCES tipo_producto(id_tipo_producto)
, CONSTRAINT FK_ProdUndMed FOREIGN KEY (id_unidad_medida) REFERENCES unidad_medida(id_unidad_medida)
);
GO

create table pedido(
nro_pedido int identity(1,1) not null
, fecha_pedido datetime null
, fecha_recepcion datetime null
, fecha_despacho datetime null
, fecha_entrega datetime null
, codigo_vendedor varchar(20) not null 
, codigo_repartidor varchar(20) not null
, id_estado_pedido int not null
, total_pedido decimal(16,4) not null
, CONSTRAINT PK_Pedido PRIMARY KEY (nro_pedido)
, CONSTRAINT FK_PedVend FOREIGN KEY (codigo_vendedor) REFERENCES usuario(codigo_trabajador)
, CONSTRAINT FK_PedRepart FOREIGN KEY (codigo_repartidor) REFERENCES usuario(codigo_trabajador)
);
GO


create table detalle_pedido(
nro_pedido int not null
, nro_item int
, sku varchar(10) not null
, cantidad int not null
, precio_unitario decimal(16,4) not null
, total_detalle decimal(16,4) not null
, CONSTRAINT PK_DetallePedido PRIMARY KEY (nro_pedido,nro_item)
, CONSTRAINT FK_DetPedPed FOREIGN KEY (nro_pedido) REFERENCES pedido(nro_pedido)
, CONSTRAINT FK_DetPedProd FOREIGN KEY (sku) REFERENCES producto(sku)
);
GO


CREATE TYPE DetallePedidoType AS TABLE
( nro_item int
, sku varchar(10)
, cantidad int
, precio_unitario decimal(16,4) 
, total_detalle decimal(16,4)
);
GO

CREATE TABLE token_usuario(
id_token INT IDENTITY(1,1) NOT NULL
, codigo_trabajador varchar(20) not null
, token_desc VARCHAR(max) NOT NULL

, CONSTRAINT PK_TokenUsr PRIMARY KEY (id_token)
, CONSTRAINT FK_ToknUsrUsr FOREIGN KEY (codigo_trabajador) REFERENCES usuario(codigo_trabajador)
);
GO

CREATE TABLE log_errores(
id_log INT IDENTITY(1,1)
, msje_error varchar(max) null
, data_json varchar(max) null
, nombre_proc varchar(max) null
, fecha_erros datetime DEFAULT GETDATE()

, CONSTRAINT PK_LogErrores PRIMARY KEY (id_log)
);
GO


--insertamos la data pre existente, como los estados de producto y algunos datos necesarios

insert into rol (codigo_rol, descripcion) values ('202404102055001','Encargado');
insert into rol (codigo_rol, descripcion) values ('202404102055002','Vendedor');
insert into rol (codigo_rol, descripcion) values ('202404102055003','Delivery');
insert into rol (codigo_rol, descripcion) values ('202404102055004','Repartidor');
go
insert into puesto (codigo_puesto, descripcion) values ('202404102056001','Supervisor');
insert into puesto (codigo_puesto, descripcion) values ('202404102056002','Ventas');
insert into puesto (codigo_puesto, descripcion) values ('202404102056003','Entregas');
insert into puesto (codigo_puesto, descripcion) values ('202404102056004','Repartidores');
go
insert into estado_pedido(descripcion) values('Por atender');
insert into estado_pedido(descripcion) values('En proceso');
insert into estado_pedido(descripcion) values('En delivery');
insert into estado_pedido(descripcion) values('Recibido');
go
insert into tipo_producto(id_tipo_producto, descripcion) values ('20240410210101','Botella');
insert into tipo_producto(id_tipo_producto, descripcion) values ('20240410210102','Frasco');
insert into tipo_producto(id_tipo_producto, descripcion) values ('20240410210103','Taper');
GO
insert into unidad_medida(id_unidad_medida, descripcion) values('20240410210201','Unidad');
insert into unidad_medida(id_unidad_medida, descripcion) values('20240410210202','Six Pack');
insert into unidad_medida(id_unidad_medida, descripcion) values('20240410210203','Docena');
GO
DECLARE @i INT = 1;

WHILE @i <= 50
BEGIN
    DECLARE @sku VARCHAR(10) = 'SKU' + CONVERT(VARCHAR(2), @i);
    DECLARE @nombre VARCHAR(100) = 'Producto ' + CONVERT(VARCHAR(2), @i);
    DECLARE @id_tipo_producto VARCHAR(20);
    DECLARE @id_unidad_medida VARCHAR(20);
    DECLARE @precio DECIMAL(16, 4);
    DECLARE @etiquetas VARCHAR(MAX) = 'Etiqueta' + CONVERT(VARCHAR(2), @i);

    SET @id_tipo_producto = (SELECT TOP 1 id_tipo_producto FROM tipo_producto ORDER BY NEWID());

    SET @id_unidad_medida = (SELECT TOP 1 id_unidad_medida FROM unidad_medida ORDER BY NEWID());

    SET @precio = ROUND(RAND() * 99 + 1, 4);

    INSERT INTO producto (sku, nombre, id_tipo_producto, etiquetas, precio, id_unidad_medida)
    VALUES (@sku, @nombre, @id_tipo_producto, @etiquetas, @precio, @id_unidad_medida);

    SET @i = @i + 1;
END;
GO

INSERT INTO usuario (codigo_trabajador, nombre, correo, telefono, codigo_puesto, codigo_rol, clave)
SELECT 
    'REP' + CONVERT(VARCHAR, RN) AS codigo_trabajador,
    'Repartidor' + CONVERT(VARCHAR, RN) AS nombre,
    'repartidor' + CONVERT(VARCHAR, RN) + '@empresa.com' AS correo,
    '123456789' AS telefono,
    '202404102056004' AS codigo_puesto, 
    '202404102055003' AS codigo_rol,
    'R3P' + CONVERT(VARCHAR, RN)
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RN
    FROM sys.objects
) AS T
WHERE RN <= 15;
GO

INSERT INTO usuario (codigo_trabajador, nombre, correo, telefono, codigo_puesto, codigo_rol, clave)
SELECT 
    'VEN' + CONVERT(VARCHAR, RN) AS codigo_trabajador,
    'Vendedor' + CONVERT(VARCHAR, RN) AS nombre,
    'vendedor' + CONVERT(VARCHAR, RN) + '@empresa.com' AS correo,
    '123456789' AS telefono,
    '202404102056002' AS codigo_puesto, 
    '202404102055002' AS codigo_rol ,
    'V3N' + CONVERT(VARCHAR, RN)
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RN
    FROM sys.objects
) AS T
WHERE RN <= 15;
GO




CREATE PROCEDURE sp_login @correo nvarchar(100), @clave nvarchar(100)
AS
SELECT us.codigo_trabajador, us.nombre, us.telefono, us.codigo_puesto, us.codigo_rol
    , P.descripcion as Puesto, R.descripcion as Rol
FROM usuario us 
    INNER JOIN rol R on us.codigo_rol = R.codigo_rol
    INNER JOIN puesto P on us.codigo_puesto = P.codigo_puesto
WHERE us.correo = @correo AND us.clave = @clave;
GO

CREATE PROCEDURE sp_Crear_Pedido @nro_pedido int, @fecha_pedido datetime, @codigo_vendedor varchar(20), @codigo_repartidor varchar(20)
    , @id_estado_pedido int, @total_pedido decimal(16,4), @ListaDetalle DetallePedidoType READONLY
AS
BEGIN  
    DECLARE @respuesta INT;
    BEGIN TRANSACTION;

    BEGIN TRY

        INSERT INTO pedido(nro_pedido, fecha_pedido, codigo_vendedor, codigo_repartidor, id_estado_pedido)
        values(@nro_pedido, @fecha_pedido, @codigo_vendedor, @codigo_repartidor, @id_estado_pedido);

        INSERT INTO detalle_pedido(nro_pedido, nro_item, sku, cantidad, precio_unitario, total_detalle)
        SELECT @nro_pedido, nro_item, sku, cantidad, precio_unitario, total_detalle 
        FROM @ListaDetalle;
        COMMIT;
        --set @respuesta = 'Pedido creado con éxito';
        set @respuesta = 1;
    END TRY  
    BEGIN CATCH 
        ROLLBACK;
        --agregnar un insert en tabla de errores para controlar los errores generados
        --set @respuesta = 'Error creando pedido, det: ' + ERROR_MESSAGE();
        INSERT INTO log_errores(msje_error, nombre_proc)
        VALUES(ERROR_MESSAGE(), 'sp_Crear_Pedido');

        set @respuesta = 0;
    END CATCH

    SELECT @respuesta;
END;
GO

CREATE PROCEDURE SP_CAMBIAR_ESTADO_PEDIDO @nro_pedido int, @fecha datetime, @id_estado_nuevo int
AS
BEGIN
    DECLARE @id_estado_actual INT, @respuesta varchar(max);
    select @id_estado_actual = id_estado_pedido FROM pedido where nro_pedido = @nro_pedido;
    set @respuesta = 'no es posible cambiar el estado, el nuevo estado es menor';
    IF @id_estado_nuevo > @id_estado_actual--puede cambiar de estado
    BEGIN
        IF @id_estado_nuevo = 2
        BEGIN
            UPDATE pedido SET fecha_recepcion = @fecha, id_estado_pedido = @id_estado_nuevo where nro_pedido = @nro_pedido;
        END
        IF @id_estado_nuevo = 3
        BEGIN
            UPDATE pedido SET fecha_despacho = @fecha, id_estado_pedido = @id_estado_nuevo where nro_pedido = @nro_pedido;
        END
        IF @id_estado_nuevo = 4
        BEGIN
            UPDATE pedido SET fecha_entrega = @fecha, id_estado_pedido = @id_estado_nuevo where nro_pedido = @nro_pedido;
        END
        set @respuesta = 'Se cambió el estado del Pedido';
    END
    select @respuesta ;
END;
GO

CREATE PROCEDURE SP_GUARDAR_TOKEN_USUARIO @codigo_usuario varchar(20), @token_desc varchar(max)
AS
BEGIN
    DECLARE @cntToken INT = 0
    SELECT @cntToken = COUNT(1) FROM token_usuario WHERE CODIGO_TRABAJADOR = @codigo_usuario;
    IF @cntToken > 0
    
        UPDATE token_usuario SET token_desc = @token_desc WHERE CODIGO_TRABAJADOR = @codigo_usuario;
    ELSE
        INSERT INTO token_usuario(CODIGO_TRABAJADOR, token_desc) VALUES(@codigo_usuario, @token_desc);

    SELECT 'Se grabo el token para el usuario: ' + @codigo_usuario

END;
GO
CREATE PROCEDURE SP_VALIDAR_TOKEN_USER @codigo_usuario varchar(20), @token_desc varchar(max)
AS
BEGIN
    DECLARE @cntToken INT = 0
    SELECT @cntToken = COUNT(1) FROM token_usuario WHERE CODIGO_TRABAJADOR = @codigo_usuario and token_desc = @token_desc;
    IF @cntToken > 0
    
        SELECT 1
    ELSE
        SELECT 0

END;
GO