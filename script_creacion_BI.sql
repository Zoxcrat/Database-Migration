USE GD1C2025
GO


-- BI_Tiempo
CREATE TABLE MONGOOSE.BI_Tiempo (
    Tiempo_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Anio BIGINT,
    Mes BIGINT,
    Cuatrimestre BIGINT
);
GO

-- BI_Ubicacion
CREATE TABLE MONGOOSE.BI_Ubicacion (
    Ubicacion_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provincia NVARCHAR(255),
    Localidad NVARCHAR(255)
);
GO
-- BI_Sucursal
CREATE TABLE MONGOOSE.BI_Sucursal (
    Sucursal_Id BIGINT PRIMARY KEY,
    Ubicacion_Id BIGINT,
    FOREIGN KEY (Ubicacion_Id) REFERENCES MONGOOSE.BI_Ubicacion(Ubicacion_Id)
);
GO
-- BI_RangoEtario 
CREATE TABLE MONGOOSE.BI_RangoEtario (
    Rango_Id BIGINT PRIMARY KEY,
    Rango_Descripcion NVARCHAR(255)
);
GO
-- BI_TurnoVenta
CREATE TABLE MONGOOSE.BI_TurnoVenta (
    Turno_Id INT PRIMARY KEY IDENTITY(1,1),
    Rango_Horario NVARCHAR(50)
);
GO
-- BI_EstadoPedido
CREATE TABLE MONGOOSE.BI_EstadoPedido (
    Estado_Id BIGINT PRIMARY KEY,
    Estado_Descripcion NVARCHAR(255)
);
GO
-- BI_ModeloSillon
CREATE TABLE MONGOOSE.BI_ModeloSillon (
    Modelo_Id BIGINT PRIMARY KEY,
    Modelo_Nombre NVARCHAR(255)
);
GO
-- BI_TipoMaterial
CREATE TABLE MONGOOSE.BI_TipoMaterial (
    Material_Id BIGINT PRIMARY KEY,
    Tipo NVARCHAR(255)
);
GO

-- Migrar datos a BI_Tiempo desde fechas de pedidos, facturas y compras
INSERT INTO MONGOOSE.BI_Tiempo (Anio, Mes, Cuatrimestre)
SELECT DISTINCT
    YEAR(f.Fecha) AS Anio,
    MONTH(f.Fecha) AS Mes,
    CASE 
        WHEN MONTH(f.Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(f.Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS Cuatrimestre
FROM (
    SELECT Pedido_Fecha AS Fecha FROM MONGOOSE.Pedido
    UNION
    SELECT Factura_Fecha FROM MONGOOSE.Factura
    UNION
    SELECT Compra_Fecha FROM MONGOOSE.Compra
) f;
GO
-- Migrar datos a BI_Ubicacion desde provincias y localidades únicas (Clientes y Sucursales)
INSERT INTO MONGOOSE.BI_Ubicacion (Provincia, Localidad)
SELECT DISTINCT 
    p.Provincia_Nombre,
    l.Localidad_Nombre
FROM MONGOOSE.Provincia p
JOIN MONGOOSE.Cliente c ON c.Cliente_Provincia = p.Provincia_Id
JOIN MONGOOSE.Localidad l ON c.Cliente_Localidad = l.Localidad_Id
UNION
SELECT DISTINCT 
    p.Provincia_Nombre,
    l.Localidad_Nombre
FROM MONGOOSE.Provincia p
JOIN MONGOOSE.Sucursal s ON s.Sucursal_Provincia = p.Provincia_Id
JOIN MONGOOSE.Localidad l ON s.Sucursal_Localidad = l.Localidad_Id;
GO
-- Migrar datos a BI_RangoEtario 
INSERT INTO MONGOOSE.BI_RangoEtario VALUES
(1, '<25'), (2, '25-35'), (3, '35-50'), (4, '>50');
GO
-- Migrar datos a BI_TurnoVenta (manual, solo se cargan los valores posibles)
INSERT INTO MONGOOSE.BI_TurnoVenta (Rango_Horario)
VALUES ('08:00-14:00'), ('14:00-20:00');
GO
-- Migrar datos a BI_EstadoPedido
INSERT INTO MONGOOSE.BI_EstadoPedido (Estado_Id, Estado_Descripcion)
SELECT Estado_Id, Estado_Descripcion
FROM MONGOOSE.EstadoPedido;
GO
-- Migrar datos a BI_ModeloSillon
INSERT INTO MONGOOSE.BI_ModeloSillon (Modelo_Id, Modelo_Nombre)
SELECT Modelo_Codigo, Modelo_Nombre
FROM MONGOOSE.ModeloSillon;
GO

-- Migrar datos a BI_TipoMaterial
INSERT INTO MONGOOSE.BI_TipoMaterial (Material_Id, Tipo)
SELECT Material_Codigo, Material_Tipo
FROM MONGOOSE.Material;
GO

-- Migrar datos a BI_Sucursal
INSERT INTO MONGOOSE.BI_Sucursal (Sucursal_Id, Ubicacion_Id)
SELECT 
    s.Sucursal_NroSucursal,
    biu.Ubicacion_Id
FROM MONGOOSE.Sucursal s
JOIN MONGOOSE.Provincia p ON s.Sucursal_Provincia = p.Provincia_Id
JOIN MONGOOSE.Localidad l ON s.Sucursal_Localidad = l.Localidad_Id
JOIN MONGOOSE.BI_Ubicacion biu ON 
    biu.Provincia = p.Provincia_Nombre AND 
    biu.Localidad = l.Localidad_Nombre;
GO

-- Creacion de tablas de Hechos

CREATE TABLE MONGOOSE.BI_Facturacion (
    Tiempo_Id BIGINT,
    Sucursal_Id BIGINT,
    Rango_Id BIGINT,
    Modelo_Id BIGINT,
    Estado_Id BIGINT,
    Total_Facturado DECIMAL(18,2),
    Cant_Facturas BIGINT,
    PRIMARY KEY (Tiempo_Id, Sucursal_Id, Rango_Id, Modelo_Id, Estado_Id),
    FOREIGN KEY (Tiempo_Id) REFERENCES MONGOOSE.BI_Tiempo(Tiempo_Id),
    FOREIGN KEY (Sucursal_Id) REFERENCES MONGOOSE.BI_Sucursal(Sucursal_Id),
    FOREIGN KEY (Rango_Id) REFERENCES MONGOOSE.BI_RangoEtario(Rango_Id),
    FOREIGN KEY (Modelo_Id) REFERENCES MONGOOSE.BI_ModeloSillon(Modelo_Id),
    FOREIGN KEY (Estado_Id) REFERENCES MONGOOSE.BI_EstadoPedido(Estado_Id)
);
GO

-- Migracion de datos a BI_Facturacion
INSERT INTO MONGOOSE.BI_Facturacion (
    Tiempo_Id, Sucursal_Id, Rango_Id, Modelo_Id, Estado_Id,
    Total_Facturado, Cant_Facturas
)
SELECT 
    t.Tiempo_Id,
    s.Sucursal_Id,
    r.Rango_Id,
    ms.Modelo_Id,
    ep.Estado_Id,
    SUM(df.Detalle_Factura_Subtotal) AS Total_Facturado,
    COUNT(DISTINCT f.Factura_Numero) AS Cant_Facturas
FROM MONGOOSE.Factura f
JOIN MONGOOSE.DetalleFactura df ON f.Factura_Numero = df.Detalle_Factura_Numero
JOIN MONGOOSE.Pedido p ON df.Detalle_Factura_Pedido = p.Pedido_Numero
JOIN MONGOOSE.DetallePedido dp ON dp.Detalle_Pedido_Numero = p.Pedido_Numero
JOIN MONGOOSE.Sillon sillon ON dp.Detalle_Pedido_Sillon = sillon.Sillon_Codigo
JOIN MONGOOSE.ModeloSillon ms_trans ON sillon.Sillon_Modelo_Codigo = ms_trans.Modelo_Codigo
JOIN MONGOOSE.BI_ModeloSillon ms ON ms.Modelo_Id = ms_trans.Modelo_Codigo
-- Sucursal
JOIN MONGOOSE.Sucursal suc ON f.Factura_Sucursal = suc.Sucursal_NroSucursal
JOIN MONGOOSE.Provincia pr ON suc.Sucursal_Provincia = pr.Provincia_Id
JOIN MONGOOSE.Localidad lo ON suc.Sucursal_Localidad = lo.Localidad_Id
JOIN MONGOOSE.BI_Ubicacion ubi ON ubi.Provincia = pr.Provincia_Nombre AND ubi.Localidad = lo.Localidad_Nombre
JOIN MONGOOSE.BI_Sucursal s ON s.Sucursal_Id = suc.Sucursal_NroSucursal AND s.Ubicacion_Id = ubi.Ubicacion_Id
-- Rango Etario (cliente)
JOIN MONGOOSE.Cliente c ON f.Factura_Cliente = c.Cliente_Id
JOIN MONGOOSE.BI_RangoEtario r ON r.Rango_Descripcion = 
    CASE 
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) < 25 THEN '<25'
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25-35'
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) BETWEEN 36 AND 50 THEN '35-50'
        ELSE '>50'
    END
-- Estado Pedido
JOIN MONGOOSE.EstadoPedido ep_trans ON p.Pedido_Estado = ep_trans.Estado_Id
JOIN MONGOOSE.BI_EstadoPedido ep ON ep.Estado_Id = ep_trans.Estado_Id
-- Tiempo
JOIN MONGOOSE.BI_Tiempo t ON
    t.Anio = YEAR(f.Factura_Fecha) AND
    t.Mes = MONTH(f.Factura_Fecha) AND
    t.Cuatrimestre = CASE 
        WHEN MONTH(f.Factura_Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(f.Factura_Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END
GROUP BY 
    t.Tiempo_Id,
    s.Sucursal_Id,
    r.Rango_Id,
    ms.Modelo_Id,
    ep.Estado_Id;
GO



-- Creacion de la tabla de Hechos compras
CREATE TABLE MONGOOSE.BI_Compra (
    Tiempo_Id BIGINT,
    Sucursal_Id BIGINT,
    TipoMaterial_Id BIGINT,
    Total_Compra DECIMAL(18,2),
    Cant_Compras BIGINT,
    PRIMARY KEY (Tiempo_Id, Sucursal_Id, TipoMaterial_Id),
    FOREIGN KEY (Tiempo_Id) REFERENCES MONGOOSE.BI_Tiempo(Tiempo_Id),
    FOREIGN KEY (Sucursal_Id) REFERENCES MONGOOSE.BI_Sucursal(Sucursal_Id),
    FOREIGN KEY (TipoMaterial_Id) REFERENCES MONGOOSE.BI_TipoMaterial(Material_Id)
);
GO


--Migracion de datos a la tabla de hechos compras
INSERT INTO MONGOOSE.BI_Compra (
    Tiempo_Id, Sucursal_Id, TipoMaterial_Id, Total_Compra, Cant_Compras
)
SELECT
    t.Tiempo_Id,
    s.Sucursal_Id,
    tm.Material_Id,
    SUM(dc.Detalle_Compra_Subtotal) AS Total_Compra,
    COUNT(DISTINCT c.Compra_Numero) AS Cant_Compras
FROM MONGOOSE.Compra c
JOIN MONGOOSE.DetalleCompra dc ON c.Compra_Numero = dc.Detalle_Compra_Numero
JOIN MONGOOSE.Material m ON dc.Detalle_Compra_Material = m.Material_Codigo
JOIN MONGOOSE.BI_TipoMaterial tm ON tm.Tipo = m.Material_Tipo
-- Sucursal
JOIN MONGOOSE.Sucursal suc ON c.Compra_Sucursal = suc.Sucursal_NroSucursal
JOIN MONGOOSE.Provincia pr ON suc.Sucursal_Provincia = pr.Provincia_Id
JOIN MONGOOSE.Localidad lo ON suc.Sucursal_Localidad = lo.Localidad_Id
JOIN MONGOOSE.BI_Ubicacion ubi ON ubi.Provincia = pr.Provincia_Nombre AND ubi.Localidad = lo.Localidad_Nombre
JOIN MONGOOSE.BI_Sucursal s ON s.Sucursal_Id = suc.Sucursal_NroSucursal AND s.Ubicacion_Id = ubi.Ubicacion_Id
-- Tiempo
JOIN MONGOOSE.BI_Tiempo t ON
    t.Anio = YEAR(c.Compra_Fecha) AND
    t.Mes = MONTH(c.Compra_Fecha) AND
    t.Cuatrimestre = CASE 
        WHEN MONTH(c.Compra_Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(c.Compra_Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END
GROUP BY
    t.Tiempo_Id,
    s.Sucursal_Id,
    tm.Material_Id;
GO

-- Creacion de la tabla de hecho Envios
CREATE TABLE MONGOOSE.BI_Envio (
    Tiempo_Id BIGINT,
    Ubicacion_Id BIGINT,
    Total_Envios BIGINT,
    Envios_Cumplidos BIGINT,
    Costo_Total_Envio DECIMAL(18,2),
    PRIMARY KEY (Tiempo_Id, Ubicacion_Id),
    FOREIGN KEY (Tiempo_Id) REFERENCES MONGOOSE.BI_Tiempo(Tiempo_Id),
    FOREIGN KEY (Ubicacion_Id) REFERENCES MONGOOSE.BI_Ubicacion(Ubicacion_Id)
);
GO


-- Migración de datos a la tabla de hechos BI_Envio
INSERT INTO MONGOOSE.BI_Envio (
    Tiempo_Id, Ubicacion_Id, Total_Envios, Envios_Cumplidos, Costo_Total_Envio
)
SELECT 
    t.Tiempo_Id,
    u.Ubicacion_Id,
    COUNT(e.Envio_Numero) AS Total_Envios,
    SUM(CASE WHEN e.Envio_Fecha <= e.Envio_Fecha_Programada THEN 1 ELSE 0 END) AS Envios_Cumplidos,
    SUM(e.Envio_Total) AS Costo_Total_Envio
FROM MONGOOSE.Envio e
JOIN MONGOOSE.Factura f ON e.Envio_Factura = f.Factura_Numero
JOIN MONGOOSE.Cliente c ON f.Factura_Cliente = c.Cliente_Id
JOIN MONGOOSE.Provincia p ON c.Cliente_Provincia = p.Provincia_Id
JOIN MONGOOSE.Localidad l ON c.Cliente_Localidad = l.Localidad_Id
JOIN MONGOOSE.BI_Ubicacion u ON u.Provincia = p.Provincia_Nombre AND u.Localidad = l.Localidad_Nombre
-- Tiempo
JOIN MONGOOSE.BI_Tiempo t ON
    t.Anio = YEAR(e.Envio_Fecha) AND
    t.Mes = MONTH(e.Envio_Fecha) AND
    t.Cuatrimestre = CASE 
        WHEN MONTH(e.Envio_Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(e.Envio_Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END
GROUP BY 
    t.Tiempo_Id,
    u.Ubicacion_Id;
GO


-- Creacion de la tabla de hecho Pedidos
CREATE TABLE MONGOOSE.BI_Pedido (
    Tiempo_Id BIGINT,
    Sucursal_Id BIGINT,
    Rango_Id BIGINT,
    Turno_Id INT,
    Estado_Id BIGINT,
    Cant_Pedidos BIGINT,
    PRIMARY KEY (Tiempo_Id, Sucursal_Id, Rango_Id, Turno_Id, Estado_Id),
    FOREIGN KEY (Tiempo_Id) REFERENCES MONGOOSE.BI_Tiempo(Tiempo_Id),
    FOREIGN KEY (Sucursal_Id) REFERENCES MONGOOSE.BI_Sucursal(Sucursal_Id),
    FOREIGN KEY (Rango_Id) REFERENCES MONGOOSE.BI_RangoEtario(Rango_Id),
    FOREIGN KEY (Turno_Id) REFERENCES MONGOOSE.BI_TurnoVenta(Turno_Id),
    FOREIGN KEY (Estado_Id) REFERENCES MONGOOSE.BI_EstadoPedido(Estado_Id)
);
GO


--Migracion de datos a tabla de hechos pedidos
INSERT INTO MONGOOSE.BI_Pedido (
    Tiempo_Id, Sucursal_Id, Rango_Id, Turno_Id, Estado_Id, Cant_Pedidos
)
SELECT
    t.Tiempo_Id,
    s.Sucursal_Id,
    r.Rango_Id,
    tv.Turno_Id,
    epb.Estado_Id,
    COUNT(p.Pedido_Numero) AS Cant_Pedidos
FROM MONGOOSE.Pedido p
-- Rango etario
JOIN MONGOOSE.Cliente c ON p.Pedido_Cliente = c.Cliente_Id
JOIN MONGOOSE.BI_RangoEtario r ON
    r.Rango_Descripcion = CASE
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) < 25 THEN '<25'
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) BETWEEN 25 AND 34 THEN '25-35'
        WHEN DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35-50'
        ELSE '>50'
    END
-- Turno
JOIN MONGOOSE.BI_TurnoVenta tv ON
    tv.Rango_Horario = CASE
        WHEN CAST(p.Pedido_Fecha AS TIME) BETWEEN '08:00:00' AND '13:59:59' THEN '08:00-14:00'
        ELSE '14:00-20:00'
    END
-- Estado
JOIN MONGOOSE.EstadoPedido ep ON p.Pedido_Estado = ep.Estado_Id
JOIN MONGOOSE.BI_EstadoPedido epb ON ep.Estado_Id = epb.Estado_Id
-- Sucursal
JOIN MONGOOSE.Sucursal su ON p.Pedido_Sucursal = su.Sucursal_NroSucursal
JOIN MONGOOSE.Provincia pr ON pr.Provincia_Id = su.Sucursal_Provincia
JOIN MONGOOSE.Localidad lo ON lo.Localidad_Id = su.Sucursal_Localidad
JOIN MONGOOSE.BI_Ubicacion ubi ON ubi.Provincia = pr.Provincia_Nombre AND ubi.Localidad = lo.Localidad_Nombre
JOIN MONGOOSE.BI_Sucursal s ON s.Sucursal_Id = su.Sucursal_NroSucursal AND s.Ubicacion_Id = ubi.Ubicacion_Id
-- Tiempo
JOIN MONGOOSE.BI_Tiempo t ON
    t.Anio = YEAR(p.Pedido_Fecha) AND
    t.Mes = MONTH(p.Pedido_Fecha) AND
    t.Cuatrimestre = CASE 
        WHEN MONTH(p.Pedido_Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(p.Pedido_Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END
GROUP BY
    t.Tiempo_Id,
    s.Sucursal_Id,
    r.Rango_Id,
    tv.Turno_Id,
    epb.Estado_Id;
GO
	

--Creacion de la tabla de hecho Pedido Facturado
CREATE TABLE MONGOOSE.BI_PedidoFacturado (
    Tiempo_Id BIGINT,
    Sucursal_Id BIGINT,
    Promedio_Dias_Fabricacion DECIMAL(10,2),
    PRIMARY KEY (Tiempo_Id, Sucursal_Id),
    FOREIGN KEY (Tiempo_Id) REFERENCES MONGOOSE.BI_Tiempo(Tiempo_Id),
    FOREIGN KEY (Sucursal_Id) REFERENCES MONGOOSE.BI_Sucursal(Sucursal_Id)
);
GO

--Migracion de datos a tabla de hechos pedidosFacturado
INSERT INTO MONGOOSE.BI_PedidoFacturado (
    Tiempo_Id, Sucursal_Id, Promedio_Dias_Fabricacion
)
SELECT 
    t.Tiempo_Id,
    s.Sucursal_Id,
    AVG(DATEDIFF(DAY, CAST(p.Pedido_Fecha AS DATE), CAST(f.Factura_Fecha AS DATE))) AS Promedio_Dias_Fabricacion
FROM MONGOOSE.Factura f
JOIN MONGOOSE.DetalleFactura df ON f.Factura_Numero = df.Detalle_Factura_Numero
JOIN MONGOOSE.Pedido p ON df.Detalle_Factura_Pedido = p.Pedido_Numero

-- Tiempo
JOIN MONGOOSE.BI_Tiempo t ON
    t.Anio = YEAR(f.Factura_Fecha) AND
    t.Cuatrimestre = CASE 
        WHEN MONTH(f.Factura_Fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(f.Factura_Fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END
-- Sucursal
JOIN MONGOOSE.Sucursal su ON p.Pedido_Sucursal = su.Sucursal_NroSucursal
JOIN MONGOOSE.Provincia pr ON pr.Provincia_Id = su.Sucursal_Provincia
JOIN MONGOOSE.Localidad lo ON lo.Localidad_Id = su.Sucursal_Localidad
JOIN MONGOOSE.BI_Ubicacion u ON u.Provincia = pr.Provincia_Nombre AND u.Localidad = lo.Localidad_Nombre
JOIN MONGOOSE.BI_Sucursal s ON s.Sucursal_Id = su.Sucursal_NroSucursal AND s.Ubicacion_Id = u.Ubicacion_Id
GROUP BY 
    t.Tiempo_Id,
    s.Sucursal_Id;
GO



-- VISTAS
--1.Vista de ganancias
CREATE VIEW MONGOOSE.BI_VistaGanancias AS
SELECT 
    t.Anio,
    t.Mes,
    s.Sucursal_Id,
    SUM(f.Total_Facturado) - ISNULL(SUM(c.Total_Compra), 0) AS Ganancia
FROM MONGOOSE.BI_Facturacion f
JOIN MONGOOSE.BI_Tiempo t ON f.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON f.Sucursal_Id = s.Sucursal_Id
LEFT JOIN MONGOOSE.BI_Compra c 
    ON f.Tiempo_Id = c.Tiempo_Id AND f.Sucursal_Id = c.Sucursal_Id
GROUP BY 
    t.Anio, t.Mes, s.Sucursal_Id;
GO

--2.Vista de Factura promedio mensual
CREATE VIEW MONGOOSE.BI_VistaFacturaPromedio AS
SELECT 
    t.Anio,
    t.Cuatrimestre,
    u.Provincia,
    AVG(f.Total_Facturado) AS Promedio_Factura
FROM MONGOOSE.BI_Facturacion f
JOIN MONGOOSE.BI_Tiempo t ON f.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON f.Sucursal_Id = s.Sucursal_Id
JOIN MONGOOSE.BI_Ubicacion u ON s.Ubicacion_Id = u.Ubicacion_Id
GROUP BY 
    t.Anio, t.Cuatrimestre, u.Provincia;
GO


--3.Vista de rendimiento de modelos
CREATE VIEW MONGOOSE.BI_VistaTopModelos AS
WITH RankingModelos AS (
    SELECT 
        t.Anio,
        t.Cuatrimestre,
        u.Localidad,
        r.Rango_Descripcion,
        ms.Modelo_Nombre,
        SUM(f.Total_Facturado) AS Total_Venta,
        ROW_NUMBER() OVER (
            PARTITION BY t.Anio, t.Cuatrimestre, u.Localidad, r.Rango_Descripcion
            ORDER BY SUM(f.Total_Facturado) DESC
        ) AS Posicion
    FROM MONGOOSE.BI_Facturacion f
    JOIN MONGOOSE.BI_Tiempo t ON f.Tiempo_Id = t.Tiempo_Id
    JOIN MONGOOSE.BI_Sucursal s ON f.Sucursal_Id = s.Sucursal_Id
    JOIN MONGOOSE.BI_Ubicacion u ON s.Ubicacion_Id = u.Ubicacion_Id
    JOIN MONGOOSE.BI_RangoEtario r ON f.Rango_Id = r.Rango_Id
    JOIN MONGOOSE.BI_ModeloSillon ms ON f.Modelo_Id = ms.Modelo_Id
    GROUP BY 
        t.Anio, t.Cuatrimestre, u.Localidad, r.Rango_Descripcion, ms.Modelo_Nombre
)
SELECT *
FROM RankingModelos
WHERE Posicion <= 3;
GO


--4 Vista de volumen de pedidos
CREATE VIEW MONGOOSE.BI_VistaVolumenPedidos AS
SELECT 
    t.Anio,
    t.Mes,
    s.Sucursal_Id,
    tv.Rango_Horario,
    SUM(p.Cant_Pedidos) AS Total_Pedidos
FROM MONGOOSE.BI_Pedido p
JOIN MONGOOSE.BI_Tiempo t ON p.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON p.Sucursal_Id = s.Sucursal_Id
JOIN MONGOOSE.BI_TurnoVenta tv ON p.Turno_Id = tv.Turno_Id
GROUP BY 
    t.Anio, t.Mes, s.Sucursal_Id, tv.Rango_Horario;
GO

--5. Vista de Conversion de pedidos
CREATE VIEW MONGOOSE.BI_VistaConversionPedidos AS
SELECT 
    t.Anio,
    t.Cuatrimestre,
    s.Sucursal_Id,
    ep.Estado_Descripcion,
    SUM(p.Cant_Pedidos) * 1.0 / SUM(SUM(p.Cant_Pedidos)) OVER (
        PARTITION BY t.Anio, t.Cuatrimestre, s.Sucursal_Id
    ) AS Porcentaje_Estado
FROM MONGOOSE.BI_Pedido p
JOIN MONGOOSE.BI_Tiempo t ON p.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON p.Sucursal_Id = s.Sucursal_Id
JOIN MONGOOSE.BI_EstadoPedido ep ON p.Estado_Id = ep.Estado_Id
GROUP BY 
    t.Anio, t.Cuatrimestre, s.Sucursal_Id, ep.Estado_Descripcion;
GO

--6. Vista de tiempo de fabricacion
CREATE VIEW MONGOOSE.BI_VistaTiempoFabricacion AS
SELECT 
    t.Anio,
    t.Cuatrimestre,
    s.Sucursal_Id,
    pf.Promedio_Dias_Fabricacion
FROM MONGOOSE.BI_PedidoFacturado pf
JOIN MONGOOSE.BI_Tiempo t ON pf.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON pf.Sucursal_Id = s.Sucursal_Id;
GO

--7. Vista de promedio de compras por mes
CREATE VIEW MONGOOSE.BI_VistaPromedioCompras AS
SELECT 
    t.Anio,
    t.Mes,
    AVG(c.Total_Compra) AS Promedio_Compra
FROM MONGOOSE.BI_Compra c
JOIN MONGOOSE.BI_Tiempo t ON c.Tiempo_Id = t.Tiempo_Id
GROUP BY 
    t.Anio, t.Mes;
GO

--8. Vista de compras por tipo de material
CREATE VIEW MONGOOSE.BI_VistaComprasPorMaterial AS
SELECT 
    t.Anio,
    t.Cuatrimestre,
    s.Sucursal_Id,
    tm.Tipo,
    SUM(c.Total_Compra) AS Total_Compras
FROM MONGOOSE.BI_Compra c
JOIN MONGOOSE.BI_Tiempo t ON c.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Sucursal s ON c.Sucursal_Id = s.Sucursal_Id
JOIN MONGOOSE.BI_TipoMaterial tm ON c.TipoMaterial_Id  = tm.Material_Id
GROUP BY 
    t.Anio, t.Cuatrimestre, s.Sucursal_Id, tm.Tipo;
GO


--9. Vista de % de cumplimiento de envios
CREATE VIEW MONGOOSE.BI_VistaCumplimientoEnvios AS
SELECT 
    t.Anio,
    t.Mes,
    u.Provincia,
    u.Localidad,
    SUM(e.Envios_Cumplidos) * 1.0 / NULLIF(SUM(e.Total_Envios), 0) AS Porcentaje_Cumplimiento
FROM MONGOOSE.BI_Envio e
JOIN MONGOOSE.BI_Tiempo t ON e.Tiempo_Id = t.Tiempo_Id
JOIN MONGOOSE.BI_Ubicacion u ON e.Ubicacion_Id = u.Ubicacion_Id
GROUP BY 
    t.Anio, t.Mes, u.Provincia, u.Localidad;
GO


--10. Vista de Localidades que pagan mayor costo de envio
CREATE VIEW MONGOOSE.BI_VistaTopLocalidadesEnvio AS
WITH PromedioPorLocalidad AS (
    SELECT 
        u.Localidad,
        AVG(e.Costo_Total_Envio * 1.0 / NULLIF(e.Total_Envios, 0)) AS Promedio_Costo
    FROM MONGOOSE.BI_Envio e
    JOIN MONGOOSE.BI_Ubicacion u ON e.Ubicacion_Id = u.Ubicacion_Id
    GROUP BY u.Localidad
)
SELECT TOP 3 *
FROM PromedioPorLocalidad
ORDER BY Promedio_Costo DESC;
GO

select * from MONGOOSE.BI_VistaGanancias

select * from MONGOOSE.BI_VistaFacturaPromedio

select * from MONGOOSE.BI_VistaTopModelos

select * from MONGOOSE.BI_VistaVolumenPedidos

select * from MONGOOSE.BI_VistaConversionPedidos

select * from MONGOOSE.BI_VistaTiempoFabricacion

select * from MONGOOSE.BI_VistaPromedioCompras

select * from MONGOOSE.BI_VistaComprasPorMaterial

select * from MONGOOSE.BI_VistaCumplimientoEnvios

select * from MONGOOSE.BI_VistaTopLocalidadesEnvio
