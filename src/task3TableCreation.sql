-- Главная таблица заказа
CREATE TABLE PurchaseOrder (
    PurchaseOrderNumber VARCHAR(50) PRIMARY KEY,
    OrderDate DATE,
    DeliveryNotes NVARCHAR(MAX)
);

-- Адреса, связанные с заказом
CREATE TABLE Address (
    AddressID INT IDENTITY PRIMARY KEY,
    PurchaseOrderNumber VARCHAR(50),
    Type VARCHAR(20),
    Name VARCHAR(100),
    Street VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(10),
    Zip VARCHAR(20),
    Country VARCHAR(50),
    FOREIGN KEY (PurchaseOrderNumber) REFERENCES PurchaseOrder(PurchaseOrderNumber)
);

-- Товары, связанные с заказом
CREATE TABLE Item (
    ItemID INT IDENTITY PRIMARY KEY,
    PurchaseOrderNumber VARCHAR(50),
    PartNumber VARCHAR(50),
    ProductName VARCHAR(100),
    Quantity INT,
    USPrice DECIMAL(10, 2),
    Comment NVARCHAR(200),
    ShipDate DATE,
    FOREIGN KEY (PurchaseOrderNumber) REFERENCES PurchaseOrder(PurchaseOrderNumber)
);

-- Условия для товаров
CREATE TABLE ItemConditions (
    ConditionID INT IDENTITY PRIMARY KEY,
    ItemID INT,
    ConditionValue NVARCHAR(100),
    FOREIGN KEY (ItemID) REFERENCES Item(ItemID)
);
