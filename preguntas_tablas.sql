-- Núria Marzo

use evaluacion_continua; 

-- 1)Calcula el total de ventas para cada producto, ordenado de mayor a menor.
SELECT 
    p.id_producto, -- columna 1
    p.nombre AS producto,  -- columna 2
    SUM(dp.cantidad) AS total_ventas, -- columna 3: calcula la suma de la cantidad vendida para cada producto 
    p.precio AS precio_unidad, -- columna 4
    SUM(dp.cantidad) * p.precio AS total_ventas_valor -- columna 5:Calcula el valor total de las ventas para cada producto multiplicando la cantidad vendida por el precio unidad(columna 3 y 4)
FROM 
    Detalles_Pedidos dp
JOIN 
    Productos p ON dp.id_producto = p.id_producto
JOIN 
    Pedidos pe ON dp.id_pedido = pe.id_pedido -- Dos joins para unir las tablas Detalles_Pedidos, Productos y Pedidos
WHERE 
    pe.estado = 'Entregado' -- es estado del pedido debe estar entregado para hacer el cáñlculo
GROUP BY 
    p.id_producto, p.nombre, p.precio --  Agrupa las filas que tienen valores comunes,se agrupan los resultados por ID del producto, nombre del producto y precio unitario.
ORDER BY 
    total_ventas_valor DESC; -- así ordenamos el total de ventas de mayor a menor
    
    
    -- 2) Identifica el último pedido realizado por cada cliente.
    
SELECT 
    id_cliente,
    MAX(id_pedido) --  La función MAX() se utiliza para encontrar el valor máximo del ID del pedido (id_pedido) para cada cliente (id_cliente). Es decir, agrupa los pedidos por cliente y selecciona el ID de pedido más alto dentro de cada grupo. 
FROM 
    Pedidos
GROUP BY 
    id_cliente;


-- 3) Determina el número total de pedidos realizados por clientes en cada ciudad.

SELECT 
    c.ciudad, -- Selecciono el nombre de la ciudad desde la tabla clientes
    COUNT(p.id_pedido) AS total_pedidos -- conto el número de pedidos (id_pedido) realizados por clientes en cada ciudad y le pongo "total_pedidos"
FROM 
    Pedidos p
JOIN 
    Clientes c ON p.id_cliente = c.id_cliente -- uno tablas pedidos y clientes, clave de union: id_cliente
GROUP BY -- se agrupan los resultados por el nombre de la ciudad para que la función COUNT() cuente el número de pedidos para cada ciudad.
    c.ciudad;

-- 4) Lista todos los productos que nunca han sido parte de un pedido.

SELECT 
    id_producto,
    nombre
FROM 
    Productos
WHERE 
    id_producto NOT IN (SELECT DISTINCT id_producto FROM Detalles_Pedidos); --  subconsulta para obtener todos los IDs de productos que han sido parte de algún pedido. Con el SELECT DISTINCT obtengo valores únicos de id_producto de la tabla Detalles_Pedidos

    -- 5) Encuentra los productos más vendidos en términos de cantidad total vendida.
    
SELECT 
    dp.id_producto, -- Selecciono el ID del producto desde la tabla Detalles_Pedidos
    pr.nombre AS nombre_producto, -- Selecciono el nombre del producto desde la tabla Productos y le pongo nombre_producto
    SUM(dp.cantidad) AS cantidad_total_vendida -- sumo la cantidad vendida de cada producto y lo pongo como "cantidad_total_vendida"
FROM 
    Detalles_Pedidos dp
JOIN 
    Productos pr ON dp.id_producto = pr.id_producto -- hacemos join de las tablas Detalles_Pedidos y Productos con la clave de union id_producto
GROUP BY 
    dp.id_producto, pr.nombre
ORDER BY 
    cantidad_total_vendida DESC;


-- 6) Identifica a los clientes que han realizado compras en más de una categoría de producto.

SELECT 
    c.id_cliente, -- columna 1  ID del cliente.
    c.nombre AS nombre_cliente -- columna 2  nombre del cliente.
FROM 
    Clientes c
JOIN 
    Pedidos p ON c.id_cliente = p.id_cliente -- clientes, pedidos
JOIN 
    Detalles_Pedidos dp ON p.id_pedido = dp.id_pedido -- detalles_pedidos, pedidos
JOIN 
    Productos pr ON dp.id_producto = pr.id_producto -- detalles_pedidos, productos. Junto todas las tablas: Clientes, Pedidos, Detalles_Pedidos y Productos. Puntos de unión entre tablas: id_cliente, id_pedido, id_producto
GROUP BY 
    c.id_cliente, c.nombre
HAVING  --  filtra los resultados después de que se han agrupado e incluye solo aquellos clientes que hayan comprado en más de una categoría de producto.
COUNT(DISTINCT pr.categoría) > 1; -- Esta condición cuenta la cantidad de categorías distintas de productos comprados por cada cliente. Si el número de categorías distintas es mayor que 1, significa que el cliente ha comprado en más de una categoría de producto.

   -- 7) Muestra las ventas totales agrupadas por mes y año.
    
SELECT 
    YEAR(p.fecha_pedido) AS año, -- función YEAR() para extraer el año de la fecha del pedido (p.fecha_pedido) y lo nombro como "año"
    MONTH(p.fecha_pedido) AS mes,
    SUM(dp.cantidad * pr.precio) AS ventas_totales -- total de ventas multiplicando la cantidad de cada producto por su precio y luego sumando estos totales. Este cálculo se realiza para cada pedido.
FROM 
    Pedidos p
JOIN 
    Detalles_Pedidos dp ON p.id_pedido = dp.id_pedido -- join con la tabla "Detalles_Pedidos" utilizando el ID del pedido como clave de unión
JOIN 
    Productos pr ON dp.id_producto = pr.id_producto -- Une la tabla "Productos" utilizando el ID del producto como clave de unión.
GROUP BY  
    YEAR(p.fecha_pedido), MONTH(p.fecha_pedido) -- Agrupa los resultados por año y mes para que la suma de las ventas se realice para cada combinación única de año y mes.
ORDER BY 
    YEAR(p.fecha_pedido), MONTH(p.fecha_pedido);


-- 8) Calcula la cantidad promedio de productos por pedido.

SELECT AVG(cantidad_productos) AS cantidad_promedio_productos --  selecciono el promedio de la cantidad de productos por pedido con AVG y le llamo cantidad_promedio_productos.
FROM ( -- subconsulta
    SELECT id_pedido, COUNT(id_producto) AS cantidad_productos -- La cantidad de productos en cada pedido. Esto se calcula contando el número de registros de la tabla Detalles_Pedidos agrupados por id_pedido.
    FROM Detalles_Pedidos
    GROUP BY id_pedido -- se agrupan los resultados por id_pedido. Esto significa que la cantidad de productos se cuenta para cada pedido individualmente.
) AS cantidades_por_pedido;



-- 9) Determina cuántos clientes han realizado pedidos en más de una ocasión. 

SELECT COUNT(*) AS clientes_multiples_pedidos
FROM (
    -- Subconsulta para contar la cantidad de pedidos por cliente en la tabla Pedidos utilizando GROUP BY id_cliente.
    SELECT id_cliente
    FROM Pedidos
    GROUP BY id_cliente
    HAVING COUNT(*) > 1 -- filtra solo aquellos clientes que tienen más de un pedido.
) AS clientes_multiples_pedidos;



-- 10) Calcula el tiempo promedio que pasa entre pedidos para cada cliente. 


SELECT 
    c.id_cliente, -- id cliente
    c.nombre AS nombre_cliente, -- nombre cliente
    AVG(DATEDIFF(p2.fecha_pedido, p1.fecha_pedido)) AS tiempo_promedio_entre_pedidos -- dATEDIFF calcula la diferencia en días entre las fechas de los pedidos consecutivos (en este caso sólo los id 10, 11 y 12), y luego se calcula el promedio de estas diferencias utilizando la función AVG()
FROM 
    Clientes c
LEFT JOIN 
    Pedidos p1 ON c.id_cliente = p1.id_cliente -- con este left join obtengo información sobre los pedidos de cada cliente.
LEFT JOIN 
    Pedidos p2 ON c.id_cliente = p2.id_cliente AND p1.id_pedido < p2.id_pedido -- este left joi también une Clientes con Pedidos, pero se usa una condición adicional p1.id_pedido < p2.id_pedido. Esto asegura que solo se unan los pedidos posteriores al primer pedido para cada cliente. Esto nos permite calcular la diferencia de días entre pedidos consecutivos.
GROUP BY 
    c.id_cliente, c.nombre;
    
    commit;
