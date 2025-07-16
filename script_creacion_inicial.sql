use GD1C2025
go

-- CREACION DEL SCHEMA MONGOOSE
CREATE SCHEMA MONGOOSE;
GO

-- Crea la tabla de estados posibles de un pedido 
CREATE TABLE MONGOOSE.EstadoPedido (
    Estado_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Estado_Descripcion NVARCHAR(255)
);
--Crea la tabla para las Provincias
CREATE TABLE MONGOOSE.Provincia (
    Provincia_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provincia_Nombre NVARCHAR(255)
);
--Crea la tabla para las localidades
CREATE TABLE MONGOOSE.Localidad (
    Localidad_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Localidad_Nombre NVARCHAR(255),
    
);

-- Crea la tabla para las sucursales
CREATE TABLE MONGOOSE.Sucursal (
    Sucursal_NroSucursal BIGINT PRIMARY KEY,
    Sucursal_Provincia BIGINT FOREIGN KEY REFERENCES MONGOOSE.Provincia(Provincia_Id),
    Sucursal_Localidad BIGINT FOREIGN KEY REFERENCES MONGOOSE.Localidad(Localidad_Id),
    Sucursal_Direccion NVARCHAR(255),
    Sucursal_Telefono NVARCHAR(255),
    Sucursal_Mail NVARCHAR(255)
);

-- Crea la tabla para los clientes
CREATE TABLE MONGOOSE.Cliente (
    Cliente_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Cliente_Dni BIGINT,
    Cliente_Nombre NVARCHAR(255),
    Cliente_Apellido NVARCHAR(255),
    Cliente_Mail NVARCHAR(255),
    Cliente_FechaNacimiento DATETIME2(6),
    Cliente_Direccion NVARCHAR(255),
    Cliente_Telefono NVARCHAR(255),
    Cliente_Provincia BIGINT FOREIGN KEY REFERENCES MONGOOSE.Provincia(Provincia_Id),
    Cliente_Localidad BIGINT FOREIGN KEY REFERENCES MONGOOSE.Localidad(Localidad_Id)
);

-- Crea la tabla para los proveedores
CREATE TABLE MONGOOSE.Proveedor (
    Proveedor_Cuit NVARCHAR(255) PRIMARY KEY,
    Proveedor_Provincia BIGINT FOREIGN KEY REFERENCES MONGOOSE.Provincia(Provincia_Id),
    Proveedor_Localidad BIGINT FOREIGN KEY REFERENCES MONGOOSE.Localidad(Localidad_Id),
    Proveedor_RazonSocial NVARCHAR(255),
    Proveedor_Direccion NVARCHAR(255),
    Proveedor_Telefono NVARCHAR(255),
    Proveedor_Mail NVARCHAR(255)
);

-- Crea la tabla para los Pedidos
CREATE TABLE MONGOOSE.Pedido (
    Pedido_Numero DECIMAL(18,0) PRIMARY KEY,
    Pedido_Fecha DATETIME2(6),
    Pedido_Estado BIGINT FOREIGN KEY REFERENCES MONGOOSE.EstadoPedido(Estado_Id),
    Pedido_Total DECIMAL(18,2),
    Pedido_Cliente BIGINT FOREIGN KEY REFERENCES MONGOOSE.Cliente(Cliente_Id),
    Pedido_Sucursal BIGINT FOREIGN KEY REFERENCES MONGOOSE.Sucursal(Sucursal_NroSucursal)
);
-- Crea la tabla para las cancelaciones de pedidos
CREATE TABLE MONGOOSE.Cancelacion (
    Cancelacion_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Cancelacion_Pedido DECIMAL(18,0) FOREIGN KEY REFERENCES MONGOOSE.Pedido(Pedido_Numero),
    Cancelacion_Fecha DATETIME2(6),
    Cancelacion_Motivo NVARCHAR(255)
);

--Crea la tabla para las facturas
CREATE TABLE MONGOOSE.Factura (
    Factura_Numero BIGINT PRIMARY KEY,
    Factura_Fecha DATETIME2(6),
    Factura_Total DECIMAL(38,2),
    Factura_Sucursal BIGINT FOREIGN KEY REFERENCES MONGOOSE.Sucursal(Sucursal_NroSucursal),
    Factura_Cliente BIGINT FOREIGN KEY REFERENCES MONGOOSE.Cliente(Cliente_Id)
);
--Crea la tabla para los detalles de las facturas
CREATE TABLE MONGOOSE.DetalleFactura (
	Detalle_Factura_Item BIGINT IDENTITY(1,1),
    Detalle_Factura_Pedido DECIMAL(18,0),
    Detalle_Factura_Numero BIGINT,
    Detalle_Factura_Precio DECIMAL(18,2),
    Detalle_Factura_Cantidad DECIMAL(18,0),
    Detalle_Factura_Subtotal DECIMAL(18,2),
    PRIMARY KEY (Detalle_Factura_Item,Detalle_Factura_Pedido, Detalle_Factura_Numero),
    FOREIGN KEY (Detalle_Factura_Pedido) REFERENCES MONGOOSE.Pedido(Pedido_Numero),
    FOREIGN KEY (Detalle_Factura_Numero) REFERENCES MONGOOSE.Factura(Factura_Numero)
);


--Crea la tabla para las compras
CREATE TABLE MONGOOSE.Compra (
    Compra_Numero DECIMAL(18,0) PRIMARY KEY,
    Compra_Fecha DATETIME2(6),
    Compra_Total DECIMAL(18,2),
    Compra_Sucursal BIGINT FOREIGN KEY REFERENCES MONGOOSE.Sucursal(Sucursal_NroSucursal),
    Compra_Proveedor NVARCHAR(255) FOREIGN KEY REFERENCES MONGOOSE.Proveedor(Proveedor_Cuit)
);
--Crea la tabla para los Materiales
CREATE TABLE MONGOOSE.Material (
    Material_Codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    Material_Tipo NVARCHAR(255),
    Material_Nombre NVARCHAR(255),
    Material_Descripcion NVARCHAR(255),
    Material_Precio DECIMAL(38,2)
);
-- Crea la tabla para los detalles de las compras
CREATE TABLE MONGOOSE.DetalleCompra (
    Detalle_Compra_Numero DECIMAL(18,0),
    Detalle_Compra_Material BIGINT,
    Detalle_Compra_Precio DECIMAL(18,2),
    Detalle_Compra_Cantidad DECIMAL(18,0),
    Detalle_Compra_Subtotal DECIMAL(18,2),
    PRIMARY KEY (Detalle_Compra_Numero, Detalle_Compra_Material),
    FOREIGN KEY (Detalle_Compra_Numero) REFERENCES MONGOOSE.Compra(Compra_Numero),
    FOREIGN KEY (Detalle_Compra_Material) REFERENCES MONGOOSE.Material(Material_Codigo)
);

-- Crea la tabla para las telas
CREATE TABLE MONGOOSE.Tela (
    Tela_Codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    Tela_Color NVARCHAR(255),
    Tela_Textura NVARCHAR(255),
	Mat_Codigo BIGINT,
    FOREIGN KEY (Mat_Codigo) REFERENCES MONGOOSE.Material(Material_Codigo)
);
--Crea la tabla para las maderas
CREATE TABLE MONGOOSE.Madera (
    Madera_Codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    Madera_Color NVARCHAR(255),
    Madera_Dureza NVARCHAR(255),
	Mat_Codigo BIGINT,
    FOREIGN KEY (Mat_Codigo) REFERENCES MONGOOSE.Material(Material_Codigo)
);
--Crea la tabla para los rellenos
CREATE TABLE MONGOOSE.Relleno (
    Relleno_Codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    Relleno_Densidad DECIMAL(38,2),
	Mat_Codigo BIGINT,
    FOREIGN KEY (Mat_Codigo) REFERENCES MONGOOSE.Material(Material_Codigo)
);

--Crea la tabla para los modelos de sillones
CREATE TABLE MONGOOSE.ModeloSillon (
    Modelo_Codigo BIGINT PRIMARY KEY,
    Modelo_Nombre NVARCHAR(255),
    Modelo_Descripcion NVARCHAR(255),
    Modelo_Precio DECIMAL(18,2)
);
-- Crea la tabla para las medidas de sillones
CREATE TABLE MONGOOSE.Medida (
    Medida_Codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    Medida_Alto DECIMAL(18,2),
    Medida_Ancho DECIMAL(18,2),
    Medida_Profundidad DECIMAL(18,2),
    Medida_Precio DECIMAL(18,2)
);

-- Crea la tabla para los sillones
CREATE TABLE MONGOOSE.Sillon (
    Sillon_Codigo BIGINT PRIMARY KEY,
    Sillon_Medida_Codigo BIGINT FOREIGN KEY REFERENCES MONGOOSE.Medida(Medida_Codigo),
    Sillon_Modelo_Codigo BIGINT FOREIGN KEY REFERENCES MONGOOSE.ModeloSillon(Modelo_Codigo)
);
-- Crea la tabla para los detalles de pedidos
CREATE TABLE MONGOOSE.DetallePedido (
    Detalle_Pedido_Numero DECIMAL(18,0),
    Detalle_Pedido_Sillon BIGINT,
    Detalle_Pedido_Cantidad BIGINT,
    Detalle_Pedido_Precio DECIMAL(18,2),
    Detalle_Pedido_Subtotal DECIMAL(18,2),
    PRIMARY KEY (Detalle_Pedido_Numero, Detalle_Pedido_Sillon),
    FOREIGN KEY (Detalle_Pedido_Numero) REFERENCES MONGOOSE.Pedido(Pedido_Numero),
    FOREIGN KEY (Detalle_Pedido_Sillon) REFERENCES MONGOOSE.Sillon(Sillon_Codigo)
);

-- Crea la tabla para relacionar el Material con el sillon
CREATE TABLE MONGOOSE.MaterialXSillon (
    Comp_Sillon BIGINT,
    Comp_Material BIGINT,
    PRIMARY KEY (Comp_Sillon, Comp_Material),
    FOREIGN KEY (Comp_Sillon) REFERENCES MONGOOSE.Sillon(Sillon_Codigo),
    FOREIGN KEY (Comp_Material) REFERENCES MONGOOSE.Material(Material_Codigo)
);

--Crea la tabla para los envios
CREATE TABLE MONGOOSE.Envio(
	Envio_Numero DECIMAL(18,2),
	Envio_Fecha_Programada DATETIME2(6),
	Envio_Fecha DATETIME2(6),
	Envio_ImporteTraslado DECIMAL(18,2),
	Envio_ImporteSubida DECIMAL(18,2),
	Envio_Total DECIMAL(18,2),
	Envio_Factura BIGINT,
	PRIMARY KEY(Envio_Numero),
	FOREIGN KEY (Envio_Factura) REFERENCES MONGOOSE.Factura(Factura_Numero)
);


--MIGRACION


-- ÍNDICES PARA ACCESO EFICIENTE
CREATE INDEX idx_cliente_dni ON MONGOOSE.Cliente(Cliente_Dni);
CREATE INDEX idx_proveedor_cuit ON MONGOOSE.Proveedor(Proveedor_Cuit);
CREATE INDEX idx_material_nombre ON MONGOOSE.Material(Material_Nombre);
CREATE INDEX idx_sucursal_nrosucursal ON MONGOOSE.Sucursal(Sucursal_NroSucursal);
CREATE INDEX idx_estado_descripcion ON MONGOOSE.EstadoPedido(Estado_Descripcion);
CREATE INDEX idx_factura_cliente ON MONGOOSE.Factura(Factura_Cliente);
GO
-- STORED PROCEDURES DE MIGRACIÓN
-- Store Procedure Para la migracion de los estados de pedidos
CREATE PROCEDURE MONGOOSE.sp_MigrarEstadoPedido AS
BEGIN
    INSERT INTO MONGOOSE.EstadoPedido (Estado_Descripcion)
    SELECT DISTINCT Pedido_Estado
    FROM gd_esquema.Maestra
    WHERE Pedido_Estado IS NOT NULL;
END;
GO
-- Insert Para agregar el estado Pendiente a la tabla de estados, ya que no lo contempla la tabla maestra.
INSERT INTO MONGOOSE.EstadoPedido (Estado_Descripcion)
VALUES ('Pendiente');
GO

-- Store Procedure Para la migracion de las provincias. Se trabaja con los Clientes, sucursales y proveedores ya que los 3 tienen Provincias.
CREATE PROCEDURE MONGOOSE.sp_MigrarProvincia AS
BEGIN
    INSERT INTO MONGOOSE.Provincia (Provincia_Nombre)
    SELECT DISTINCT Cliente_Provincia FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL
    UNION
    SELECT DISTINCT Sucursal_Provincia FROM gd_esquema.Maestra WHERE Sucursal_Provincia IS NOT NULL
    UNION
    SELECT DISTINCT Proveedor_Provincia FROM gd_esquema.Maestra WHERE Proveedor_Provincia IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de Localidades. Misma estrategia que las provincias.
CREATE PROCEDURE MONGOOSE.sp_MigrarLocalidad AS
BEGIN
    INSERT INTO MONGOOSE.Localidad (Localidad_Nombre)
    SELECT DISTINCT Cliente_Localidad FROM gd_esquema.Maestra WHERE Cliente_Localidad IS NOT NULL
    UNION
    SELECT DISTINCT Sucursal_Localidad FROM gd_esquema.Maestra WHERE Sucursal_Localidad IS NOT NULL
    UNION
    SELECT DISTINCT Proveedor_Localidad FROM gd_esquema.Maestra WHERE Proveedor_Localidad IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de Sucursales
CREATE PROCEDURE MONGOOSE.sp_MigrarSucursal AS
BEGIN
    INSERT INTO MONGOOSE.Sucursal (Sucursal_NroSucursal, Sucursal_Direccion, Sucursal_Telefono, Sucursal_Mail, Sucursal_Provincia, Sucursal_Localidad)
    SELECT DISTINCT
        m.Sucursal_NroSucursal,
        m.Sucursal_Direccion,
        m.Sucursal_Telefono,
        m.Sucursal_Mail,
        p.Provincia_Id,
        l.Localidad_Id
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Provincia p ON m.Sucursal_Provincia = p.Provincia_Nombre
    JOIN MONGOOSE.Localidad l ON m.Sucursal_Localidad = l.Localidad_Nombre
END;
GO

-- Store Procedure Para la migracion de Clientes
CREATE PROCEDURE MONGOOSE.sp_MigrarCliente AS
BEGIN
    INSERT INTO MONGOOSE.Cliente (Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Cliente_Mail, Cliente_FechaNacimiento, Cliente_Direccion, Cliente_Telefono, Cliente_Provincia, Cliente_Localidad)
    SELECT DISTINCT
        m.Cliente_Dni,
        m.Cliente_Nombre,
        m.Cliente_Apellido,
        m.Cliente_Mail,
        m.Cliente_FechaNacimiento,
        m.Cliente_Direccion,
        m.Cliente_Telefono,
        p.Provincia_Id,
        l.Localidad_Id
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Provincia p ON m.Cliente_Provincia = p.Provincia_Nombre
    JOIN MONGOOSE.Localidad l ON m.Cliente_Localidad = l.Localidad_Nombre
END;
GO
-- Store Procedure Para la migracion de Proveedores
CREATE PROCEDURE MONGOOSE.sp_MigrarProveedor AS
BEGIN
    INSERT INTO MONGOOSE.Proveedor (Proveedor_Cuit, Proveedor_RazonSocial, Proveedor_Direccion, Proveedor_Telefono, Proveedor_Mail, Proveedor_Provincia, Proveedor_Localidad)
    SELECT DISTINCT
        m.Proveedor_Cuit,
        m.Proveedor_RazonSocial,
        m.Proveedor_Direccion,
        m.Proveedor_Telefono,
        m.Proveedor_Mail,
        p.Provincia_Id,
        l.Localidad_Id
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Provincia p ON m.Proveedor_Provincia = p.Provincia_Nombre
    JOIN MONGOOSE.Localidad l ON m.Proveedor_Localidad = l.Localidad_Nombre
END;
GO

-- Ejecutar procedimientos de migración De Estados, provincias, Localidades, Sucursales, Clientes y Proveedor. Esto para que posteriormente se pueda hacer referencia
-- Con los joins a estas tablas sin que genere error.
EXEC MONGOOSE.sp_MigrarEstadoPedido;
EXEC MONGOOSE.sp_MigrarProvincia;
EXEC MONGOOSE.sp_MigrarLocalidad;
EXEC MONGOOSE.sp_MigrarSucursal;
EXEC MONGOOSE.sp_MigrarCliente;
EXEC MONGOOSE.sp_MigrarProveedor;
GO

-- Store Procedure Para la migracion del Modelo de sillones
CREATE PROCEDURE MONGOOSE.sp_MigrarModeloSillon AS
BEGIN
    INSERT INTO MONGOOSE.ModeloSillon (Modelo_Codigo, Modelo_Nombre, Modelo_Descripcion, Modelo_Precio)
    SELECT DISTINCT
        Sillon_Modelo_Codigo,
        Sillon_Modelo,
        Sillon_Modelo_Descripcion,
        Sillon_Modelo_Precio
    FROM gd_esquema.Maestra
    WHERE Sillon_Modelo_Codigo IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de Medidas de sillones
CREATE PROCEDURE MONGOOSE.sp_MigrarMedida AS
BEGIN
    INSERT INTO MONGOOSE.Medida (Medida_Alto, Medida_Ancho, Medida_Profundidad, Medida_Precio)
    SELECT DISTINCT
        Sillon_Medida_Alto,
        Sillon_Medida_Ancho,
        Sillon_Medida_Profundidad,
        Sillon_Medida_Precio
    FROM gd_esquema.Maestra
    WHERE Sillon_Medida_Alto IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de materiales
CREATE PROCEDURE MONGOOSE.sp_MigrarMaterial AS
BEGIN
    INSERT INTO MONGOOSE.Material (Material_Tipo, Material_Nombre, Material_Descripcion, Material_Precio)
    SELECT DISTINCT
        Material_Tipo,
        Material_Nombre,
        Material_Descripcion,
        Material_Precio
    FROM gd_esquema.Maestra
    WHERE Material_Nombre IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de telas
CREATE PROCEDURE MONGOOSE.sp_MigrarTela
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MONGOOSE.Tela (Tela_Color, Tela_Textura, Mat_Codigo)
    SELECT DISTINCT g.Tela_Color, g.Tela_Textura, m.Material_Codigo
    FROM gd_esquema.Maestra g
    JOIN MONGOOSE.Material m 
        ON g.Material_Nombre = m.Material_Nombre AND m.Material_Tipo = 'Tela'
    WHERE g.Tela_Color IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM MONGOOSE.Tela t WHERE t.Mat_Codigo = m.Material_Codigo
      );
END;
GO

-- Store Procedure Para la migracion de maderas
CREATE PROCEDURE MONGOOSE.sp_MigrarMadera
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MONGOOSE.Madera (Madera_Color, Madera_Dureza, Mat_Codigo)
    SELECT DISTINCT g.Madera_Color, g.Madera_Dureza, m.Material_Codigo
    FROM gd_esquema.Maestra g
    JOIN MONGOOSE.Material m 
        ON g.Material_Nombre = m.Material_Nombre AND m.Material_Tipo = 'Madera'
    WHERE g.Madera_Color IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM MONGOOSE.Madera ma WHERE ma.Mat_Codigo = m.Material_Codigo
      );
END;
GO

-- Store Procedure Para la migracion de rellenos
CREATE PROCEDURE MONGOOSE.sp_MigrarRelleno
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MONGOOSE.Relleno (Relleno_Densidad, Mat_Codigo)
    SELECT DISTINCT g.Relleno_Densidad, m.Material_Codigo
    FROM gd_esquema.Maestra g
    JOIN MONGOOSE.Material m 
        ON g.Material_Nombre = m.Material_Nombre AND m.Material_Tipo = 'Relleno'
    WHERE g.Relleno_Densidad IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM MONGOOSE.Relleno r WHERE r.Mat_Codigo = m.Material_Codigo
      );
END;
GO


-- Ejecutar procedimientos de migracion de Modelos, medidas, materiales, telas, maderas y rellenos.
EXEC MONGOOSE.sp_MigrarModeloSillon;
EXEC MONGOOSE.sp_MigrarMedida;
EXEC MONGOOSE.sp_MigrarMaterial;
EXEC MONGOOSE.sp_MigrarTela;
EXEC MONGOOSE.sp_MigrarMadera;
EXEC MONGOOSE.sp_MigrarRelleno;
GO
-- Store Procedure Para la migracion de sillones
CREATE PROCEDURE MONGOOSE.sp_MigrarSillon AS
BEGIN
    INSERT INTO MONGOOSE.Sillon (Sillon_Codigo, Sillon_Medida_Codigo,Sillon_Modelo_Codigo)
    SELECT DISTINCT
        m.Sillon_Codigo,
        medida.Medida_Codigo,
        m.Sillon_Modelo_Codigo
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Medida medida ON
        m.Sillon_Medida_Alto = medida.Medida_Alto AND
        m.Sillon_Medida_Ancho = medida.Medida_Ancho AND
        m.Sillon_Medida_Profundidad = medida.Medida_Profundidad;
END;
GO
-- Store Procedure Para la migracion de MaterialesXSillones
CREATE PROCEDURE MONGOOSE.sp_MigrarMaterialXSillon AS
BEGIN
    INSERT INTO MONGOOSE.MaterialXSillon (Comp_Sillon, Comp_Material)
    SELECT DISTINCT s.Sillon_Codigo, m.Material_Codigo
    FROM gd_esquema.Maestra g
    JOIN MONGOOSE.Sillon s ON g.Sillon_Codigo = s.Sillon_Codigo
    JOIN MONGOOSE.Material m ON g.Material_Nombre = m.Material_Nombre;
END;
GO
-- Store Procedure Para la migracion de detalles de pedidos
CREATE PROCEDURE MONGOOSE.sp_MigrarDetallePedido AS
BEGIN
    INSERT INTO MONGOOSE.DetallePedido (Detalle_Pedido_Numero, Detalle_Pedido_Sillon, Detalle_Pedido_Cantidad, Detalle_Pedido_Precio, Detalle_Pedido_Subtotal)
    SELECT DISTINCT
        m.Pedido_Numero,
        s.Sillon_Codigo,
        m.Detalle_Pedido_Cantidad,
        m.Detalle_Pedido_Precio,
        m.Detalle_Pedido_SubTotal
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Sillon s ON m.Sillon_Codigo = s.Sillon_Codigo
    WHERE m.Pedido_Numero IS NOT NULL;
END;
GO

-- Ejecutar migración de Sillones y materialesXSillones
EXEC MONGOOSE.sp_MigrarSillon;
EXEC MONGOOSE.sp_MigrarMaterialXSillon;
GO
-- Store Procedure Para la migracion de pedidos
CREATE PROCEDURE MONGOOSE.sp_MigrarPedido AS
BEGIN
    INSERT INTO MONGOOSE.Pedido (Pedido_Numero, Pedido_Fecha, Pedido_Estado, Pedido_Total, Pedido_Cliente, Pedido_Sucursal)
    SELECT DISTINCT
        m.Pedido_Numero,
        m.Pedido_Fecha,
        e.Estado_Id,
        m.Pedido_Total,
        c.Cliente_Id,
        s.Sucursal_NroSucursal
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.EstadoPedido e ON m.Pedido_Estado = e.Estado_Descripcion
    JOIN MONGOOSE.Cliente c ON m.Cliente_Dni = c.Cliente_Dni
    JOIN MONGOOSE.Sucursal s ON m.Sucursal_NroSucursal = s.Sucursal_NroSucursal
    WHERE m.Pedido_Numero IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de cancelaciones de pedidos
CREATE PROCEDURE MONGOOSE.sp_MigrarCancelacion AS
BEGIN
    INSERT INTO MONGOOSE.Cancelacion (Cancelacion_Pedido, Cancelacion_Fecha, Cancelacion_Motivo)
    SELECT DISTINCT
        m.Pedido_Numero,
        m.Pedido_Cancelacion_Fecha,
        m.Pedido_Cancelacion_Motivo
    FROM gd_esquema.Maestra m
    WHERE m.Pedido_Cancelacion_Fecha IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de facturas
CREATE PROCEDURE MONGOOSE.sp_MigrarFactura AS
BEGIN
    INSERT INTO MONGOOSE.Factura (Factura_Numero, Factura_Fecha, Factura_Total, Factura_Sucursal, Factura_Cliente)
    SELECT DISTINCT
        m.Factura_Numero,
        m.Factura_Fecha,
        m.Factura_Total,
        s.Sucursal_NroSucursal,
        c.Cliente_Id
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Sucursal s ON m.Sucursal_NroSucursal = s.Sucursal_NroSucursal
    JOIN MONGOOSE.Cliente c ON m.Cliente_Dni = c.Cliente_Dni
    WHERE m.Factura_Numero IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de detalle de facturas
CREATE PROCEDURE MONGOOSE.sp_MigrarDetalleFactura AS
BEGIN
    INSERT INTO MONGOOSE.DetalleFactura (Detalle_Factura_Pedido, Detalle_Factura_Numero, Detalle_Factura_Precio, Detalle_Factura_Cantidad, Detalle_Factura_Subtotal)
    SELECT DISTINCT
        m.Pedido_Numero,
        m.Factura_Numero,
        m.Detalle_Factura_Precio,
        m.Detalle_Factura_Cantidad,
        m.Detalle_Factura_SubTotal
    FROM gd_esquema.Maestra m
    WHERE m.Factura_Numero IS NOT NULL AND m.Pedido_Numero IS NOT NULL
	order by m.Factura_Numero;
END;
GO
-- Store Procedure Para la migracion de compras
CREATE PROCEDURE MONGOOSE.sp_MigrarCompra AS
BEGIN
    INSERT INTO MONGOOSE.Compra (Compra_Numero, Compra_Fecha, Compra_Total, Compra_Sucursal, Compra_Proveedor)
    SELECT DISTINCT
        m.Compra_Numero,
        m.Compra_Fecha,
        m.Compra_Total,
        s.Sucursal_NroSucursal,
        p.Proveedor_Cuit
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Sucursal s ON m.Sucursal_NroSucursal = s.Sucursal_NroSucursal
    JOIN MONGOOSE.Proveedor p ON m.Proveedor_Cuit = p.Proveedor_Cuit
    WHERE m.Compra_Numero IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de detalles de compras
CREATE PROCEDURE MONGOOSE.sp_MigrarDetalleCompra AS
BEGIN
    INSERT INTO MONGOOSE.DetalleCompra (Detalle_Compra_Numero, Detalle_Compra_Material, Detalle_Compra_Precio, Detalle_Compra_Cantidad, Detalle_Compra_Subtotal)
    SELECT DISTINCT
        m.Compra_Numero,
        mat.Material_Codigo,
        m.Detalle_Compra_Precio,
        m.Detalle_Compra_Cantidad,
        m.Detalle_Compra_SubTotal
    FROM gd_esquema.Maestra m
    JOIN MONGOOSE.Material mat ON m.Material_Nombre = mat.Material_Nombre
    WHERE m.Compra_Numero IS NOT NULL;
END;
GO
-- Store Procedure Para la migracion de envios
CREATE PROCEDURE MONGOOSE.sp_MigrarEnvio AS
BEGIN
    INSERT INTO MONGOOSE.Envio (
        Envio_Numero,
        Envio_Fecha_Programada,
        Envio_Fecha,
        Envio_ImporteTraslado,
        Envio_ImporteSubida,
        Envio_Total,
        Envio_Factura
    )
    SELECT DISTINCT
        m.Envio_Numero,
        m.Envio_Fecha_Programada,
        m.Envio_Fecha,
        m.Envio_ImporteTraslado,
        m.Envio_ImporteSubida,
        m.Envio_Total,
        m.Factura_Numero
    FROM gd_esquema.Maestra m
    WHERE m.Envio_Numero IS NOT NULL;
END;
GO


-- Ejecutar migración final de los Stores procedures restantes para completar la migracion.
EXEC MONGOOSE.sp_MigrarPedido;
EXEC MONGOOSE.sp_MigrarDetallePedido;
EXEC MONGOOSE.sp_MigrarCancelacion;
EXEC MONGOOSE.sp_MigrarFactura;
EXEC MONGOOSE.sp_MigrarDetalleFactura;
EXEC MONGOOSE.sp_MigrarCompra;
EXEC MONGOOSE.sp_MigrarDetalleCompra;
EXEC MONGOOSE.sp_MigrarEnvio;
GO



-- Triggers y Otras funcionalidades.

-- TRIGGER para Insertar automáticamente en Cancelacion cuando se cambia el estado a 'cancelado'
CREATE TRIGGER trg_InsertarCancelacion
ON MONGOOSE.Pedido
AFTER UPDATE
AS
BEGIN
    INSERT INTO MONGOOSE.Cancelacion (Cancelacion_Pedido, Cancelacion_Fecha, Cancelacion_Motivo)
    SELECT i.Pedido_Numero, GETDATE(), 'Cambio de estado a cancelado'
    FROM inserted i
    JOIN deleted d ON i.Pedido_Numero = d.Pedido_Numero
    WHERE d.Pedido_Estado <> i.Pedido_Estado
      AND i.Pedido_Estado = (SELECT Estado_Id FROM MONGOOSE.EstadoPedido WHERE Estado_Descripcion = 'cancelado');
END;
GO

-- STORED PROCEDURE: Reporte de pedidos por cliente con sus totales y estado
CREATE PROCEDURE MONGOOSE.sp_ReportePedidosPorCliente
    @Dni NVARCHAR(20)
AS
BEGIN
    SELECT
        p.Pedido_Numero,
        p.Pedido_Fecha,
        ep.Estado_Descripcion AS Estado,
        p.Pedido_Total
    FROM MONGOOSE.Pedido p
    JOIN MONGOOSE.Cliente c ON p.Pedido_Cliente = c.Cliente_Id
    JOIN MONGOOSE.EstadoPedido ep ON p.Pedido_Estado = ep.Estado_Id
    WHERE c.Cliente_Dni = @Dni;
END;
GO

-- STORED PROCEDURE: Crear un pedido con sus detalles 
/*
CREATE PROCEDURE MONGOOSE.sp_CrearPedido_ConTemp
    @Pedido_Numero DECIMAL(18,0),
    @Pedido_Fecha DATETIME,
    @Estado NVARCHAR(100),
    @Total DECIMAL(18,2),
    @Cliente_Dni NVARCHAR(20),
    @Sucursal_Id BIGINT
AS
BEGIN
    DECLARE @Cliente_Id BIGINT = (SELECT Cliente_Id FROM MONGOOSE.Cliente WHERE Cliente_Dni = @Cliente_Dni);
    DECLARE @Estado_Id INT = (SELECT Estado_Id FROM MONGOOSE.EstadoPedido WHERE Estado_Descripcion = @Estado);

    INSERT INTO MONGOOSE.Pedido (Pedido_Numero, Pedido_Fecha, Pedido_Estado, Pedido_Total, Pedido_Cliente, Pedido_Sucursal)
    VALUES (@Pedido_Numero, @Pedido_Fecha, @Estado_Id, @Total, @Cliente_Id, @Sucursal_Id);

    INSERT INTO MONGOOSE.DetallePedido (Detalle_Pedido_Numero, Detalle_Pedido_Sillon, Detalle_Pedido_Cantidad, Detalle_Pedido_Precio, Detalle_Pedido_Subtotal)
    SELECT 
        @Pedido_Numero,
        Sillon_Codigo,
        Cantidad,
        Precio,
        Cantidad * Precio
    FROM #DetallePedidoTemp;
END;
GO
*/


-- STORED PROCEDURE: Registrar una factura con detalles


CREATE TYPE MONGOOSE.DetalleFacturaType AS TABLE (
    Pedido_Numero DECIMAL(18,0),
    Precio DECIMAL(18,2),
    Cantidad BIGINT
);
GO


CREATE PROCEDURE MONGOOSE.sp_CrearFactura
    @Factura_Numero BIGINT,
    @Fecha DATETIME,
    @Total DECIMAL(18,2),
    @Sucursal_Id BIGINT,
    @Cliente_Dni NVARCHAR(255),
    @Detalles MONGOOSE.DetalleFacturaType READONLY
AS
BEGIN
    DECLARE @Cliente_Id BIGINT;

    SELECT @Cliente_Id = Cliente_Id
    FROM MONGOOSE.Cliente
    WHERE Cliente_Dni = @Cliente_Dni;

    INSERT INTO MONGOOSE.Factura (
        Factura_Numero, Factura_Fecha, Factura_Total, Factura_Sucursal, Factura_Cliente
    ) VALUES (
        @Factura_Numero, @Fecha, @Total, @Sucursal_Id, @Cliente_Id
    );

    INSERT INTO MONGOOSE.DetalleFactura (
        Detalle_Factura_Pedido,
        Detalle_Factura_Numero,
        Detalle_Factura_Precio,
        Detalle_Factura_Cantidad,
        Detalle_Factura_Subtotal
    )
    SELECT
        Pedido_Numero,
        @Factura_Numero,
        Precio,
        Cantidad,
        Precio * Cantidad
    FROM @Detalles;
END;
GO


-- STORED PROCEDURE: Registrar una compra con detalles

CREATE TYPE MONGOOSE.DetalleCompraType AS TABLE (
    Material_Codigo BIGINT,
    Precio DECIMAL(18,2),
    Cantidad INT
);
GO

CREATE PROCEDURE MONGOOSE.sp_CrearCompra
    @Compra_Numero DECIMAL(18,0),
    @Fecha DATETIME,
    @Total DECIMAL(18,2),
    @Sucursal_Id BIGINT,
    @Proveedor_Cuit NVARCHAR(20),
    @Detalles MONGOOSE.DetalleCompraType READONLY
AS
BEGIN
    DECLARE @Proveedor_Id BIGINT;

    SELECT @Proveedor_Id = Proveedor_Cuit
    FROM MONGOOSE.Proveedor
    WHERE Proveedor_Cuit = @Proveedor_Cuit;

    INSERT INTO MONGOOSE.Compra (
        Compra_Numero,
        Compra_Fecha,
        Compra_Total,
        Compra_Sucursal,
        Compra_Proveedor
    ) VALUES (
        @Compra_Numero,
        @Fecha,
        @Total,
        @Sucursal_Id,
        @Proveedor_Id
    );

    INSERT INTO MONGOOSE.DetalleCompra (
        Detalle_Compra_Numero,
        Detalle_Compra_Material,
        Detalle_Compra_Precio,
        Detalle_Compra_Cantidad,
        Detalle_Compra_Subtotal
    )
    SELECT
        @Compra_Numero,
        Material_Codigo,
        Precio,
        Cantidad,
        Precio * Cantidad
    FROM @Detalles;
END;
GO


--STORE PROCEDURE para generar un Envio

CREATE PROCEDURE MONGOOSE.sp_CrearEnvio
    @Envio_Numero DECIMAL(18,2),
    @Envio_Fecha_Programada DATETIME2(6),
    @Envio_Fecha DATETIME2(6),
    @Envio_ImporteTraslado DECIMAL(18,2),
    @Envio_ImporteSubida DECIMAL(18,2),
    @Factura_Numero BIGINT
AS
BEGIN
    -- Validar que la factura exista
    IF NOT EXISTS (SELECT 1 FROM MONGOOSE.Factura WHERE Factura_Numero = @Factura_Numero)
    BEGIN
        RETURN;
    END

    -- Calcular total
    DECLARE @Envio_Total DECIMAL(18,2);
    SET @Envio_Total = @Envio_ImporteTraslado + @Envio_ImporteSubida;

    -- Insertar envío
    INSERT INTO MONGOOSE.Envio (
        Envio_Numero,
        Envio_Fecha_Programada,
        Envio_Fecha,
        Envio_ImporteTraslado,
        Envio_ImporteSubida,
        Envio_Total,
        Envio_Factura
    )
    VALUES (
        @Envio_Numero,
        @Envio_Fecha_Programada,
        @Envio_Fecha,
        @Envio_ImporteTraslado,
        @Envio_ImporteSubida,
        @Envio_Total,
        @Factura_Numero
    );
END;
GO

