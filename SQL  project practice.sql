USE commercialdb;
-- Male employees with net salary ≥ 8000, ordered by seniority
SELECT * FROM employees;
SELECT 
    FIRST_NAME, 
    LAST_NAME, 
    TIMESTAMPDIFF(YEAR, BIRTH_DATE, CURDATE()) AS Age,
    TIMESTAMPDIFF(YEAR, HIRE_DATE, CURDATE()) AS Seniority
FROM EMPLOYEES
WHERE (SALARY + IFNULL(COMMISSION, 0)) >= 8000
-- AND GENDER = 'Male'  -- Only if a gender field exists
ORDER BY Seniority DESC;

SELECT * FROM suppliers;
-- Products meeting multiple criteria
SELECT 
  PRODUCT_REF,
  PRODUCT_NAME,
  SUPPLIER_int,
  UNITS_ON_ORDER,
  UNIT_PRICE
FROM 
  PRODUCTS
WHERE 
  QUANTITY LIKE '%bottle%'  -- C1: packaging in bottle(s)
  AND (SUBSTRING(PRODUCT_NAME, 3, 1) = 't' OR SUBSTRING(PRODUCT_NAME, 3, 1) = 'T')  -- C2: 3rd character is t/T
  AND SUPPLIER_int IN (1, 2, 3)  -- C3: supplier filter
  AND UNIT_PRICE BETWEEN 70 AND 200  -- C4: price range
  AND UNITS_ON_ORDER IS NOT NULL;  -- C5: units ordered must be specified
  
 -- customers in the same region as supplier 1 
 SELECT *
FROM CUSTOMERS
WHERE (COUNTRY, CITY, RIGHT(POSTAL_CODE, 3)) IN (
  SELECT COUNTRY, CITY, RIGHT(POSTAL_CODE, 3)
  FROM SUPPLIERS
  WHERE SUPPLIER_int = 1
);

-- For each order number between 10998 and 11003, do the following:  
-- Display the new discount rate, which should be 0% if the total order amount before discount (unit price * quantity) is between 0 and 2000, 5% if between 2001 and 10000, 10% if between 10001 and 40000, 15% if between 40001 and 80000, and 20% otherwise.
-- Display the message "apply old discount rate" if the order number is between 10000 and 10999, and "apply new discount rate" otherwise. The resulting table should display the columns: order number, new discount rate, and discount rate application note.

Select * from order_details
SELECT 
  ORDER_int,
  CASE
    WHEN SUM(UNIT_PRICE * QUANTITY) BETWEEN 0 AND 2000 THEN '0%'
    WHEN SUM(UNIT_PRICE * QUANTITY) BETWEEN 2001 AND 10000 THEN '5%'
    WHEN SUM(UNIT_PRICE * QUANTITY) BETWEEN 10001 AND 40000 THEN '10%'
    WHEN SUM(UNIT_PRICE * QUANTITY) BETWEEN 40001 AND 80000 THEN '15%'
    ELSE '20%'
  END AS NEW_DISCOUNT_RATE,
  CASE 
    WHEN ORDER_int BETWEEN 10000 AND 10999 THEN 'apply old discount rate'
    ELSE 'apply new discount rate'
  END AS DISCOUNT_NOTE
FROM ORDER_DETAILS
WHERE ORDER_int BETWEEN 10998 AND 11003
GROUP BY ORDER_int;

-- Display suppliers of beverage products. The resulting table should display the columns: supplier number, company, address, and phone number.
SELECT 
  S.SUPPLIER_int,
  S.COMPANY,
  S.ADDRESS,
  S.PHONE
FROM SUPPLIERS S
JOIN PRODUCTS P ON S.SUPPLIER_int = P.SUPPLIER_int
JOIN CATEGORIES C ON P.CATEGORY_CODE = C.CATEGORY_CODE
WHERE C.CATEGORY_NAME = 'Beverages';

-- Display customers from Berlin who have ordered at most 1 (0 or 1) dessert product. The resulting table should display the column: customer code.
SELECT CUSTOMER_CODE
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.CUSTOMER_CODE = O.CUSTOMER_CODE
LEFT JOIN ORDER_DETAILS OD ON O.ORDER_NUMBER = OD.ORDER_NUMBER
LEFT JOIN PRODUCTS P ON OD.PRODUCT_REF = P.PRODUCT_REF
LEFT JOIN CATEGORIES CAT ON P.CATEGORY_CODE = CAT.CATEGORY_CODE
WHERE C.CITY = 'Berlin' AND (CAT.CATEGORY_NAME = 'Desserts' OR CAT.CATEGORY_NAME IS NULL)
GROUP BY C.CUSTOMER_CODE
HAVING COUNT(DISTINCT CASE WHEN CAT.CATEGORY_NAME = 'Desserts' THEN OD.ORDER_NUMBER END) <= 1;

-- Display customers who reside in France and the total amount of orders they placed every Monday in April 1998 (considering customers who haven't placed any orders yet). The resulting table should display the columns: customer number, company name, phone number, total amount, and country.

SELECT 
  C.CUSTOMER_CODE,
  C.COMPANY,
  C.PHONE,
  IFNULL(SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT)), 0) AS TOTAL_AMOUNT,
  C.COUNTRY
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.CUSTOMER_CODE = O.CUSTOMER_CODE 
  AND YEAR(O.ORDER_DATE) = 1998 
  AND MONTH(O.ORDER_DATE) = 4
  AND DAYOFWEEK(O.ORDER_DATE) = 2
LEFT JOIN ORDER_DETAILS OD ON O.ORDER_int = OD.ORDER_int
WHERE C.COUNTRY = 'France'
GROUP BY C.CUSTOMER_CODE;


-- Display customers who have ordered all products. The resulting table should display the columns: customer code, company name, and telephone number.

SELECT 
  C.CUSTOMER_CODE,
  C.COMPANY,
  C.PHONE
FROM CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_CODE = O.CUSTOMER_CODE
JOIN ORDER_DETAILS OD ON O.ORDER_int = OD.ORDER_int
GROUP BY C.CUSTOMER_CODE
HAVING COUNT(DISTINCT OD.PRODUCT_REF) = (
  SELECT COUNT(*) FROM PRODUCTS
);

--  Display for each customer from France the number of orders they have placed. The resulting table should display the columns: customer code and number of orders
SELECT 
CUSTOMER_CODE,
  COUNT(ORDER_int) AS NUMBER_OF_ORDERS
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.CUSTOMER_CODE = O.CUSTOMER_CODE
WHERE C.COUNTRY = 'France'
GROUP BY  CUSTOMER_CODE;

-- Display the number of orders placed in 1996, the number of orders placed in 1997, and the difference between these two numbers. The resulting table should display the columns: orders in 1996, orders in 1997, and Difference.
SELECT 
  SUM(YEAR(ORDER_DATE) = 1996) AS ORDERS_1996,
  SUM(YEAR(ORDER_DATE) = 1997) AS ORDERS_1997,
  SUM(YEAR(ORDER_DATE) = 1997) - SUM(YEAR(ORDER_DATE) = 1996) AS DIFFERENCE
FROM ORDERS;


