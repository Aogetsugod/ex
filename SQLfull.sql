-- Create Tables for Образ плюс Database

-- Partners Table
CREATE TABLE Partners (
    PartnerID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(50),
    CompanyName NVARCHAR(100),
    LegalAddress NVARCHAR(200),
    INN NVARCHAR(20),
    DirectorFullName NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Logo VARBINARY(MAX),
    Rating INT,
    Discount DECIMAL(5,2) DEFAULT 0.00
);

-- Partner Sales Locations Table
CREATE TABLE PartnerSalesLocations (
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    PartnerID INT FOREIGN KEY REFERENCES Partners(PartnerID),
    Location NVARCHAR(200)
);

-- Partner Sales History Table
CREATE TABLE PartnerSalesHistory (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    PartnerID INT FOREIGN KEY REFERENCES Partners(PartnerID),
    ProductID INT, -- Will reference Products table later
    Quantity INT,
    SaleDate DATE,
    Amount DECIMAL(18,2)
);

-- Employees Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100),
    DateOfBirth DATE,
    PassportDetails NVARCHAR(100),
    BankDetails NVARCHAR(100),
    FamilyStatus NVARCHAR(50),
    HealthStatus NVARCHAR(50),
    Role NVARCHAR(50)
);

-- Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    PartnerID INT FOREIGN KEY REFERENCES Partners(PartnerID),
    OrderDate DATE,
    Status NVARCHAR(50),
    TotalAmount DECIMAL(18,2),
    PrepaymentAmount DECIMAL(18,2),
    FullPaymentDate DATE,
    DeliveryDate DATE
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Article NVARCHAR(50),
    Type NVARCHAR(50),
    Name NVARCHAR(100),
    Description NVARCHAR(MAX),
    Image VARBINARY(MAX),
    MinPartnerCost DECIMAL(18,2),
    PackagingLength DECIMAL(10,2),
    PackagingWidth DECIMAL(10,2),
    PackagingHeight DECIMAL(10,2),
    WeightWithoutPackaging DECIMAL(10,2),
    WeightWithPackaging DECIMAL(10,2),
    QualityCertificate VARBINARY(MAX),
    StandardNumber NVARCHAR(50),
    ProductionTime INT, -- in days
    CostPrice DECIMAL(18,2),
    WorkshopNumber INT,
    NumberOfPeople INT
);

-- Order Items Table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(18,2),
    ProductionDate DATE
);

-- Materials Table
CREATE TABLE Materials (
    MaterialID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(50),
    Name NVARCHAR(100),
    QuantityPerPackage INT,
    UnitOfMeasurement NVARCHAR(20),
    Description NVARCHAR(MAX),
    Image VARBINARY(MAX),
    Cost DECIMAL(18,2),
    StockQuantity INT,
    MinAllowableQuantity INT
);

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(50),
    Name NVARCHAR(100),
    INN NVARCHAR(20)
);

-- Material Suppliers Junction Table
CREATE TABLE MaterialSuppliers (
    MaterialSupplierID INT PRIMARY KEY IDENTITY(1,1),
    MaterialID INT FOREIGN KEY REFERENCES Materials(MaterialID),
    SupplierID INT FOREIGN KEY REFERENCES Suppliers(SupplierID)
);

-- Supply History Table
CREATE TABLE SupplyHistory (
    SupplyID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT FOREIGN KEY REFERENCES Suppliers(SupplierID),
    MaterialID INT FOREIGN KEY REFERENCES Materials(MaterialID),
    SupplyDate DATE,
    Quantity INT,
    Cost DECIMAL(18,2)
);

-- Product Materials Junction Table
CREATE TABLE ProductMaterials (
    ProductMaterialID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    MaterialID INT FOREIGN KEY REFERENCES Materials(MaterialID),
    QuantityRequired INT
);

-- Material Movements Table
CREATE TABLE MaterialMovements (
    MovementID INT PRIMARY KEY IDENTITY(1,1),
    MaterialID INT FOREIGN KEY REFERENCES Materials(MaterialID),
    MovementType NVARCHAR(50), -- e.g., receipt, reservation, issuance, write-off
    Quantity INT,
    MovementDate DATE,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- Product Movements Table
CREATE TABLE ProductMovements (
    MovementID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    MovementType NVARCHAR(50), -- e.g., receipt from production, shipment
    Quantity INT,
    MovementDate DATE,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- Access Cards Table
CREATE TABLE AccessCards (
    CardID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CardNumber NVARCHAR(50)
);

-- Doors Table
CREATE TABLE Doors (
    DoorID INT PRIMARY KEY IDENTITY(1,1),
    DoorName NVARCHAR(50),
    Location NVARCHAR(100)
);

-- Access Logs Table
CREATE TABLE AccessLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    CardID INT FOREIGN KEY REFERENCES AccessCards(CardID),
    AccessTime DATETIME,
    DoorID INT FOREIGN KEY REFERENCES Doors(DoorID)
);

-- Equipment Table
CREATE TABLE Equipment (
    EquipmentID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Description NVARCHAR(MAX)
);

-- Employee Equipment Permissions Table
CREATE TABLE EmployeeEquipmentPermissions (
    PermissionID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    EquipmentID INT FOREIGN KEY REFERENCES Equipment(EquipmentID),
    PermissionDate DATE
);

-- Update Foreign Key References in PartnerSalesHistory
ALTER TABLE PartnerSalesHistory
ADD CONSTRAINT FK_PartnerSalesHistory_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);

-- Insert Initial Data

-- Partners
INSERT INTO Partners (Type, CompanyName, LegalAddress, INN, DirectorFullName, Phone, Email, Rating, Discount)
VALUES 
    ('Дистрибьютор', 'ООО Партнер 1', 'г. Москва, ул. Ленина, 1', '1234567890', 'Иванов Иван Иванович', '+7(495)123-45-67', 'partner1@example.com', 5, 5.00),
    ('Розничный магазин', 'ООО Мебельный Мир', 'г. Санкт-Петербург, ул. Мира, 10', '0987654321', 'Сидоров Сидор Сидорович', '+7(812)987-65-43', 'mebelmir@example.com', 3, 0.00);

-- Partner Sales Locations
INSERT INTO PartnerSalesLocations (PartnerID, Location)
VALUES 
    (1, 'г. Москва, ТЦ "Север"'),
    (2, 'г. Санкт-Петербург, ТЦ "Юг"');

-- Employees
INSERT INTO Employees (FullName, DateOfBirth, PassportDetails, BankDetails, FamilyStatus, HealthStatus, Role)
VALUES 
    ('Петров Петр Петрович', '1980-01-01', '1234 567890', 'BANK123456', 'Женат', 'Здоров', 'Менеджер'),
    ('Смирнова Анна Ивановна', '1985-05-15', '4321 098765', 'BANK654321', 'Не замужем', 'Здорова', 'Мастер производства');

-- Suppliers
INSERT INTO Suppliers (Type, Name, INN)
VALUES 
    ('Поставщик сырья', 'ООО Сырье', '1122334455'),
    ('Поставщик фурнитуры', 'ООО Фурнитура', '5566778899');

-- Materials
INSERT INTO Materials (Type, Name, QuantityPerPackage, UnitOfMeasurement, Description, Cost, StockQuantity, MinAllowableQuantity)
VALUES 
    ('Дерево', 'Доска сосновая', 10, 'шт', 'Сосновая доска для мебели', 100.00, 100, 20),
    ('Фурнитура', 'Винты 5x50', 1000, 'шт', 'Винты для сборки мебели', 0.50, 5000, 1000);

-- Material Suppliers
INSERT INTO MaterialSuppliers (MaterialID, SupplierID)
VALUES 
    (1, 1),
    (2, 2);

-- Products
INSERT INTO Products (Article, Type, Name, Description, MinPartnerCost, PackagingLength, PackagingWidth, PackagingHeight, WeightWithoutPackaging, WeightWithPackaging, StandardNumber, ProductionTime, CostPrice, WorkshopNumber, NumberOfPeople)
VALUES 
    ('ART001', 'Стол', 'Стол офисный', 'Офисный стол из дерева', 5000.00, 120.00, 60.00, 75.00, 20.00, 22.00, 'ГОСТ 12345', 5, 3000.00, 1, 2),
    ('ART002', 'Стул', 'Стул офисный', 'Офисный стул с мягкой обивкой', 2000.00, 50.00, 50.00, 90.00, 8.00, 9.00, 'ГОСТ 54321', 3, 1200.00, 2, 1);

-- Product Materials
INSERT INTO ProductMaterials (ProductID, MaterialID, QuantityRequired)
VALUES 
    (1, 1, 5), -- Стол требует 5 досок
    (1, 2, 20), -- Стол требует 20 винтов
    (2, 1, 2), -- Стул требует 2 доски
    (2, 2, 10); -- Стул требует 10 винтов

-- Orders
INSERT INTO Orders (PartnerID, OrderDate, Status, TotalAmount, PrepaymentAmount)
VALUES 
    (1, '2023-10-01', 'Создана', 9500.00, 0.00),
    (2, '2023-10-02', 'Оплачена', 3800.00, 3800.00);

-- Order Items (with discount applied: Partner 1 has 5% discount)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice, ProductionDate)
VALUES 
    (1, 1, 2, 4750.00, '2023-10-06'), -- 5000 * 0.95
    (2, 2, 2, 1900.00, '2023-10-05'); -- 2000 * 0.95 (assuming discount applied)

-- Partner Sales History
INSERT INTO PartnerSalesHistory (PartnerID, ProductID, Quantity, SaleDate, Amount)
VALUES 
    (1, 1, 10, '2023-09-15', 47500.00),
    (2, 2, 5, '2023-09-20', 9500.00);

-- Supply History
INSERT INTO SupplyHistory (SupplierID, MaterialID, SupplyDate, Quantity, Cost)
VALUES 
    (1, 1, '2023-09-01', 100, 10000.00),
    (2, 2, '2023-09-02', 5000, 2500.00);

-- Material Movements
INSERT INTO MaterialMovements (MaterialID, MovementType, Quantity, MovementDate, EmployeeID)
VALUES 
    (1, 'Поступление', 100, '2023-09-01', 2),
    (2, 'Поступление', 5000, '2023-09-02', 2);

-- Product Movements
INSERT INTO ProductMovements (ProductID, MovementType, Quantity, MovementDate, EmployeeID, OrderID)
VALUES 
    (1, 'Поступление из производства', 2, '2023-10-06', 2, 1),
    (2, 'Отгрузка', 2, '2023-10-05', 1, 2);

-- Access Cards
INSERT INTO AccessCards (EmployeeID, CardNumber)
VALUES 
    (1, 'CARD001'),
    (2, 'CARD002');

-- Doors
INSERT INTO Doors (DoorName, Location)
VALUES 
    ('Вход в цех 1', 'Цех 1'),
    ('Главный вход', 'Офис');

-- Access Logs
INSERT INTO AccessLogs (CardID, AccessTime, DoorID)
VALUES 
    (1, '2023-10-01 08:00:00', 2),
    (2, '2023-10-01 08:05:00', 1);

-- Equipment
INSERT INTO Equipment (Name, Description)
VALUES 
    ('Станок ЧПУ', 'Станок для обработки дерева'),
    ('Сборочный конвейер', 'Конвейер для сборки мебели');

-- Employee Equipment Permissions
INSERT INTO EmployeeEquipmentPermissions (EmployeeID, EquipmentID, PermissionDate)
VALUES 
    (2, 1, '2023-01-01'),
    (2, 2, '2023-01-01');