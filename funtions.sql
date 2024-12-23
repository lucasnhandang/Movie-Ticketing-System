-- ============================================
-- 1. Function: Tính tổng giá của một booking
-- ============================================
CREATE OR REPLACE FUNCTION CalculateBookingPrice(input_booking_id INT)
RETURNS INT AS $$
DECLARE
    total_price INT := 0;
BEGIN
    -- Tính tổng giá cho tất cả các ghế trong một booking
    SELECT SUM(st.Price) INTO total_price
    FROM BookingSeat bs
    JOIN Seat s ON bs.Seat_id = s.Seat_id
    JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    WHERE bs.Booking_id = input_booking_id;

    -- Trả về tổng giá của booking
    RETURN total_price;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2. Function: Tính doanh thu của một ngày
-- ============================================
CREATE OR REPLACE FUNCTION CalculateRevenueByDay(input_date DATE)
RETURNS INT AS $$
DECLARE
    total_revenue INT := 0;
BEGIN
    -- Tính tổng doanh thu cho tất cả booking trong ngày input_date
    SELECT SUM(st.Price) INTO total_revenue
    FROM BookingSeat bs
    JOIN Seat s ON bs.Seat_id = s.Seat_id
    JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    JOIN Booking b ON bs.Booking_id = b.Booking_id
    WHERE b.Time::DATE = input_date;

    -- Trả về tổng doanh thu
    RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. Function: Tính doanh thu của một tháng
-- ============================================
CREATE OR REPLACE FUNCTION CalculateRevenueByMonth(input_month INT, input_year INT)
RETURNS INT AS $$
DECLARE
    total_revenue INT := 0;
BEGIN
    -- Tính tổng doanh thu cho tất cả booking trong tháng và năm chỉ định
    SELECT SUM(st.Price) INTO total_revenue
    FROM BookingSeat bs
    JOIN Seat s ON bs.Seat_id = s.Seat_id
    JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    JOIN Booking b ON bs.Booking_id = b.Booking_id
    WHERE EXTRACT(MONTH FROM b.Time) = input_month AND EXTRACT(YEAR FROM b.Time) = input_year;

    -- Trả về tổng doanh thu
    RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. Function: Tính doanh thu của một năm
-- ============================================
CREATE OR REPLACE FUNCTION CalculateRevenueByYear(input_year INT)
RETURNS INT AS $$
DECLARE
    total_revenue INT := 0;
BEGIN
    -- Tính tổng doanh thu cho tất cả booking trong năm input_year
    SELECT SUM(st.Price) INTO total_revenue
    FROM BookingSeat bs
    JOIN Seat s ON bs.Seat_id = s.Seat_id
    JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    JOIN Booking b ON bs.Booking_id = b.Booking_id
    WHERE EXTRACT(YEAR FROM b.Time) = input_year;

    -- Trả về tổng doanh thu
    RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. Function: Tìm các bộ phim trong một rạp
-- ============================================
CREATE OR REPLACE FUNCTION FindMoviesByTheater(input_theater_id INT)
RETURNS TABLE(Movie_id INT, Title VARCHAR, Description TEXT, Language VARCHAR, Rating DECIMAL, Duration INT, Release_Date DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT m.*
    FROM Movie m
    JOIN Showtime s ON m.Movie_id = s.Movie_id
    JOIN Room r ON s.Room_id = r.Room_id
    JOIN Theater t ON r.Theater_id = t.Theater_id
    WHERE t.Theater_id = input_theater_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. Function: Tìm ghế theo booking
-- ============================================
CREATE OR REPLACE FUNCTION FindSeatsByBooking(input_booking_id INT)
RETURNS TABLE(Seat_id INT, "Row" VARCHAR, "Number" INT, Seattype_id INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.Seat_id, s.Row, s.Number, s.Seattype_id
    FROM Seat s
    JOIN BookingSeat bs ON s.Seat_id = bs.Seat_id
    WHERE bs.Booking_id = input_booking_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. Function: Tìm ghế theo suất chiếu và trạng thái booking
-- ============================================
CREATE OR REPLACE FUNCTION FindSeatsByShowtimeAndBookingStatus(input_showtime_id INT)
RETURNS TABLE(Seat_id INT, "Row" VARCHAR, "Number" INT, Seattype_id INT, Booking_Status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT s.Seat_id, s.Row, s.Number, s.Seattype_id, b.Status AS Booking_Status
    FROM Seat s
    LEFT JOIN BookingSeat bs ON s.Seat_id = bs.Seat_id
    LEFT JOIN Booking b ON bs.Booking_id = b.Booking_id
    LEFT JOIN Showtime st ON b.Showtime_id = st.Showtime_id
    WHERE st.Showtime_id = input_showtime_id
    AND (b.Status NOT IN ('Confirmed', 'Pending') OR b.Status IS NULL);
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- 8. Function: Tìm suất chiếu theo phim và rạp
-- ============================================
CREATE OR REPLACE FUNCTION FindShowtimesByMovieAndTheater(input_movie_id INT, input_theater_id INT)
RETURNS TABLE(Showtime_id INT, Start_Time TIME, End_Time TIME, Date DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT s.Showtime_id, s.Start_Time, s.End_Time, s.Date
    FROM Showtime s
    JOIN Room r ON s.Room_id = r.Room_id
    JOIN Theater t ON r.Theater_id = t.Theater_id
    WHERE s.Movie_id = input_movie_id
    AND t.Theater_id = input_theater_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. Function: Tìm rạp chiếu theo phim
-- ============================================
CREATE OR REPLACE FUNCTION FindTheatersByMovieId(input_movie_id INT)
RETURNS TABLE(
    Theater_id INT,
    Theater_Name VARCHAR,
    Address VARCHAR,
    City VARCHAR,
    Total_Rooms INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        t.Theater_id,
        t.Name AS Theater_Name,
        t.Address,
        t.City,
        t.Total_Rooms
    FROM Theater t
    JOIN Room r ON t.Theater_id = r.Theater_id
    JOIN Showtime s ON r.Room_id = s.Room_id
    WHERE s.Movie_id = input_movie_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. Function: Tìm voucher khả dụng (cre: Nhi)
-- ============================================
CREATE OR REPLACE FUNCTION update_expired_vouchers()
RETURNS VOID AS $$
BEGIN
    -- Cập nhật trạng thái trong bảng Redemption thành 'Expired' nếu voucher hết hạn
    UPDATE Redemption
    SET Status = 'Expired'
    WHERE Voucher_id IN (
        SELECT Voucher_id
        FROM Voucher
        WHERE Expiry_Date < NOW()
    );

    -- Thông báo nếu cần kiểm tra log
    RAISE NOTICE 'Expired vouchers have been updated in Redemption.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION view_redemption_vouchers(userid INT) 
RETURNS TABLE (Voucher_id INT, Status VARCHAR, Redeem_Date TIMESTAMP) AS $$
BEGIN
    -- Cập nhật trạng thái của các voucher hết hạn
    PERFORM update_expired_vouchers();

    -- Trả về danh sách các voucher đã đổi
    RETURN QUERY
    SELECT r.Voucher_id, r.Status, r.Redeem_Date
    FROM Redemption r
    WHERE r.User_id = userid; 
END;
$$ LANGUAGE plpgsql;

-- 11. Tính tổng tiền tiêu theo khoảng thời gian dành cho User
CREATE OR REPLACE FUNCTION CalculateTotalSpentByTime(
    input_user_id INT, 
    input_time_start DATE, 
    input_time_end DATE
)
RETURNS DECIMAL AS $$
DECLARE
    total_spent DECIMAL := 0;
BEGIN
    -- Tính tổng tiền bỏ ra theo khoảng thời gian
    SELECT SUM(stp.Price) INTO total_spent
    FROM Booking b
    JOIN BookingSeat bs ON b.Booking_id = bs.Booking_id
    JOIN Seat s ON bs.Seat_id = s.Seat_id
    JOIN SeatType stp ON s.Seattype_id = stp.Seattype_id
    WHERE b.User_id = input_user_id
    AND b.Time BETWEEN input_time_start AND input_time_end
    AND b.Status = 'Confirmed'; -- Chỉ tính các booking đã xác nhận

    RETURN total_spent;
END;
$$ LANGUAGE plpgsql;

-- 12. Tính tổng thời gian xem phim trong một khung thời gian dành cho User
CREATE OR REPLACE FUNCTION CalculateTotalWatchTime(
    input_user_id INT,
    input_time_start DATE,
    input_time_end DATE
)
RETURNS INTERVAL AS $$
DECLARE
    total_time INTERVAL := INTERVAL '0' MINUTE;
BEGIN
    SELECT SUM(m.Duration * 60) * INTERVAL '1 minute' INTO total_time
    FROM Booking b
    JOIN Showtime st ON b.Showtime_id = st.Showtime_id
    JOIN Movie m ON st.Movie_id = m.Movie_id
    WHERE b.User_id = input_user_id
    AND b.Time BETWEEN input_time_start AND input_time_end
    AND b.Status = 'Confirmed'; -- Chỉ tính các booking đã xác nhận

    RETURN total_time;
END;
$$ LANGUAGE plpgsql;

-- 13. Tìm thể loại phim xem nhiều nhất dành cho User
CREATE OR REPLACE FUNCTION FindMostWatchedGenreByUser(input_user_id INT)
RETURNS TABLE(Genre_id INT, Genre_Name VARCHAR, Watch_Count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT g.Genre_id, g.Name AS Genre_Name, COUNT(*) AS Watch_Count
    FROM Booking b
    JOIN Showtime st ON b.Showtime_id = st.Showtime_id
    JOIN Movie m ON st.Movie_id = m.Movie_id
    JOIN MovieGenre mg ON m.Movie_id = mg.Movie_id
    JOIN Genre g ON mg.Genre_id = g.Genre_id
    WHERE b.User_id = input_user_id
    AND b.Status = 'Confirmed'  -- Chỉ tính những booking đã xác nhận
    GROUP BY g.Genre_id, g.Name
    ORDER BY Watch_Count DESC  -- Sắp xếp theo số lần xem giảm dần
    LIMIT 1;  -- Chỉ trả về genre xem nhiều nhất
END;
$$ LANGUAGE plpgsql;



