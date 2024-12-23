-- ============================================
-- 1. Update User.Loyalty_points after reedeming voucher
-- ============================================

CREATE OR REPLACE FUNCTION deduct_loyalty_points_on_redemption()
RETURNS TRIGGER AS $$
DECLARE
    required_points INT; -- Điểm yêu cầu của voucher
    current_points INT;  -- Điểm Loyalty hiện tại của người dùng
BEGIN
    -- Lấy số điểm yêu cầu của voucher từ bảng Voucher
    SELECT Points_Required INTO required_points
    FROM Voucher
    WHERE Voucher_id = NEW.Voucher_id;

    -- Lấy số điểm Loyalty hiện tại của người dùng
    SELECT Loyalty_Points INTO current_points
    FROM "User"
    WHERE User_id = NEW.User_id;

    -- Kiểm tra nếu người dùng đủ điểm để sử dụng voucher
    IF current_points >= required_points THEN
        -- Trừ số điểm Loyalty của người dùng
        UPDATE "User"
        SET Loyalty_Points = Loyalty_Points - required_points
        WHERE User_id = NEW.User_id;

        -- Hiển thị thông báo khi trừ điểm thành công
        RAISE NOTICE 'User with User_id % redeemed a voucher with Voucher_id % successfully. % points deducted. Remaining points: %.',
            NEW.User_id, NEW.Voucher_id, required_points, current_points - required_points;
    ELSE
        -- Nếu không đủ điểm, hủy hành động và báo lỗi
        RAISE EXCEPTION 'Not enough Loyalty Points to redeem this voucher (User_id: %, Required Points: %, Current Points: %)',
            NEW.User_id, required_points, current_points;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_deduct_loyalty_points_on_redemption
AFTER INSERT ON Redemption
FOR EACH ROW
WHEN (NEW.Status = 'Available') -- Chỉ chạy khi Status là 'Available'
EXECUTE FUNCTION deduct_loyalty_points_on_redemption();

-- ============================================
-- 2. Cancel Booking with status = ‘Pending’ after 10 minutes (expired)
-- ============================================

CREATE OR REPLACE FUNCTION cancel_expired_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Pending' AND (NOW() - NEW.time) > INTERVAL '10 minutes' THEN
        UPDATE Booking
        SET status = 'Cancelled'
        WHERE booking_id = NEW.booking_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cancel_expired_booking
AFTER INSERT OR UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION cancel_expired_booking();

-- ============================================
-- 3. Update User.Loyalty_points when Booking.status = ‘Confirmed’
-- ============================================

CREATE OR REPLACE FUNCTION update_loyalty_points_with_function()
RETURNS TRIGGER AS $$
DECLARE
    total_price INT; -- Total price of the booking
    loyalty_points_to_add INT; -- Loyalty points to be added
    current_loyalty_points INT; -- Current loyalty points of the user
BEGIN
    -- Call the CalculateBookingPrice function to calculate the total price of the booking
    total_price := CalculateBookingPrice(NEW.Booking_id);

    -- Calculate loyalty points (5% of the total price)
    loyalty_points_to_add := (total_price * 5) / 100;

    -- Fetch the current loyalty points of the user
    SELECT Loyalty_Points INTO current_loyalty_points
    FROM "User"
    WHERE User_id = NEW.User_id;

    -- Add loyalty points to the user's account
    UPDATE "User"
    SET Loyalty_Points = COALESCE(Loyalty_Points, 0) + loyalty_points_to_add
    WHERE User_id = NEW.User_id;

    -- Display a notice about the loyalty points update
    RAISE NOTICE 'User with User_id % has been awarded % loyalty points. Current loyalty points are now %.',
        NEW.User_id, loyalty_points_to_add, COALESCE(current_loyalty_points, 0) + loyalty_points_to_add;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_loyalty_points_with_function
AFTER INSERT OR UPDATE ON Booking
FOR EACH ROW
WHEN (NEW.Status = 'Confirmed' AND OLD.Status != 'Confirmed') -- Chỉ chạy khi trạng thái chuyển thành "Confirmed"
EXECUTE FUNCTION update_loyalty_points_with_function();

-- ============================================
-- 4. Check if there are any showtimes with duplicate Room_id and screening time 
-- ============================================

CREATE OR REPLACE FUNCTION check_conflicting_showtime()
RETURNS TRIGGER AS $$
BEGIN
    -- Kiểm tra xem có bất kỳ showtime nào trùng Room_id và thời gian chiếu không
    IF EXISTS (
        SELECT 1
        FROM Showtime
        WHERE Room_id = NEW.Room_id
          AND Date = NEW.Date
          AND (
              (NEW.Start_Time BETWEEN Start_Time AND End_Time) OR
              (NEW.End_Time BETWEEN Start_Time AND End_Time) OR
              (Start_Time BETWEEN NEW.Start_Time AND NEW.End_Time)
          )
    ) THEN
        RAISE EXCEPTION 'Conflicting showtime: Room_id % already has a showtime during this time.', NEW.Room_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_conflicting_showtime
BEFORE INSERT ON Showtime
FOR EACH ROW
EXECUTE FUNCTION check_conflicting_showtime();

-- ============================================
-- 5. Check if the movie already exists in the Movie table
-- ============================================

CREATE OR REPLACE FUNCTION check_duplicate_movie()
RETURNS TRIGGER AS $$
BEGIN
    -- Kiểm tra nếu phim đã tồn tại trong bảng Movie
    IF EXISTS (
        SELECT 1
        FROM Movie
        WHERE LOWER(Title) = LOWER(NEW.Title) -- So sánh tiêu đề không phân biệt chữ hoa/thường
          AND Language = NEW.Language        -- Ngôn ngữ phải giống nhau
          AND Release_Date = NEW.Release_Date -- Ngày phát hành phải giống nhau
    ) THEN
        RAISE EXCEPTION 'Duplicate movie detected: Movie with Title "%" already exists in the database.', NEW.Title;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_duplicate_movie
BEFORE INSERT ON Movie
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_movie();
