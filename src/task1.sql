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

--Достаём атрибуты из PurchaseOrder 
SELECT 
    @xm.value('(/PurchaseOrder/@PurchaseOrderNumber)[1]', 'varchar(20)') as PurchaseOrderNumber,
    @xm.value('(/PurchaseOrder/@OrderDate)[1]', 'date') as OrderDate;

--Первое значение из списка Address
SELECT
    A.value('(Name)[1]', 'varchar(100)') as Name,
    A.value('(Street)[1]', 'varchar(100)') as Street,
    A.value('(City)[1]', 'varchar(100)') as City,
    A.value('(State)[1]', 'varchar(10)') as State,
    A.value('(Zip)[1]', 'varchar(20)') as Zip,
    A.value('(Country)[1]', 'varchar(50)') as Country,
    A.value('(@Type)[1]', 'varchar(20)') as AddressType
from @xm.nodes('(/PurchaseOrder/Address)[1]') as T(A) 

--Все итемы
SELECT
    I.value('(@PartNumber)', 'varchar(50)') as PartNumber,
    I.value('(ProductName)[1]', 'varchar(100)') as ProductName,
    I.value('(Quantity)[1]', 'int') as Quantity,
    I.value('(USPrice)[1]', 'decimal(10,2)') as USPrice,
    I.value('(Comment)[1]', 'varchar(200)') as Comment,
    I.value('(ShipDate)[1]', 'date') as ShipDate
from @xm.nodes('/PurchaseOrder/Items/Item') as T(I) 
