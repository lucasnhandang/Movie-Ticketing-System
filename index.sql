-- ####################################################################################################
-- TẠO INDEX

CREATE INDEX idx_booking_time ON Booking(time);
CREATE INDEX idx_booking_status_time ON Booking(status, time);

CREATE INDEX idx_showtime_date ON Showtime(date);

CREATE INDEX idx_theater_name ON Theater(name);
CREATE INDEX idx_theater_city ON Theater(city);

CREATE INDEX idx_movie_title on Movie(title);

CREATE INDEX idx_redemption_date ON Redemption(redeem_date);

-- ####################################################################################################
-- BẢNG BOOKING

-- 2. Thông tin các booking từ tháng 8/2024 tới hết năm 2024
EXPLAIN (ANALYZE)
SELECT *
FROM Booking
WHERE Time >= '2024-08-01 00:00:00' AND Time < '2025-01-01 00:00:00';

-- 3. Thông tin booking có trạng thái 'Cancelled' từ T8 tới hết T12/2024
EXPLAIN (ANALYZE)
SELECT *
FROM Booking
WHERE Status = 'Cancelled' AND Time >= '2024-01-08 00:00:00' AND Time < '2025-01-01 00:00:00';

-- ####################################################################################################
-- BẢNG MOVIE

-- 1. Danh sách các phim đang được chiếu
EXPLAIN (ANALYZE)
SELECT DISTINCT m.*, s.Date AS Showtime_Date
FROM Movie m
JOIN Showtime s ON m.Movie_id = s.Movie_id
WHERE s.Date >= '2024-07-01'
ORDER BY s.Date ASC;

-- 2. Tìm các rạp chiếu phim + suất chiếu nơi một phim cụ thể có title nào đó đang được chiếu
-- trong khoảng thời gian nào đó
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
WHERE m.Title = 'Inception' 
AND sh.Date >= '2024-06-09'
ORDER BY sh.Date ASC, sh.Start_Time ASC;

-- ####################################################################################################
-- BẢNG REDEMPTION

-- 3. Lịch sử đổi voucher trong một khoảng thời gian cụ thể
EXPLAIN (ANALYZE)
SELECT *
FROM Redemption
WHERE redeem_date between '2024-09-08 00:00:00' and '2024-12-11 00:00:00';



