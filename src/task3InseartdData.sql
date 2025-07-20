declare @xm xml = '<PurchaseOrder PurchaseOrderNumber="99503" OrderDate="1999-10-20">
  <Address Type="Shipping">
    <Name>Ellen Adams</Name>
    <Street>123 Maple Street</Street>
    <City>Mill Valley</City>
    <State>CA</State>
    <Zip>10999</Zip>
    <Country>USA</Country>
  </Address>
  <Address Type="Billing">
    <Name>Tai Yee</Name>
    <Street>8 Oak Avenue</Street>
    <City>Old Town</City>
    <State>PA</State>
    <Zip>95819</Zip>
    <Country>USA</Country>
  </Address>
  <Address Type="Post">
    <Name>Doll King</Name>
    <Street>8 Venue Street</Street>
    <City>Saints Hill</City>
    <State>PA</State>
    <Zip>89795</Zip>
    <Country>USA</Country>
  </Address>
  <DeliveryNotes>Please leave packages in shed by driveway.</DeliveryNotes>
  <Items>
    <Item PartNumber="872-AA">
      <ProductName>Lawnmower</ProductName>
      <Quantity>1</Quantity>
      <USPrice>148.95</USPrice>
      <Comment>Confirm this is electric</Comment>
    </Item>
    <Item PartNumber="926-AA">
      <ProductName>Baby Monitor</ProductName>
      <Quantity>2</Quantity>
      <USPrice>39.98</USPrice>
      <ShipDate>1999-05-21</ShipDate>
    </Item>
    <Item PartNumber="10000-AA">
      <ProductName>Godd thing</ProductName>
      <Quantity>06</Quantity>
	  <Conditions>
		<row>Humid</row>
		<row>Cold</row>
		<row>Sunless</row>
	  </Conditions>
      <USPrice>80.98</USPrice>
      <ShipDate>2009-01-28</ShipDate>
    </Item>
  </Items>
</PurchaseOrder>'



INSERT INTO PurchaseOrder (PurchaseOrderNumber, OrderDate, DeliveryNotes)
SELECT
    @xm.value('(/PurchaseOrder/@PurchaseOrderNumber)[1]', 'varchar(50)'),
    @xm.value('(/PurchaseOrder/@OrderDate)[1]', 'date'),
    @xm.value('(/PurchaseOrder/DeliveryNotes)[1]', 'nvarchar(max)');

INSERT INTO Address (PurchaseOrderNumber, Type, Name, Street, City, State, Zip, Country)
SELECT
    @xm.value('(/PurchaseOrder/@PurchaseOrderNumber)[1]', 'varchar(50)'),
    A.value('@Type', 'varchar(20)'),
    A.value('(Name)[1]', 'varchar(100)'),
    A.value('(Street)[1]', 'varchar(100)'),
    A.value('(City)[1]', 'varchar(100)'),
    A.value('(State)[1]', 'varchar(10)'),
    A.value('(Zip)[1]', 'varchar(20)'),
    A.value('(Country)[1]', 'varchar(50)')
FROM @xm.nodes('/PurchaseOrder/Address') AS T(A);


DECLARE @ItemIDTable TABLE (
    ItemID INT,
    PartNumber VARCHAR(50)
);

INSERT INTO Item (PurchaseOrderNumber, PartNumber, ProductName, Quantity, USPrice, Comment, ShipDate)
OUTPUT INSERTED.ItemID, INSERTED.PartNumber INTO @ItemIDTable(ItemID, PartNumber)
SELECT
    @xm.value('(/PurchaseOrder/@PurchaseOrderNumber)[1]', 'varchar(50)'),
    I.value('@PartNumber', 'varchar(50)'),
    I.value('(ProductName)[1]', 'varchar(100)'),
    I.value('(Quantity)[1]', 'int'),
    I.value('(USPrice)[1]', 'decimal(10,2)'),
    I.value('(Comment)[1]', 'nvarchar(200)'),
    I.value('(ShipDate)[1]', 'date')
FROM @xm.nodes('/PurchaseOrder/Items/Item') AS T(I);


-- Для каждого товара с Conditions
DECLARE @i INT = 1;
DECLARE @total INT = (SELECT COUNT(*) FROM @xm.nodes('/PurchaseOrder/Items/Item[Conditions]') AS X(I));
WHILE @i <= @total
BEGIN
    DECLARE @PartNumber VARCHAR(50);

    SELECT @PartNumber = I.value('@PartNumber', 'varchar(50)')
    FROM @xm.nodes('/PurchaseOrder/Items/Item[Conditions]') AS X(I)
    WHERE X.I.exist('./Conditions') = 1
    OFFSET (@i - 1) ROWS FETCH NEXT 1 ROWS ONLY;

    DECLARE @ItemID INT = (
        SELECT ItemID FROM @ItemIDTable WHERE PartNumber = @PartNumber
    );

    INSERT INTO ItemConditions (ItemID, ConditionValue)
    SELECT @ItemID,
           C.value('.', 'nvarchar(100)')
    FROM @xm.nodes('/PurchaseOrder/Items/Item[@PartNumber=sql:variable("@PartNumber")]/Conditions/row') AS T(C);

    SET @i = @i + 1;
END;


