SET ECHO ON
SPOOL C:\Users\Deric\workspace\COMP2714_ASN03\Asn03_MccaddenD.txt
--
-- ---------------------------------------------------------
--
--  COMP 2714 
--  SET 2D
--  Assignment Asn03
--  Mccadden, Deric    A00751277
--  email: dmccadden@my.bcit.ca
--
-- ---------------------------------------------------------
--  BUILD DATABASE
--  START C:\Users\Deric\workspace\COMP2714_ASN03\Asn3SetupHotels.sql
--
--  ASSIGNMENT
--  START C:\Users\Deric\workspace\COMP2714_ASN03\Asn03_MccaddenD.sql
-- ---------------------------------------------------------
--
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';
--
SELECT SYSDATE
FROM DUAL;
--
--Q1--------------------------------------------------------
--What is the average price of a room in london?
--A)------
--using join?
SELECT AVG(r.price) Average
FROM Room r 
  INNER JOIN Hotel h ON h.hotelNo = r.hotelNo
WHERE h.hotelAddress LIKE'%London%'
; 
--A)------
--using IN?
SELECT AVG(price) Average
FROM Room
WHERE hotelNo IN (
  SELECT hotelNo
  FROM Hotel
  WHERE hotelAddress LIKE'%London%'
)
;
--
--Q2--------------------------------------------------------
--How many different guests have made bookings in 2016-02? 
--for each hotel, hotel name order.
SELECT h.hotelName, COUNT(DISTINCT b.guestNo) Distinct_Guests
FROM Booking b
  JOIN Hotel h ON h.hotelNo = b.hotelNo
WHERE (dateTo IS NULL OR dateTo >= DATE'2016-02-01') 
  AND dateFrom < DATE'2016-03-01'
GROUP BY h.hotelName
ORDER BY h.hotelName
;
--
--Q3--------------------------------------------------------
--List the details of all rooms at the Grosvenor Hotel, 
--including the name of the guest staying in the room.
--List in hotelNo, roomNo roder
SELECT h.hotelName, 
       r.roomNo, 
       r.type, 
       r.price, 
       g.guestname AS Booked_By
FROM Room r
  INNER JOIN (
    SELECT *
    FROM Hotel
    WHERE hotelName LIKE '%Grosvenor%'
  ) h ON r.hotelNo = h.hotelNo
  LEFT JOIN (
    SELECT * 
    FROM Booking 
    WHERE dateFrom <= DATE'2016-02-01' 
      AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01')
  ) b 
    ON h.hotelNo = b.hotelNo AND r.roomNo = b.roomNo
  LEFT JOIN Guest g ON b.guestNo = g.guestNo
ORDER BY r.hotelNo, r.roomNo
; 
--
--Q4--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo oder
--use NOT IN
SELECT *
FROM Room r
WHERE roomNo NOT IN (
  SELECT roomNo
  FROM Booking
  WHERE dateFrom <= DATE'2016-02-01' 
    AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01')
)
AND hotelNo NOT IN (
  SELECT HotelNo
  FROM Hotel
  WHERE hotelName NOT LIKE'%Grosvenor%'
)
ORDER BY r.hotelNo, r.roomNo
;  
--
--Q5--------------------------------------------------------
--not exists
SELECT *
FROM Room r
WHERE NOT EXISTS (
  SELECT *
    FROM Booking b
    WHERE b.roomNo = r.roomNo
     AND dateFrom <= DATE'2016-02-01' 
     AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01'))
AND NOT EXISTS (
  SELECT *
    FROM Hotel h
    WHERE h.hotelNo = r.hotelNo
      AND h.hotelName NOT LIKE'%Grosvenor%')
ORDER BY r.hotelNo, r.roomNo
;
--
--Q6--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo roder
--use LEFT JOIN
SELECT h.hotelName, r.roomNo, r.type, r.price
FROM Room r
  LEFT JOIN Hotel h ON h.hotelNo = r.hotelNo
  LEFT JOIN (
    SELECT *
    FROM Booking
    WHERE dateFrom <= DATE'2016-02-01' 
    AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01')
  ) b ON b.hotelNo = h.hotelNo 
                      AND b.roomNo = r.roomNo
  LEFT JOIN Guest g ON g.guestNo = b.guestNo
WHERE g.guestNo is NULL
AND h.hotelName LIKE '%Grosvenor%'
ORDER BY r.hotelNo, r.roomNo
; 
--
--Q7--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo roder
--use MINUS
SELECT r.hotelNo, r.roomNo, r.type, r.price
FROM Room r, Booking b
WHERE r.hotelNo = b.hotelNo 
AND b.dateFrom <= DATE'2016-02-01' 
AND (b.dateTo IS NULL OR b.dateTo >= DATE'2016-02-01')
  MINUS (
    SELECT r.hotelNo, r.roomNo, r.type, r.price
    FROM Room r, Hotel h
    WHERE r.hotelNo = h.hotelNo 
    AND h.hotelName NOT LIKE '%Grosvenor%'
  )
;
--
--Q8--------------------------------------------------------
--What is the average number of bookings for each hotel in 2016-2
SELECT AVG(numBookings) AS Average
FROM (
  SELECT COUNT(b.guestNo) AS numBookings
  FROM Hotel h
  JOIN Booking b
    ON h.hotelNo = b.hotelNo
  GROUP BY h.hotelNo
)
;
--
--Q9--------------------------------------------------------
--WHat is the lost income from unocupied rooms at each hotels today?? 
--2016-02-01
--HotelNo, hotelName, LostIncome  in hotelNo order.
SELECT r.hotelNo, 
       h.hotelName, 
       SUM(r.price) AS LostIncome
FROM Room r
INNER JOIN Hotel h
  ON r.hotelNo = h.hotelNo
LEFT JOIN (
  SELECT *
  FROM Booking
    WHERE dateFrom <= DATE'2016-02-01'
    AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01')
) b ON r.hotelNo = b.hotelNo
    AND b.roomNo = r.roomNo
GROUP BY r.hotelNo, h.hotelName
ORDER BY hotelNo
;
--
--Q10--------------------------------------------------------
--Create a view containing the account for each guest at grosenvor hotel
--Use 2016-02-01 as date, and guestAccount as view name
--
CREATE VIEW guestAccount AS
SELECT r.roomNo AS Room, 
       g.guestName AS Name, 
       dateFrom AS CheckIn, 
       dateTo AS CheckOut
FROM Guest g=
INNER JOIN (
  SELECT *
  FROM Booking b
  INNER JOIN (
    SELECT hotelName
    FROM Hotel
    WHERE hotelName LIKE '%Grosvenor Hotel%'
  )  ON hotelNo = b.hotelNo
) bh ON bh.hotelNo = g.hotelNo
LEFT JOIN Room r ON h.hotelNo = r.hotelNo
;
SELECT *
FROM guestAccount
;
DROP VIEW guestAccount;
--
--END--------------------------------------------------------
--
SPOOL OFF