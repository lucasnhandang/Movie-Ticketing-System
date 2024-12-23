-- ============================================
-- 1. Insert Procedures: Thêm dữ liệu
-- ============================================

-- Thêm một bộ phim mới
CREATE OR REPLACE PROCEDURE InsertMovie(
    IN input_title VARCHAR(100),
    IN input_description TEXT,
    IN input_language VARCHAR(10),
    IN input_rating DECIMAL(2, 1),
    IN input_duration INT,
    IN input_release_date DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    new_movie_id INT; -- Biến để lưu Movie_id mới được tạo
BEGIN
    -- Chèn dữ liệu vào bảng Movie, Movie_id sẽ được tự động tạo
    INSERT INTO Movie (Title, Description, Language, Rating, Duration, Release_Date)
    VALUES (input_title, input_description, input_language, input_rating, input_duration, input_release_date)
    RETURNING Movie_id INTO new_movie_id; -- Lấy Movie_id vừa được tạo

    -- Hiển thị thông báo thành công
    RAISE NOTICE 'Movie inserted with Movie_id: %', new_movie_id;
END;
$$;

-- Thêm một bản ghi đổi quà vào Redemption
CREATE OR REPLACE PROCEDURE InsertRedemption(
    IN input_user_id INT,
    IN input_voucher_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Chèn bản ghi mới vào bảng Redemption (sẽ kích hoạt trigger)
    INSERT INTO Redemption (User_id, Voucher_id, Redeem_Date, Status)
    VALUES (input_user_id, input_voucher_id, NOW(), 'Available');

    -- Thông báo sau khi thêm thành công
    RAISE NOTICE 'Redemption record inserted for User_id % and Voucher_id %. Trigger will handle point deduction.', 
        input_user_id, input_voucher_id;
END;
$$;

-- Thêm một suất chiếu phim mới
CREATE OR REPLACE PROCEDURE InsertShowtime(
    IN input_start_time TIME,
    IN input_end_time TIME,
    IN input_date DATE,
    IN input_room_id INT,
    IN input_movie_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Showtime (Start_Time, End_Time, Date, Room_id, Movie_id)
    VALUES (input_showtime_id, input_start_time, input_end_time, input_date, input_room_id, input_movie_id);
END;
$$;

-- Thêm một người dùng mới
CREATE OR REPLACE FUNCTION insert_user(
    name VARCHAR,
    email VARCHAR,
    password VARCHAR,
    phone VARCHAR DEFAULT NULL,
    address VARCHAR DEFAULT NULL,
    date_joined TIMESTAMP DEFAULT NOW(),
    dob DATE DEFAULT NULL,
    loyalty_points INT DEFAULT 0
)
RETURNS VOID AS $$
BEGIN
    -- Thêm người dùng mới vào bảng "User"
    INSERT INTO "User" (Name, Email, Password, Phone, Address, Date_Joined, Dob, Loyalty_Points)
    VALUES (name, email, password, phone, address, date_joined, dob, loyalty_points);

    -- Hiển thị thông báo thành công
    RAISE NOTICE 'User % inserted successfully.', name;
END;
$$ LANGUAGE plpgsql;


-- Thêm một voucher mới
CREATE OR REPLACE PROCEDURE InsertVoucher(
    IN input_description TEXT,
    IN input_discount_percentage INT,
    IN input_expiry_date TIMESTAMP,
    IN input_points_required INT
)
LANGUAGE plpgsql AS $$
DECLARE
    new_voucher_id INT; -- Biến để lưu Voucher_id mới được tạo
BEGIN
    -- Chèn dữ liệu vào bảng Voucher, Voucher_id sẽ được tự động tạo
    INSERT INTO Voucher (Description, Discount_Percentage, Expiry_Date, Points_Required)
    VALUES (input_description, input_discount_percentage, input_expiry_date, input_points_required)
    RETURNING Voucher_id INTO new_voucher_id; -- Lấy Voucher_id vừa được tạo

    -- Hiển thị thông báo thành công
    RAISE NOTICE 'Voucher inserted with Voucher_id: %', new_voucher_id;
END;
$$;

-- ============================================
-- 2. Update Procedures: Cập nhật dữ liệu
-- ============================================

-- Cập nhật thông tin bộ phim
CREATE OR REPLACE PROCEDURE UpdateMovieByTitle(
    IN input_title VARCHAR(100),
    IN input_description TEXT,
    IN input_rating DECIMAL(2, 1)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Kiểm tra xem tên phim có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM Movie WHERE Title = input_title) THEN
        RAISE EXCEPTION 'Movie with title "%" does not exist.', input_title;
    END IF;

    -- Cập nhật Description và Rating của phim
    UPDATE Movie
    SET 
        Description = input_description,
        Rating = input_rating
    WHERE Title = input_title;

    -- Hiển thị thông báo thành công
    RAISE NOTICE 'Movie "%", Description and Rating updated successfully.', input_title;
END;
$$;

-- Cập nhật thông tin người dùng
CREATE OR REPLACE FUNCTION update_user_by_email(
    emails VARCHAR, 
    names VARCHAR DEFAULT NULL, 
    passwords VARCHAR DEFAULT NULL, 
    phones VARCHAR DEFAULT NULL, 
    addresss VARCHAR DEFAULT NULL, 
    dobs DATE DEFAULT NULL 
)
RETURNS VOID AS $$
BEGIN
    -- Kiểm tra xem email có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM "User" u WHERE u.Email = emails) THEN 
        RAISE EXCEPTION 'User with email % does not exist.', emails; 
    END IF;

    -- Cập nhật thông tin người dùng
    UPDATE "User"
    SET 
        Name = COALESCE(names, Name), 
        Password = COALESCE(passwords, Password), 
        Phone = COALESCE(phones, Phone), 
        Address = COALESCE(addresss, Address), 
        Dob = COALESCE(dobs, Dob) 
    WHERE Email = emails; 

    -- Hiển thị thông báo thành công (tuỳ chọn)
    RAISE NOTICE 'User with email % has been updated successfully.', emails; 
END;
$$ LANGUAGE plpgsql;


-- Cập nhật thông tin voucher 
CREATE OR REPLACE PROCEDURE UpdateVoucher(
    IN input_voucher_id INT,
    IN input_description TEXT,
    IN input_expiry_date TIMESTAMP,
    IN input_points_required INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Kiểm tra xem Voucher_id có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM Voucher WHERE Voucher_id = input_voucher_id) THEN
        RAISE EXCEPTION 'Voucher with ID % does not exist.', input_voucher_id;
    END IF;

    -- Cập nhật các trường Expiry_Date, Points_Required, và Description
    UPDATE Voucher
    SET 
        Description = input_description,
        Expiry_Date = input_expiry_date,
        Points_Required = input_points_required
    WHERE Voucher_id = input_voucher_id;

    -- Hiển thị thông báo thành công
    RAISE NOTICE 'Voucher with ID % updated successfully.', input_voucher_id;
END;
$$;

-- ============================================
-- 3. Payment Procedure
-- ============================================

-- Modify the book_tickets procedure
CREATE OR REPLACE PROCEDURE book_tickets(
    p_user_id INT,
    p_showtime_id INT,
    p_seat_ids INT[],
    p_voucher_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_booking_id INT;
    v_seat_count INT;
    v_locked_seat_count INT;
BEGIN
    -- Previous validation code remains the same
    IF p_user_id IS NULL OR p_showtime_id IS NULL OR p_seat_ids IS NULL THEN
        RAISE EXCEPTION 'Required parameters cannot be null';
    END IF;

    SELECT COUNT(*)
    INTO v_seat_count
    FROM Seat s
    JOIN Showtime sh ON s.Room_id = sh.Room_id
    WHERE s.Seat_id = ANY(p_seat_ids)
    AND sh.Showtime_id = p_showtime_id;

    IF v_seat_count != array_length(p_seat_ids, 1) THEN
        RAISE EXCEPTION 'Invalid seats selected for this showtime';
    END IF;

    BEGIN
        -- Lock and verify selected seats are available
        WITH LockedSeats AS (
            SELECT Seat_id
            FROM Seat
            WHERE Seat_id = ANY(p_seat_ids)
            AND Seat_id NOT IN (
                SELECT bs.Seat_id
                FROM BookingSeat bs
                JOIN Booking b ON bs.Booking_id = b.Booking_id
                WHERE b.Showtime_id = p_showtime_id
                AND b.Status != 'Cancelled'
            )
            FOR UPDATE
        )
        SELECT COUNT(*)
        INTO v_locked_seat_count
        FROM LockedSeats;

        IF v_locked_seat_count != array_length(p_seat_ids, 1) THEN
            RAISE EXCEPTION 'Some selected seats are already booked';
        END IF;

        -- Create booking record
        INSERT INTO Booking (
            Time,
            Status,
            User_id,
            Showtime_id,
            Voucher_id
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'Pending',
            p_user_id,
            p_showtime_id,
            p_voucher_id
        )
        RETURNING Booking_id INTO v_booking_id;

        -- Link seats to booking
        INSERT INTO BookingSeat (Booking_id, Seat_id)
        SELECT v_booking_id, unnest(p_seat_ids);

        -- Voucher validation and processing remains the same
        IF p_voucher_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1
                FROM Redemption
                WHERE User_id = p_user_id
                AND Voucher_id = p_voucher_id
                AND Status = 'Available'
                AND CURRENT_TIMESTAMP <= (
                    SELECT Expiry_Date
                    FROM Voucher
                    WHERE Voucher_id = p_voucher_id
                )
            ) THEN
                RAISE EXCEPTION 'Invalid or expired voucher';
            END IF;

            UPDATE Redemption
            SET Status = 'Used',
                Redeem_Date = CURRENT_TIMESTAMP
            WHERE User_id = p_user_id
            AND Voucher_id = p_voucher_id;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$;

-- Modify the update_booking_status procedure
CREATE OR REPLACE PROCEDURE update_booking_status(
    p_booking_id INT,
    p_new_status VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(10);
    v_user_id INT;
    v_voucher_id INT;
    v_loyalty_points INT;
    v_total_amount DECIMAL;
BEGIN
    -- Validation code
    IF p_booking_id IS NULL OR p_new_status IS NULL THEN
        RAISE EXCEPTION 'Required parameters cannot be null';
    END IF;

    IF p_new_status NOT IN ('Confirmed', 'Cancelled') THEN
        RAISE EXCEPTION 'Invalid status. Must be either Confirmed or Cancelled';
    END IF;

    SELECT 
        b.Status,
        b.User_id,
        b.Voucher_id
    INTO 
        v_current_status,
        v_user_id,
        v_voucher_id
    FROM Booking b
    WHERE b.Booking_id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;

    IF v_current_status = p_new_status THEN
        RAISE EXCEPTION 'Booking is already in % status', p_new_status;
    END IF;

    IF v_current_status = 'Cancelled' THEN
        RAISE EXCEPTION 'Cannot update cancelled booking';
    END IF;

    BEGIN
        -- Update booking status
        UPDATE Booking
        SET Status = p_new_status,
            Time = CURRENT_TIMESTAMP
        WHERE Booking_id = p_booking_id;

        -- Handle voucher based on new status
        IF v_voucher_id IS NOT NULL THEN
            IF p_new_status = 'Cancelled' THEN
                UPDATE Redemption
                SET Status = 'Available'
                WHERE User_id = v_user_id
                AND Voucher_id = v_voucher_id;
            END IF;
        END IF;

        -- Modified loyalty points calculation (5% of total amount)
        IF p_new_status = 'Confirmed' THEN
            -- Calculate total amount spent
            SELECT SUM(st.Price)
            INTO v_total_amount
            FROM BookingSeat bs
            JOIN Seat s ON bs.Seat_id = s.Seat_id
            JOIN SeatType st ON s.Seattype_id = st.Seattype_id
            WHERE bs.Booking_id = p_booking_id;

            -- Calculate loyalty points (5% of total amount)
            v_loyalty_points := FLOOR(v_total_amount * 0.05);

            -- Add loyalty points
            UPDATE "User"
            SET Loyalty_Points = Loyalty_Points + v_loyalty_points
            WHERE User_id = v_user_id;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$;

CREATE OR REPLACE PROCEDURE simulate_payment(
    p_booking_id INT,
    p_payment_status BOOLEAN -- TRUE for success, FALSE for failure
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(10);
    v_user_id INT;
    v_voucher_id INT;
BEGIN
    -- Validate booking exists and is in Pending status
    SELECT 
        b.Status,
        b.User_id,
        b.Voucher_id
    INTO 
        v_current_status,
        v_user_id,
        v_voucher_id
    FROM Booking b
    WHERE b.Booking_id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;

    IF v_current_status != 'Pending' THEN
        RAISE EXCEPTION 'Can only process payment for pending bookings. Current status: %', v_current_status;
    END IF;

    -- Start transaction
    BEGIN
        IF p_payment_status THEN
            -- Payment successful
            CALL update_booking_status(
                p_booking_id := p_booking_id,
                p_new_status := 'Confirmed'
            );
        ELSE
            -- Payment failed
            CALL update_booking_status(
                p_booking_id := p_booking_id,
                p_new_status := 'Cancelled'
            );
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$;
