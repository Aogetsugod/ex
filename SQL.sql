-- Creating database for warehouse material management
CREATE DATABASE warehouse_db;
GO

USE warehouse_db;
GO

-- Creating table for material types
CREATE TABLE material_types (
    material_type_id INT IDENTITY(1,1) PRIMARY KEY,
    material_type_name NVARCHAR(50) NOT NULL UNIQUE,
    loss_percentage DECIMAL(5,2) NOT NULL CHECK (loss_percentage >= 0)
);
GO

-- Creating table for materials
CREATE TABLE materials (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
    material_name NVARCHAR(100) NOT NULL UNIQUE,
    material_type_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity DECIMAL(10,2) NOT NULL CHECK (stock_quantity >= 0),
    min_quantity DECIMAL(10,2) NOT NULL CHECK (min_quantity >= 0),
    package_quantity DECIMAL(10,2) NOT NULL CHECK (package_quantity > 0),
    unit_of_measure NVARCHAR(20) NOT NULL,
    FOREIGN KEY (material_type_id) REFERENCES material_types(material_type_id)
);
GO

-- Creating table for product types
CREATE TABLE product_types (
    product_type_id INT IDENTITY(1,1) PRIMARY KEY,
    product_type_name NVARCHAR(50) NOT NULL UNIQUE,
    type_coefficient DECIMAL(5,2) NOT NULL CHECK (type_coefficient > 0)
);
GO

-- Creating table for products
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_type_id INT NOT NULL,
    product_name NVARCHAR(100) NOT NULL,
    article_number NVARCHAR(20) NOT NULL UNIQUE,
    min_partner_price DECIMAL(10,2) NOT NULL CHECK (min_partner_price >= 0),
    FOREIGN KEY (product_type_id) REFERENCES product_types(product_type_id)
);
GO

-- Creating junction table for material-product relationships
CREATE TABLE material_products (
    material_id INT NOT NULL,
    product_id INT NOT NULL,
    required_quantity DECIMAL(10,2) NOT NULL CHECK (required_quantity >= 0),
    PRIMARY KEY (material_id, product_id),
    FOREIGN KEY (material_id) REFERENCES materials(material_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- Inserting data into material_types from Material_type_import.xlsx
INSERT INTO material_types (material_type_name, loss_percentage)
VALUES
    ('Дерево', 0.55),
    ('Древесная плита', 0.30),
    ('Текстиль', 0.15),
    ('Стекло', 0.45),
    ('Металл', 0.10),
    ('Пластик', 0.05);
GO

-- Inserting data into product_types from Product_type_import.xlsx
INSERT INTO product_types (product_type_name, type_coefficient)
VALUES
    ('Кресла', 1.95),
    ('Полки', 2.50),
    ('Стеллажи', 4.35),
    ('Столы', 5.50),
    ('Тумбы', 7.60),
    ('Шкафы', 6.72);
GO

-- Inserting data into materials from Materials_import.xlsx
INSERT INTO materials (material_name, material_type_id, unit_price, stock_quantity, min_quantity, package_quantity, unit_of_measure)
SELECT 
    m.[Наименование материала],
    mt.material_type_id,
    CAST(m.[Цена единицы материала] AS DECIMAL(10,2)),
    CAST(m.[Количество на складе] AS DECIMAL(10,2)),
    CAST(m.[Минимальное количество] AS DECIMAL(10,2)),
    CAST(m.[Количество в упаковке] AS DECIMAL(10,2)),
    m.[Единица измерения]
FROM (
    VALUES
        ('Цельный массив дерева Дуб 1000х600 мм', 'Дерево', 7450.00, 1500.00, 500.00, 7.20, 'м²'),
        ('Клееный массив дерева Дуб 1000х600 мм', 'Дерево', 4520.00, 300.00, 500.00, 7.20, 'м²'),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Дерево', 2500.00, 2000.00, 1500.00, 19.80, 'м²'),
        ('Фанера 2200х1000 мм', 'Древесная плита', 2245.00, 450.00, 1000.00, 52.80, 'м²'),
        ('ДСП 2750х1830 мм', 'Древесная плита', 529.60, 1010.00, 1200.00, 181.08, 'м²'),
        ('МДФ 2070х1400 мм', 'Древесная плита', 417.24, 1550.00, 1000.00, 87.00, 'м²'),
        ('ДВП 2440х2050 мм', 'Древесная плита', 187.00, 1310.00, 1000.00, 190.00, 'м²'),
        ('ХДФ 2800x2070 мм', 'Древесная плита', 370.96, 1400.00, 1200.00, 90.00, 'м²'),
        ('Экокожа 140 см', 'Текстиль', 1600.00, 1200.00, 1500.00, 100.00, 'пог.м'),
        ('Велюр 140 см', 'Текстиль', 1300.00, 1300.00, 1500.00, 100.00, 'пог.м'),
        ('Шенилл 140 см', 'Текстиль', 620.00, 950.00, 1500.00, 100.00, 'пог.м'),
        ('Рогожка 140 см', 'Текстиль', 720.00, 960.00, 1500.00, 100.00, 'пог.м'),
        ('Закаленное стекло 2600х1800 мм', 'Стекло', 1148.00, 1000.00, 500.00, 196.56, 'м²'),
        ('Металлокаркас для стула', 'Металл', 1100.00, 300.00, 250.00, 5.00, 'шт'),
        ('Металлокаркас каркас из профиля с траверсами для стола', 'Металл', 6700.00, 100.00, 100.00, 1.00, 'шт'),
        ('Колесо для мебели поворотное', 'Пластик', 10.59, 1500.00, 1000.00, 500.00, 'шт'),
        ('Газ-лифт', 'Металл', 730.00, 500.00, 250.00, 5.00, 'шт'),
        ('Металлическая крестовина для офисных кресел', 'Металл', 2700.00, 500.00, 250.00, 5.00, 'шт'),
        ('Пластиковый комплект для стула', 'Пластик', 900.00, 300.00, 250.00, 100.00, 'шт'),
        ('Кромка ПВХ', 'Пластик', 35.80, 1500.00, 1000.00, 100.00, 'м')
) AS m ([Наименование материала], [Тип материала], [Цена единицы материала], [Количество на складе], [Минимальное количество], [Количество в упаковке], [Единица измерения])
JOIN material_types mt ON m.[Тип материала] = mt.material_type_name;
GO

-- Inserting data into products from Products_import.xlsx
INSERT INTO products (product_type_id, product_name, article_number, min_partner_price)
SELECT 
    pt.product_type_id,
    p.[Наименование продукции],
    p.[Артикул],
    CAST(p.[Минимальная стоимость для партнера] AS DECIMAL(10,2))
FROM (
    VALUES
        ('Кресла', 'Кресло детское цвет Белый и Розовый', '3028272', 15324.99),
        ('Кресла', 'Кресло офисное цвет Черный', '3018556', 21443.99),
        ('Кресла', 'Кресло эргономичное цвет Темно-коричневый', '3549922', 24760.00),
        ('Полки', 'Полка настольная', '7028048', 2670.89),
        ('Стеллажи', 'Стеллаж для документов цвет Дуб светлый 854х445х2105 мм', '5759324', 24899.00),
        ('Стеллажи', 'Стеллаж цвет Белый с ящиками 854х445х2105 мм', '5259474', 16150.00),
        ('Стеллажи', 'Стеллаж цвет Орех 400х370х2000 мм', '5118827', 2860.00),
        ('Столы', 'Стол для ноутбука на металлокаркасе 800х600х123 мм', '1029784', 14690.00),
        ('Столы', 'Стол компьютерный 700х600х500 мм', '1028248', 4105.89),
        ('Столы', 'Стол компьютерный на металлокаркасе 1400х600х750 мм', '1130981', 13899.00),
        ('Столы', 'Стол письменный 1100x750x600 мм', '1188827', 5148.00),
        ('Столы', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', '1029272', 15325.00),
        ('Столы', 'Стол руководителя письменный цвет Венге 1600x800x764 мм', '1016662', 43500.90),
        ('Столы', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', '1658953', 132500.00),
        ('Тумбы', 'Тумба выкатная 3 ящика', '6033136', 3750.00),
        ('Тумбы', 'Тумба офисная для оргтехники', '6115947', 2450.00),
        ('Стеллажи', 'Узкий пенал стеллаж 5 полок цвет Орех 364х326x2000 мм', '5559898', 8348.00),
        ('Шкафы', 'Шкаф для книг 800x420x2000 мм', '4159043', 23390.99),
        ('Шкафы', 'Шкаф для одежды цвет Венге 602x420x2000 мм', '4758375', 12035.00),
        ('Шкафы', 'Шкаф-витрина 2 ящика 800x420x2000 мм', '4588376', 31991.00)
) AS p ([Тип продукции], [Наименование продукции], [Артикул], [Минимальная стоимость для партнера])
JOIN product_types pt ON p.[Тип продукции] = pt.product_type_name;
GO

-- Inserting data into material_products from Material_products__import.xlsx with duplicate handling
INSERT INTO material_products (material_id, product_id, required_quantity)
SELECT 
    m.material_id,
    p.product_id,
    SUM(CAST(mp.[Необходимое количество материала] AS DECIMAL(10,2))) AS required_quantity
FROM (
    VALUES
        ('Фанера 2200х1000 мм', 'Кресло детское цвет Белый и Розовый', 0.85),
        ('Велюр 140 см', 'Кресло детское цвет Белый и Розовый', 1.50),
        ('Шенилл 140 см', 'Кресло детское цвет Белый и Розовый', 1.50),
        ('Рогожка 140 см', 'Кресло детское цвет Белый и Розовый', 1.50),
        ('Металлокаркас для стула', 'Кресло детское цвет Белый и Розовый', 1.00),
        ('Колесо для мебели поворотное', 'Кресло детское цвет Белый и Розовый', 5.00),
        ('Газ-лифт', 'Кресло детское цвет Белый и Розовый', 1.00),
        ('Металлическая крестовина для офисных кресел', 'Кресло детское цвет Белый и Розовый', 1.00),
        ('Пластиковый комплект для стула', 'Кресло детское цвет Белый и Розовый', 1.00),
        ('Фанера 2200х1000 мм', 'Кресло офисное цвет Черный', 1.25),
        ('Экокожа 140 см', 'Кресло офисное цвет Черный', 3.04),
        ('Шенилл 140 см', 'Кресло офисное цвет Черный', 1.50),
        ('Рогожка 140 см', 'Кресло офисное цвет Черный', 2.50),
        ('Металлокаркас для стула', 'Кресло офисное цвет Черный', 1.00),
        ('Колесо для мебели поворотное', 'Кресло офисное цвет Черный', 5.00),
        ('Газ-лифт', 'Кресло офисное цвет Черный', 1.00),
        ('Металлическая крестовина для офисных кресел', 'Кресло офисное цвет Черный', 1.00),
        ('Пластиковый комплект для стула', 'Кресло офисное цвет Черный', 1.00),
        ('Фанера 2200х1000 мм', 'Кресло эргономичное цвет Темно-коричневый', 1.85),
        ('Экокожа 140 см', 'Кресло эргономичное цвет Темно-коричневый', 4.22),
        ('Велюр 140 см', 'Кресло эргономичное цвет Темно-коричневый', 1.50),
        ('Металлокаркас для стула', 'Кресло эргономичное цвет Темно-коричневый', 1.00),
        ('Колесо для мебели поворотное', 'Кресло эргономичное цвет Темно-коричневый', 5.00),
        ('Газ-лифт', 'Кресло эргономичное цвет Темно-коричневый', 1.00),
        ('Металлическая крестовина для офисных кресел', 'Кресло эргономичное цвет Темно-коричневый', 1.00),
        ('Пластиковый комплект для стула', 'Кресло эргономичное цвет Темно-коричневый', 1.00),
        ('ДСП 2750х1830 мм', 'Полка настольная', 3.33),
        ('Кромка ПВХ', 'Полка настольная', 6.00),
        ('Клееный массив дерева Дуб 1000х600 мм', 'Стеллаж для документов цвет Дуб светлый 854х445х2105 мм', 2.90),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Стеллаж для документов цвет Дуб светлый 854х445х2105 мм', 1.70),
        ('МДФ 2070х1400 мм', 'Стеллаж для документов цвет Дуб светлый 854х445х2105 мм', 2.70),
        ('ХДФ 2800x2070 мм', 'Стеллаж для документов цвет Дуб светлый 854х445х2105 мм', 1.80),
        ('Клееный массив дерева Дуб 1000х600 мм', 'Стеллаж цвет Белый с ящиками 854х445х2105 мм', 1.70),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Стеллаж цвет Белый с ящиками 854х445х2105 мм', 1.60),
        ('ХДФ 2800x2070 мм', 'Стеллаж цвет Белый с ящиками 854х445х2105 мм', 1.80),
        ('ДСП 2750х1830 мм', 'Стеллаж цвет Орех 400х370х2000 мм', 2.00),
        ('ДВП 1400х693', 'Стеллаж цвет Орех 400х370х2000 мм', 0.80),
        ('Кромка ПВХ', 'Стеллаж цвет Орех 400х370х2000 мм', 7.00),
        ('МДФ 2070х1400 мм', 'Стол для ноутбука на металлокаркасе 800х600х123 мм', 5.95),
        ('Металлокаркас каркас из профиля с траверсами для стола', 'Стол для ноутбука на металлокаркасе 800х600х123 мм', 1.00),
        ('ДСП 2750х1830 мм', 'Стол компьютерный 700х600х500 мм', 4.30),
        ('Кромка ПВХ', 'Стол компьютерный 700х600х500 мм', 8.60),
        ('МДФ 2070х1400 мм', 'Стол компьютерный на металлокаркасе 1400х600х750 мм', 7.65),
        ('ХДФ 2800x2070 мм', 'Стол компьютерный на металлокаркасе 1400х600х750 мм', 1.05),
        ('Металлокаркас каркас из профиля с траверсами для стола', 'Стол компьютерный на металлокаркасе 1400х600х750 мм', 1.00),
        ('ДСП 2750х1830 мм', 'Стол письменный 1100x750x600 мм', 6.40),
        ('Кромка ПВХ', 'Стол письменный 1100x750x600 мм', 6.20),
        ('Фанера 2200х1000 мм', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', 2.55),
        ('ДСП 2750х1830 мм', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', 5.20),
        ('ДСП 2750х1830 мм', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', 5.22),
        ('ДВП 1400х691', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', 3.59),
        ('Кромка ПВХ', 'Стол письменный с тумбочкой 4 ящика 1100x750x600 мм', 9.40),
        ('Цельный массив дерева Дуб 1000х600 мм', 'Стол руководителя письменный цвет Венге 1600x800x764 мм', 3.50),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Стол руководителя письменный цвет Венге 1600x800x764 мм', 1.50),
        ('ХДФ 2800x2070 мм', 'Стол руководителя письменный цвет Венге 1600x800x764 мм', 2.10),
        ('Закаленное стекло', 'Стол руководителя письменный цвет Венге 1600x800x764 мм', 0.80),
        ('Цельный массив дерева Дуб 1000х600 мм', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 7.70),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 6.50),
        ('ДСП 2750х1830 мм', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 4.50),
        ('МДФ 2070х1400 мм', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 5.70),
        ('ХДФ 2800x2070 мм', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 2.30),
        ('Экокожа 140 см', 'Стол руководителя письменный цвет Орех темный 2300x1000x750 мм', 1.74),
        ('ДСП 2750х1830 мм', 'Тумба выкатная 3 ящика', 4.20),
        ('ДВП 1400х690', 'Тумба выкатная 3 ящика', 2.21),
        ('Колесо для мебели поворотное', 'Тумба выкатная 3 ящика', 4.00),
        ('Кромка ПВХ', 'Тумба выкатная 3 ящика', 6.50),
        ('Клееный массив дерева Дуб 1000х600 мм', 'Тумба офисная для оргтехники', 0.40),
        ('Колесо для мебели поворотное', 'Тумба офисная для оргтехники', 4.00),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Узкий пенал стеллаж 5 полок цвет Орех 364х326x2000 мм', 0.70),
        ('ДСП 2750х1830 мм', 'Узкий пенал стеллаж 5 полок цвет Орех 364х326x2000 мм', 7.65),
        ('ДВП 1400х694', 'Узкий пенал стеллаж 5 полок цвет Орех 364х326x2000 мм', 0.80),
        ('Кромка ПВХ', 'Узкий пенал стеллаж 5 полок цвет Орех 364х326x2000 мм', 6.30),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Шкаф для книг 800x420x2000 мм', 3.20),
        ('Фанера 2200х1000 мм', 'Шкаф для книг 800x420x2000 мм', 3.50),
        ('ДВП 1400х692', 'Шкаф для книг 800x420x2000 мм', 1.60),
        ('Закаленное стекло', 'Шкаф для книг 800x420x2000 мм', 1.60),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Шкаф для одежды цвет Венге 602x420x2000 мм', 1.30),
        ('ДСП 2750х1830 мм', 'Шкаф для одежды цвет Венге 602x420x2000 мм', 8.20),
        ('ХДФ 2800x2070 мм', 'Шкаф для одежды цвет Венге 602x420x2000 мм', 1.30),
        ('Цельный массив дерева Дуб 1000х600 мм', 'Шкаф-витрина 2 ящика 800x420x2000 мм', 1.80),
        ('Шпон облицовочный Дуб натуральный 2750х480 мм', 'Шкаф-витрина 2 ящика 800x420x2000 мм', 3.50),
        ('ХДФ 2800x2070 мм', 'Шкаф-витрина 2 ящика 800x420x2000 мм', 1.65),
        ('Закаленное стекло', 'Шкаф-витрина 2 ящика 800x420x2000 мм', 1.60)
) AS mp ([Наименование материала], [Продукция], [Необходимое количество материала])
JOIN materials m ON mp.[Наименование материала] = m.material_name
JOIN products p ON mp.[Продукция] = p.product_name
GROUP BY m.material_id, p.product_id;
GO