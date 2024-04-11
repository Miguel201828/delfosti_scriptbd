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

IF OBJECT_ID(N'dbo.detalle_pedido', N'U') IS NOT NULL  
   DROP TABLE [dbo].[detalle_pedido];  
GO
IF OBJECT_ID(N'dbo.pedido', N'U') IS NOT NULL  
   DROP TABLE [dbo].[pedido];  
GO
IF OBJECT_ID(N'dbo.producto', N'U') IS NOT NULL  
   DROP TABLE [dbo].[producto];  
GO
IF OBJECT_ID(N'dbo.unidad_medida', N'U') IS NOT NULL  
   DROP TABLE [dbo].[unidad_medida];  
GO
IF OBJECT_ID(N'dbo.tipo_producto', N'U') IS NOT NULL  
   DROP TABLE [dbo].[tipo_producto];  
GO
IF OBJECT_ID(N'dbo.estado_pedido', N'U') IS NOT NULL  
   DROP TABLE [dbo].[estado_pedido];  
GO
IF OBJECT_ID(N'dbo.usuario', N'U') IS NOT NULL  
   DROP TABLE [dbo].[usuario];  
GO
IF OBJECT_ID(N'dbo.puesto', N'U') IS NOT NULL  
   DROP TABLE [dbo].[puesto];  
GO
IF OBJECT_ID(N'dbo.rol', N'U') IS NOT NULL  
   DROP TABLE [dbo].[rol];  
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