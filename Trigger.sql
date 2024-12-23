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

CREATE OR REPLACE TRIGGER trigger_deduct_loyalty_points_on_redemption
AFTER INSERT ON Redemption
FOR EACH ROW
WHEN (NEW.Status = 'Available') -- Chỉ chạy khi Status là 'Available'
EXECUTE FUNCTION deduct_loyalty_points_on_redemption();

-- ============================================
-- 2. Check if there are any showtimes with duplicate Room_id and screening time 
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
-- 3. Check if the movie already exists in the Movie table
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
