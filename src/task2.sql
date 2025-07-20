DECLARE @xm XML = 
'<PurchaseOrder PurchaseOrderNumber="99503" OrderDate="1999-10-20">
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
</PurchaseOrder>';

-- Извлекаем основные данные и формируем JSON
WITH Header AS (
    SELECT
        @xm.value('(/PurchaseOrder/@PurchaseOrderNumber)[1]', 'varchar(20)') AS PurchaseOrderNumber,
        @xm.value('(/PurchaseOrder/@OrderDate)[1]', 'date') AS OrderDate
),
Address AS (
    SELECT
        A.value('(Name)[1]', 'varchar(100)') AS Name,
        A.value('(Street)[1]', 'varchar(100)') AS Street,
        A.value('(City)[1]', 'varchar(100)') AS City,
        A.value('(State)[1]', 'varchar(10)') AS State,
        A.value('(Zip)[1]', 'varchar(20)') AS Zip,
        A.value('(Country)[1]', 'varchar(50)') AS Country,
        A.value('(@Type)[1]', 'varchar(20)') AS AddressType
    FROM @xm.nodes('(/PurchaseOrder/Address)[1]') AS T(A)
),
Items AS (
    SELECT
        I.value('(@PartNumber)', 'varchar(50)') AS PartNumber,
        I.value('(ProductName)[1]', 'varchar(100)') AS ProductName,
        I.value('(Quantity)[1]', 'int') AS Quantity,
        I.value('(USPrice)[1]', 'decimal(10,2)') AS USPrice,
        I.value('(Comment)[1]', 'varchar(200)') AS Comment,
        I.value('(ShipDate)[1]', 'date') AS ShipDate
    FROM @xm.nodes('/PurchaseOrder/Items/Item') AS T(I)
)

SELECT 
    h.PurchaseOrderNumber,
    h.OrderDate,
    (
        SELECT * 
        FROM Address 
        FOR JSON PATH
    ) AS Address,
    (
        SELECT * 
        FROM Items 
        FOR JSON PATH
    ) AS Items
FROM Header h
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
