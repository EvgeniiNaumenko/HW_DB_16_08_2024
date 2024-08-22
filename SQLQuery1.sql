CREATE DATABASE Icecream
GO
USE Icecream
GO
CREATE TABLE IceCream (
    ID INT PRIMARY KEY,
    Name NVARCHAR(255),
    Price DECIMAL(10, 2),
    StockQuantity INT
);
CREATE TABLE Orders (
    ID INT PRIMARY KEY,
    OrderDate DATETIME,
    Quantity INT,
    TotalCost DECIMAL(10, 2)
);
CREATE TABLE OrderHistory (
    ID INT PRIMARY KEY,
    OrderID INT,
    IceCreamID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(ID),
    FOREIGN KEY (IceCreamID) REFERENCES IceCream(ID)
);
GO
--Тригер, який відслідковує кількість порцій морозива, які залишилися на складі після кожного замовлення.
CREATE TRIGGER TrackStockAfterOrderHistory
ON OrderHistory
AFTER INSERT
AS
BEGIN
    UPDATE IceCream
    SET StockQuantity = StockQuantity - I.Quantity
    FROM IceCream AS IC
    INNER JOIN inserted AS I ON IC.ID = I.IceCreamID;
END
GO
--Тригер, який обчислює загальну вартість кожного замовлення та зберігає її в таблиці "Замовлення".
CREATE TRIGGER CalculateTotalCost
ON OrderHistory
AFTER INSERT
AS
BEGIN
    UPDATE Orders
    SET TotalCost = (
        SELECT SUM(OH.Quantity * ic.Price)
        FROM OrderHistory AS OH
        INNER JOIN IceCream AS IC ON OH.IceCreamID = IC.ID
        WHERE OH.OrderID = Orders.ID
    )
    FROM Orders
    INNER JOIN inserted AS I ON Orders.ID = I.OrderID;
END

GO
--Тригер, який автоматично оновлює кількість порцій морозива на складі після отримання нового партії товару.

CREATE TRIGGER UpdateStockAfterOrder
ON Orders
AFTER INSERT
AS
BEGIN
    UPDATE IceCream
    SET StockQuantity = StockQuantity - OH.Quantity
    FROM IceCream IC
    INNER JOIN OrderHistory AS OH ON IC.ID = OH.IceCreamID
    INNER JOIN inserted AS I ON I.ID = OH.OrderID
    WHERE I.ID = OH.OrderID;
END
GO