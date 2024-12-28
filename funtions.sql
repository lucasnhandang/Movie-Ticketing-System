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
--Tìm rạp
CREATE OR REPLACE FUNCTION FindTheatersByName(input_theater_name VARCHAR)
RETURNS TABLE(Theater_id INT, Name VARCHAR, Address VARCHAR, City VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT t.Theater_id, t.Name, t.Address, t.City
    FROM Theater t
    WHERE t.Name ILIKE '%' || input_theater_name || '%'; -- Tìm theo chuỗi nhập vào
END;
$$ LANGUAGE plpgsql;
--Tìm phim trong rạp đó
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
CREATE OR REPLACE FUNCTION FindAvailableSeatsByShowtime(input_showtime_id INT)
RETURNS TABLE(
    Seat_id INT, 
    "Row" VARCHAR, 
    "Number" INT, 
    Seattype_id INT, 
    Seattype_name VARCHAR, 
    Price INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.Seat_id, 
        s.Row, 
        s.Number, 
        s.Seattype_id, 
        st.Name AS Seattype_name, 
        st.Price
    FROM Seat s
    JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    JOIN Room r ON s.Room_id = r.Room_id
    JOIN Showtime stime ON r.Room_id = stime.Room_id
    LEFT JOIN BookingSeat bs ON s.Seat_id = bs.Seat_id
    LEFT JOIN Booking b ON bs.Booking_id = b.Booking_id
    WHERE stime.Showtime_id = input_showtime_id
      AND (b.Status IS NULL OR b.Status NOT IN ('Confirmed', 'Pending'));
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

CREATE OR REPLACE FUNCTION get_booking_info(booking_id_param INT)
RETURNS TABLE (
    user_name VARCHAR,
    theater_name VARCHAR,
    room_name VARCHAR,
    movie_title VARCHAR,
    start_time TIME,
    end_time TIME,
    seats TEXT,
    total_price INT,
    loyalty_points INT
) AS $$
BEGIN
    RETURN QUERY
    WITH seat_details AS (
        SELECT 
            b.booking_id,
            STRING_AGG(s.row || s.number || ' (' || st.name || ')', ', ') as booked_seats,
            SUM(st.price)::INT as total_seat_price
        FROM Booking b
        JOIN BookingSeat bs ON b.booking_id = bs.booking_id
        JOIN Seat s ON bs.seat_id = s.seat_id
        JOIN SeatType st ON s.seattype_id = st.seattype_id
        WHERE b.booking_id = booking_id_param
        GROUP BY b.booking_id
    )
    SELECT 
        u.name,
        t.name,
        r.name,
        m.title,
        sh.start_time,
        sh.end_time,
        sd.booked_seats,
        (CASE 
            WHEN b.voucher_id IS NOT NULL THEN 
                sd.total_seat_price - (sd.total_seat_price * v.discount_percentage / 100)
            ELSE sd.total_seat_price
        END)::INT,
        (CEIL(
            CASE 
                WHEN b.voucher_id IS NOT NULL THEN 
                    (sd.total_seat_price - (sd.total_seat_price * v.discount_percentage / 100)) * 0.05
                ELSE sd.total_seat_price * 0.05
            END
        ))::INT
    FROM Booking b
    JOIN "User" u ON b.user_id = u.user_id
    JOIN Showtime sh ON b.showtime_id = sh.showtime_id
    JOIN Room r ON sh.room_id = r.room_id
    JOIN Theater t ON r.theater_id = t.theater_id
    JOIN Movie m ON sh.movie_id = m.movie_id
    JOIN seat_details sd ON b.booking_id = sd.booking_id
    LEFT JOIN Voucher v ON b.voucher_id = v.voucher_id
    WHERE b.booking_id = booking_id_param;
END;
$$ LANGUAGE plpgsql;

-- Tính số tiền người dùng đã tiêu để xem phim trong 1 tháng
CREATE OR REPLACE FUNCTION CalculateUserMonthlySpending(UserId INT, Month INT, Year INT)
RETURNS NUMERIC AS $$
DECLARE
    TotalSpent NUMERIC := 0;
BEGIN
    -- Tính tổng tiền
    SELECT COALESCE(SUM(st.Price), 0) INTO TotalSpent
    FROM Booking b
    INNER JOIN BookingSeat bs ON b.Booking_id = bs.Booking_id
    INNER JOIN Seat s ON bs.Seat_id = s.Seat_id
    INNER JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    WHERE b.User_id = UserId
      AND EXTRACT(MONTH FROM b.Time) = Month
      AND EXTRACT(YEAR FROM b.Time) = Year
      AND b.Status = 'Confirmed'; -- Chỉ tính những booking đã được xác nhận

    RETURN TotalSpent;
END;
$$ LANGUAGE plpgsql;

-- Tính số tiền người dùng đã tiêu để xem phim trong 1 năm
CREATE OR REPLACE FUNCTION CalculateUserYearlySpending(UserId INT, Year INT)
RETURNS NUMERIC AS $$
DECLARE
    TotalSpent NUMERIC := 0;
BEGIN
    -- Tính tổng tiền người dùng đã chi trong năm
    SELECT COALESCE(SUM(st.Price), 0) INTO TotalSpent
    FROM Booking b
    INNER JOIN BookingSeat bs ON b.Booking_id = bs.Booking_id
    INNER JOIN Seat s ON bs.Seat_id = s.Seat_id
    INNER JOIN SeatType st ON s.Seattype_id = st.Seattype_id
    WHERE b.User_id = UserId
      AND EXTRACT(YEAR FROM b.Time) = Year
      AND b.Status = 'Confirmed'; -- Chỉ tính những booking đã được xác nhận

    RETURN TotalSpent;
END;
$$ LANGUAGE plpgsql;

-- Tính số bộ phim người dùng đã xem trong tháng
CREATE OR REPLACE FUNCTION CountUserMoviesWatchedInMonth(UserId INT, Month INT, Year INT)
RETURNS INT AS $$
DECLARE
    MovieCount INT := 0;
BEGIN
    -- Tính số lượng bộ phim đã xem trong tháng
    SELECT COUNT(DISTINCT s.Movie_id) INTO MovieCount
    FROM Booking b
    INNER JOIN Showtime s ON b.Showtime_id = s.Showtime_id
    WHERE b.User_id = UserId
      AND EXTRACT(MONTH FROM b.Time) = Month
      AND EXTRACT(YEAR FROM b.Time) = Year
      AND b.Status = 'Confirmed'; -- Chỉ tính những booking đã được xác nhận

    RETURN MovieCount;
END;
$$ LANGUAGE plpgsql;

-- Tính số phim người dùng đã xem trong năm
CREATE OR REPLACE FUNCTION CountUserMoviesWatchedInYear(UserId INT, Year INT)
RETURNS INT AS $$
DECLARE
    MovieCount INT := 0;
BEGIN
    -- Tính số lượng bộ phim đã xem trong năm
    SELECT COUNT(DISTINCT s.Movie_id) INTO MovieCount
    FROM Booking b
    INNER JOIN Showtime s ON b.Showtime_id = s.Showtime_id
    WHERE b.User_id = UserId
      AND EXTRACT(YEAR FROM b.Time) = Year
      AND b.Status = 'Confirmed'; -- Chỉ tính những booking đã được xác nhận

    RETURN MovieCount;
END;
$$ LANGUAGE plpgsql;

