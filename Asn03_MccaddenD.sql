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
--  START C:\Users\Deric\workspace\COMP2714_ASN03\Asn03_MccaddenD.sql
--
--  build database
--  START C:\Users\Deric\workspace\COMP2714_ASN03\Asn3SetupHotels.sql
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
INNER JOIN Hotel h
  ON r.hotelNo = h.hotelNo
; 
--A)------
--using IN?
SELECT AVG(r.price) Average
FROM Room r, Hotel h
WHERE r.hotelNo IN h.hotelNo
;
--
--Q2--------------------------------------------------------
--How many different guests have made bookings in 2016-02? 
--for each hotel, hotel name order.
SELECT DISTINCT h.hotelName, 
       COUNT(g.guestName) Distinct_Guests
FROM Booking b
NATURAL JOIN Guest g
NATURAL JOIN Hotel h
WHERE b.dateFrom >= DATE '2016-02-01'
GROUP BY h.hotelName
;
--
--Q3--------------------------------------------------------
--List the details of all rooms at the Grosvenor Hotel, 
--including the name of the guest staying in the room.
--List in hotelNo, roomNo roder
SELECT h.hotelName, 
       h.hotelNo,
       r.roomNo, 
       r.type, 
       r.price, 
       g.guestname AS Booked_By
FROM Room r
INNER JOIN (
  SELECT *
  FROM Hotel
  WHERE hotelName LIKE '%Grosvenor%'
) h 
    ON r.hotelNo = h.hotelNo
LEFT JOIN (
  SELECT * 
  FROM Booking 
  WHERE DATE '2016-02-01' BETWEEN dateFrom AND DateTo
) b 
    ON h.hotelNo = b.hotelNo AND r.roomNo = b.roomNo
LEFT JOIN Guest g 
    ON b.guestNo = g.guestNo
ORDER BY r.hotelNo, r.roomNo
; 
--
--Q4--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo oder
--use NOT IN
SELECT *
FROM (
  SELECT h.hotelNo, 
         h.hotelName, 
         r.roomNo, 
         r.type, 
         r.price, 
         b.guestNo
  FROM Room r
  INNER JOIN (
    SELECT *
    FROM Hotel
    WHERE hotelName LIKE '%Grosvenor%'
  ) h 
      ON r.hotelNo = h.hotelNo
  LEFT JOIN (
    SELECT *
    FROM Booking 
    WHERE DATE '2016-02-01' BETWEEN dateFrom AND DateTo
  ) b 
    ON h.hotelNo = b.hotelNo 
    AND r.roomNo = b.roomNo
)
WHERE guestNo NOT IN (
  SELECT guestNo
  FROM Guest
  WHERE guestNo IS NOT NULL
 )
OR guestNo IS NULL
ORDER BY hotelNo, roomNo
;
--
--Q5--------------------------------------------------------
--not exists
SELECT *
FROM (
  SELECT h.hotelNo, h.hotelName, r.roomNo, r.type, r.price, b.guestNo
  FROM Room r
  INNER JOIN (
    SELECT *
    FROM Hotel
    WHERE hotelName LIKE '%Grosvenor%'
  ) h 
    ON r.hotelNo = h.hotelNo
  LEFT JOIN (
    SELECT *
    FROM Booking 
    WHERE DATE '2016-02-01' BETWEEN dateFrom AND DateTo
  ) b 
    ON h.hotelNo = b.hotelNo 
    AND r.roomNo = b.roomNo
) hb
WHERE NOT EXISTS (
  SELECT *
  FROM Guest g
  WHERE g.guestNo = hb.guestNo
 )
ORDER BY hotelNo, roomNo
;   
--
--Q6--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo roder
--use LEFT JOIN
SELECT h.hotelName, 
       h.hotelNo,
       r.roomNo, 
       r.type, 
       r.price
FROM Room r
INNER JOIN (
  SELECT *
  FROM Hotel
  WHERE hotelName LIKE '%Grosvenor%'
  ) h 
    ON r.hotelNo = h.hotelNo
LEFT JOIN (
  SELECT * 
  FROM Booking 
  WHERE DATE '2016-02-01' BETWEEN dateFrom AND DateTo
  ) b 
    ON h.hotelNo = b.hotelNo 
    AND r.roomNo = b.roomNo
LEFT JOIN Guest g ON b.guestNo = g.guestNo
WHERE g.guestNo is NULL
ORDER BY r.hotelNo, r.roomNo
; 
--
--Q7--------------------------------------------------------
--List the rooms that are currently unocupied at all 'Grosvenor' hotels
--List in hotelNo, roomNo roder
--use MINUS
SELECT h.hotelNo, 
       r.roomNo, 
       b.guestNo
FROM Room r
INNER JOIN (
  SELECT *
  FROM Hotel
  WHERE hotelName LIKE '%Grosvenor%'
) h 
  ON r.hotelNo = h.hotelNo
LEFT JOIN (
  SELECT *
  FROM Booking 
  WHERE DATE '2016-02-01' BETWEEN dateFrom AND DateTo
) b 
  ON h.hotelNo = b.hotelNo 
  AND r.roomNo = b.roomNo
MINUS 
  SELECT *
  FROM Guest g,
  WHERE b.guestNo = g.guestNo
ORDER BY h.hotelNo, r.roomNo
;
--
--Q8--------------------------------------------------------
--What is the average number of bookings for each hotel in 2016-2
SELECT AVG(numBookings) AS Average
FROM (
  SELECT COUNT(b.guestNo) AS numBookings
  FROM Hotel h
  LEFT JOIN Booking b
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
INNER JOIN (
  SELECT *
  FROM Booking
    WHERE dateFrom <= DATE'2016-02-01'
    AND (dateTo IS NULL OR dateTo >= DATE'2016-02-01')
) b
  ON r.hotelNo = b.hotelNo
GROUP BY r.hotelNo, h.hotelName
ORDER BY hotelNo
;
--
--Q10--------------------------------------------------------
--Create a view containing the account for each guest at grosenvor hotel
--Use 2016-02-01 as date, and guestAccount as view name
--
CREATE VIEW guestAccount 
AS
SELECT r.roomNo AS Room, 
       g.guestName AS Name, 
       dateFrom AS CheckIn, 
       dateTo AS CheckOut
FROM Guest g
LEFT JOIN Booking b
  ON g.guestNo = b.guestNo
INNER JOIN (
  SELECT *
  FROM Hotel
  WHERE hotelName LIKE '%Grosvenor Hotel%'
) h
  ON b.hotelNo = h.hotelNo
LEFT JOIN Room r
  ON h.hotelNo = r.hotelNo
;
--
--END--------------------------------------------------------
--
SPOOL OFF