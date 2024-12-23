-- 1. MovieGenresInfo
-- This view provides detailed information about movies along with their associated genres. 
-- It includes all movie attributes and the genre name, enabling easy retrieval of movies categorized by their genres. 
-- Useful for filtering or grouping movies by genre in analytics or user-facing applications.

CREATE VIEW MovieGenresInfo AS
SELECT 
    m.*,
    STRING_AGG(G.Name, ', ') AS Genres
FROM Movie m
JOIN MovieGenre mg ON m.Movie_id = mg.Movie_id
JOIN Genre g ON mg.Genre_id = g.Genre_id
GROUP BY M.Movie_id, M.Title;

-- 2. ShowtimeOccupancy
-- This view provides detailed occupancy data for each showtime, including the theater name, movie title, showtime date and start time, 
-- total confirmed bookings, seats booked, room capacity, and occupancy rate (percentage of seats filled). 
-- It helps analyze theater performance and optimize scheduling or promotions.

CREATE VIEW ShowtimeOccupancy AS
SELECT 
    t.name AS theater_name,
    m.title AS movie_title,
    s.date,
    s.start_time,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    COUNT(DISTINCT bs.seat_id) AS seats_booked,
    r.capacity AS room_capacity,
    ROUND(COUNT(DISTINCT bs.seat_id)::numeric / NULLIF(r.capacity, 0) * 100, 2) AS occupancy_rate
FROM Showtime s
JOIN Room r ON s.room_id = r.room_id
JOIN Theater t ON r.theater_id = t.theater_id
JOIN Movie m ON s.movie_id = m.movie_id
LEFT JOIN Booking b ON s.showtime_id = b.showtime_id AND b.status = 'Confirmed'
LEFT JOIN BookingSeat bs ON b.booking_id = bs.booking_id
GROUP BY 
    t.name,
    m.title,
    s.date,
    s.start_time,
    r.capacity
ORDER BY seats_booked DESC;

-- 3. TopBookingUsers
-- This view provides a ranked list of users based on the number of confirmed bookings they have made. 
-- It includes user details such as ID, name, email, and the total count of confirmed bookings, ordered from highest to lowest. 
-- It is useful for identifying the most active and loyal customers.

CREATE VIEW TopBookingUsers AS
SELECT 
    u.User_id,
    u.Name AS UserName,
    u.Email,
    COUNT(b.Booking_id) AS TotalBookings
FROM "User" u
JOIN Booking b ON u.User_id = b.User_id
WHERE b.Status = 'Confirmed' 
GROUP BY u.User_id, u.Name, u.Email
ORDER BY TotalBookings DESC;

-- 4. DetailedBookingSummary
-- This view provides a comprehensive summary of booking details, including user information, booking time and status, movie title, 
-- showtime schedule, theater details (name and city), seat information (row, number, type, and price), 
-- and sorts the results by the most recent bookings.

CREATE VIEW DetailedBookingSummary AS
SELECT 
	U.User_id, 
	U.name,
    B.Time AS Booking_Time,
    B.Status AS Booking_Status,
	M.Title AS Movie_Title,
    ST.Date AS Showtime_Date,
    ST.Start_Time AS Start_Time,
    ST.End_Time AS End_Time,
    T.Name AS Theater_Name,
	T.City,
    S.Row || '-' || S.Number AS Seat_Info,
    SType.Name AS Seat_Type,
    SType.Price AS Seat_Price
FROM Booking B
JOIN "User" U ON B.User_id = U.User_id
JOIN Showtime ST ON B.Showtime_id = ST.Showtime_id
JOIN Movie M ON ST.Movie_id = M.Movie_id
JOIN Room R ON ST.Room_id = R.Room_id
JOIN Theater T ON R.Theater_id = T.Theater_id
JOIN BookingSeat BS ON B.Booking_id = BS.Booking_id
JOIN Seat S ON BS.Seat_id = S.Seat_id
JOIN SeatType SType ON S.Seattype_id = SType.Seattype_id
ORDER BY B.Time DESC;

-- 5. MoviePerformance
-- This view provides a performance summary of movies, including the number of showtimes, total bookings, and total revenue 
-- generated for each movie. It aggregates data from related tables to offer an overview of movie effectiveness 
-- sorted by revenue in descending order.

CREATE VIEW MoviePerformance AS
SELECT 
    m.Title AS Movie_Name,
    COUNT(DISTINCT s.Showtime_id) AS Total_Showtimes,
    COUNT(DISTINCT b.Booking_id) AS Total_Bookings,
    COALESCE(SUM(bs.Total_Price), 0) AS Total_Revenue
FROM 
    Movie m
LEFT JOIN Showtime s ON m.Movie_id = s.Movie_id
LEFT JOIN Booking b ON s.Showtime_id = b.Showtime_id
LEFT JOIN (
    SELECT 
        bs.Booking_id,
        SUM(st.Price) AS Total_Price
    FROM 
        BookingSeat bs
    JOIN Seat seat ON bs.Seat_id = seat.Seat_id
    JOIN SeatType st ON seat.Seattype_id = st.Seattype_id
    GROUP BY bs.Booking_id
) bs ON b.Booking_id = bs.Booking_id
GROUP BY m.Title
ORDER BY Total_Revenue DESC;