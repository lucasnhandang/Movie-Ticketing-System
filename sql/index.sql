-- ########################################################## --
-- INDEX

CREATE INDEX idx_booking_time ON Booking(time);
CREATE INDEX idx_booking_status_time ON Booking(status, time);

CREATE INDEX idx_theater_name ON Theater(name);
CREATE INDEX idx_theater_city ON Theater(city);

CREATE INDEX idx_showtime_date ON Showtime(date);

CREATE INDEX idx_movie_title on Movie(title);

CREATE INDEX idx_redemption_date ON Redemption(redeem_date);

-- ########################################################## --
-- BOOKING TABLE

-- Information on bookings from August 2024 to the end of 2024
EXPLAIN (ANALYZE)
SELECT *
FROM Booking
WHERE Time >= '2024-08-01 00:00:00' AND Time < '2025-01-01 00:00:00';

-- Information on bookings with the status 'Cancelled' from August to the end of December 2024.
EXPLAIN (ANALYZE)
SELECT *
FROM Booking
WHERE Status = 'Cancelled' AND Time >= '2024-01-08 00:00:00' AND Time < '2025-01-01 00:00:00';

-- ########################################################## --
-- MOVIE + SHOWTIME TABLE

-- List of movies screened during a specific period (1/7 to 21/7/24)
EXPLAIN (ANALYZE)
SELECT DISTINCT m.*, s.Date AS Showtime_Date
FROM Movie m
JOIN Showtime s ON m.Movie_id = s.Movie_id
WHERE s.Date >= '2024-07-01' and s.Date <= '2024-07-21'
ORDER BY s.Date ASC;

-- Find the cinemas and showtimes where a specific movie with a given title start with 'Inception' 
-- is being screened during a specific period (9/6/24 - 9/7/24)
EXPLAIN (ANALYZE)
SELECT 
    m.Title AS Movie_Title,
    t.Name AS Theater_Name,
    sh.Date AS Showtime_Date,
    sh.Start_Time AS Showtime_Start_Time,
    sh.End_Time AS Showtime_End_Time
FROM Movie m
JOIN Showtime sh ON m.Movie_id = sh.Movie_id
JOIN Room r ON sh.Room_id = r.Room_id
JOIN Theater t ON r.Theater_id = t.Theater_id
WHERE m.Title LIKE 'Inception %' 
AND sh.Date >= '2024-06-09' and sh.Date <= '2024-07-09'
ORDER BY sh.Date ASC, sh.Start_Time ASC;

-- ########################################################## --
-- REDEMPTION TABLE

-- History of voucher redemptions during 8/9/24 to 22/9/24.
EXPLAIN (ANALYZE)
SELECT *
FROM Redemption
WHERE redeem_date between '2024-09-08 00:00:00' and '2024-09-22 00:00:00';

-- ########################################################## --
-- THEATER TABLE

-- Retrieve all movies screened at cinemas in cities start with 'A' during 1/3/24 - 1/4/24, 
-- including detailed information about the cinema, screening room, movie, and schedule. 
-- The data is sorted by cinema, screening date, and movie start time.
EXPLAIN(ANALYZE)
SELECT 
    t.Theater_id,
    t.Name AS Theater_Name,
    t.Address AS Theater_Address,
    t.City AS Theater_City,
    m.*,
    s.Start_Time,
    s.End_Time,
    s.Date
FROM 
    Theater t
JOIN 
    Room r ON t.Theater_id = r.Theater_id
JOIN 
    Showtime s ON r.Room_id = s.Room_id
JOIN 
    Movie m ON s.Movie_id = m.Movie_id
WHERE 
    t.city like 'A%'
    AND s.Date BETWEEN '2024-03-01' AND '2024-04-01'
ORDER BY 
    s.Date, s.Start_Time;

-- Retrieve all movies screened at cinemas with name starts with 'CGV' during 1/8/24 - 15/8/24, 
-- including the cinema name, movie information, and screening schedule.
EXPLAIN(ANALYZE)
SELECT 
    T.Name AS Theater_Name,
    M.Title AS Movie_Title,
    M.Description AS Movie_Description,
    M.Language AS Movie_Language,
    M.Rating AS Movie_Rating,
    M.Duration AS Movie_Duration,
    S.Start_Time AS Showtime_Start,
    S.End_Time AS Showtime_End,
    S.Date AS Showtime_Date
FROM 
    Showtime S
JOIN 
    Room R ON S.Room_id = R.Room_id
JOIN 
    Theater T ON R.Theater_id = T.Theater_id
JOIN 
    Movie M ON S.Movie_id = M.Movie_id
WHERE 
    T.Name like 'CGV %'
    AND S.Date BETWEEN '2024-08-01' AND '2024-08-15'
ORDER BY 
    S.Date ASC, S.Start_Time ASC;




