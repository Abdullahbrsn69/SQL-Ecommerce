/* Bu bir E-commerce Data Management projesidir. */

create table Customers (
customer_id SERIAL primary key,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(20),
created_at timestamp default CURRENT_TIMESTAMP
);

create table Products (
product_id serial primary key,
product_name varchar(100) not null,
category varchar(50),
price numeric(10, 2) not null,
stock_quantity integer not null
);

create table Orders(
order_id serial primary key,
customer_id integer references Customers(customer_id),
order_date timestamp default current_timestamp,
total_amount numeric(10,2)
);

create table OrderDetails (
order_detail_id serial primary key,
order_id integer references Orders(order_id),
product_id integer references Products(product_id),
quantity integer not null,
unit_price numeric (10,2) not null
);


create table Suppliers (
supplier_id serial primary key,
suppliers_name varchar(100) not null,
contact_name varchar(50),
contact_email varchar(100),
contact_phone varchar(20)
);

create table ProductSuppliers (
product_id integer references Products(product_id),
supplier_id INTEGER references Suppliers(supplier_id),
primary key (product_id, supplier_id)
);


INSERT INTO Customers (first_name, last_name, email, phone)
VALUES 
('John', 'Doe', 'john.doe@example.com', '555-1234'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678');

INSERT INTO Products (product_name, category, price, stock_quantity)
VALUES
('Laptop', 'Electronics', 1200.00, 50),
('Smartphone', 'Electronics', 800.00, 100),
('Tablet', 'Electronics', 500.00, 75);

INSERT INTO Suppliers (supplier_name, contact_name, contact_email, contact_phone)
VALUES
('TechSupplier', 'Alice Johnson', 'alice.johnson@techsupplier.com', '555-8765'),
('GadgetCo', 'Bob Brown', 'bob.brown@gadgetco.com', '555-4321');

INSERT INTO ProductSuppliers (product_id, supplier_id)
VALUES
(1, 1), (2, 2), (3, 1);

INSERT INTO Orders (customer_id, total_amount)
VALUES
(1, 2000.00),
(2, 800.00);

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 800.00),
(2, 2, 1, 800.00);


-- Müşterilere ait toplam sipariş tutarını hesaplama
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(o.total_amount) AS total_spent
FROM 
    Customers c
JOIN 
    Orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id;

-- Her kategori için en çok satan ürünü getirme
SELECT 
    p.category,
    p.product_name,
    SUM(od.quantity) AS total_sold
FROM 
    Products p
JOIN 
    OrderDetails od ON p.product_id = od.product_id
GROUP BY 
    p.category, p.product_name
HAVING 
    SUM(od.quantity) = (
        SELECT 
            MAX(sales.total_sold)
        FROM (
            SELECT 
                category, 
                SUM(quantity) AS total_sold
            FROM 
                Products p
            JOIN 
                OrderDetails od ON p.product_id = od.product_id
            GROUP BY 
                category
        ) AS sales
        WHERE sales.category = p.category
    );

-- Stokta olmayan veya azalan ürünleri ve bunların tedarikçilerini getirme
SELECT 
    p.product_name,
    p.stock_quantity,
    s.supplier_name,
    s.contact_email
FROM 
    Products p
JOIN 
    ProductSuppliers ps ON p.product_id = ps.product_id
JOIN 
    Suppliers s ON ps.supplier_id = s.supplier_id
WHERE 
    p.stock_quantity < 10;

-- Son 30 gün içinde sipariş vermiş olan müşterilerin listesini getirme
SELECT 
    DISTINCT c.first_name, 
    c.last_name, 
    c.email
FROM 
    Customers c
JOIN 
    Orders o ON c.customer_id = o.customer_id
WHERE 
    o.order_date >= CURRENT_DATE - INTERVAL '30 days';

-- En çok ürün siparişi veren müşteriyi bulma işlemi
SELECT 
    c.first_name, 
    c.last_name, 
    COUNT(od.product_id) AS total_products_ordered
FROM 
    Customers c
JOIN 
    Orders o ON c.customer_id = o.customer_id
JOIN 
    OrderDetails od ON o.order_id = od.order_id
GROUP BY 
    c.customer_id
ORDER BY 
    total_products_ordered DESC
LIMIT 1;















