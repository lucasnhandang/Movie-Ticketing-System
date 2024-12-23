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
    IN input_voucher_id INT,
    IN input_redeem_date TIMESTAMP,
    IN input_status VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Redemption (User_id, Voucher_id, Redeem_Date, Status)
    VALUES (input_user_id, input_voucher_id, input_redeem_date, input_status);
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
IN input_discount_percentage INT, 
IN input_expiry_date TIMESTAMP, 
IN input_points_required INT 
) 
LANGUAGE plpgsql AS $$ 
BEGIN 
UPDATE Voucher 
SET 	Description = input_description, 
Discount_Percentage = input_discount_percentage, 
Expiry_Date = input_expiry_date, 
Points_Required = input_points_required 
WHERE Voucher_id = input_voucher_id; 
END;
$$;


