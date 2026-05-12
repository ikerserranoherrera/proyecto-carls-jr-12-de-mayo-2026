/*
  Nombre del archivo: dbcarlsjr.sql
  Descripción: Creación de base de datos para Carl's Jr.
  Entidades: 10
*/

CREATE DATABASE IF NOT EXISTS dbcarlsjr;
USE dbcarlsjr;

-- 1. SUCURSALES (Entidad Maestra)
CREATE TABLE Sucursales (
    sucursal_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    ciudad VARCHAR(60),
    estado VARCHAR(60),
    telefono VARCHAR(15),
    horario_apertura TIME,
    horario_cierre TIME,
    tiene_drive_thru BOOLEAN DEFAULT FALSE,
    activa BOOLEAN DEFAULT TRUE
);

-- 2. PRODUCTOS (Menú)
CREATE TABLE Productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria ENUM('Hamburguesa', 'Papas', 'Bebida', 'Postre', 'Complemento') NOT NULL,
    precio DECIMAL(8,2) NOT NULL,
    calorias INT,
    es_combo BOOLEAN DEFAULT FALSE,
    disponible BOOLEAN DEFAULT TRUE,
    imagen_url VARCHAR(255)
);

-- 3. CLIENTES (Loyalty)
CREATE TABLE Clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    email VARCHAR(120) UNIQUE,
    telefono VARCHAR(15),
    fecha_nacimiento DATE,
    puntos_loyalty INT DEFAULT 0,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 4. PERSONAL (Empleados)
CREATE TABLE Personal (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    sucursal_id INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    rol ENUM('Cajero', 'Cocina', 'Gerente', 'Supervisor') NOT NULL,
    email VARCHAR(120) UNIQUE,
    telefono VARCHAR(15),
    fecha_ingreso DATE NOT NULL,
    salario DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);

-- 5. CUPONES (Entidad adicional para completar 10)
CREATE TABLE Cupones (
    cupon_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion VARCHAR(150),
    descuento_porcentaje DECIMAL(5,2),
    fecha_expiracion DATE,
    activo BOOLEAN DEFAULT TRUE
);

-- 6. PEDIDOS (Núcleo Transaccional)
CREATE TABLE Pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NULL,
    sucursal_id INT NOT NULL,
    empleado_id INT,
    canal ENUM('Caja', 'Drive-thru', 'App', 'Delivery') NOT NULL,
    estado ENUM('Pendiente', 'Preparando', 'Listo', 'Entregado', 'Cancelado') NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    impuesto DECIMAL(8,2),
    total DECIMAL(10,2) NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id),
    FOREIGN KEY (empleado_id) REFERENCES Personal(empleado_id)
);

-- 7. DETALLE DE PEDIDO (Tabla Pivot)
CREATE TABLE Detalle_Pedido (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    personalizacion TEXT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);

-- 8. PAGOS (Conciliación)
CREATE TABLE Pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    metodo ENUM('Efectivo', 'Tarjeta', 'App', 'Cupón') NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    referencia VARCHAR(100),
    estado ENUM('Aprobado', 'Rechazado', 'Reembolsado') NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id)
);

-- 9. TURNOS (Asistencia)
CREATE TABLE Turnos (
    turno_id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    sucursal_id INT,
    fecha DATE NOT NULL,
    hora_entrada TIME NOT NULL,
    hora_salida TIME NOT NULL,
    entrada_real DATETIME,
    salida_real DATETIME,
    estado ENUM('Programado', 'Presente', 'Ausente', 'Retardo'),
    FOREIGN KEY (empleado_id) REFERENCES Personal(empleado_id),
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);

-- 10. INVENTARIO (Stock)
CREATE TABLE Inventario (
    inventario_id INT AUTO_INCREMENT PRIMARY KEY,
    sucursal_id INT NOT NULL,
    insumo VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    stock_actual DECIMAL(10,2) NOT NULL,
    stock_minimo DECIMAL(10,2),
    costo_unitario DECIMAL(8,2),
    fecha_caducidad DATE,
    ultima_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sucursal_id) REFERENCES Sucursales(sucursal_id)
);