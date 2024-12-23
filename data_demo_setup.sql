-- Theater table
INSERT INTO Theater (Name, Address, City, Total_Rooms) VALUES
( 'Galaxy Cinema Nguyen Du', '116 Nguyen Du, Quan 1', 'Ho Chi Minh', 8),
( 'CGV Vincom Ba Trieu', '191 Ba Trieu, Hai Ba Trung', 'Ha Noi', 10),
( 'Lotte Cinema Dong Da', '229 Tay Son, Dong Da', 'Ha Noi', 7),
( 'BHD Star Bitexco', 'Tang 3, TTTM Icon 68, Quan 1', 'Ho Chi Minh', 5),
( 'CineStar Quoc Thanh', '271 Nguyen Trai, Quan 1', 'Ho Chi Minh', 6);

-- Room table
INSERT INTO Room (Name, Capacity, Theater_id) VALUES
('Room 1', 150, 1),
('Room 2', 120, 1),
('Room 3', 100, 1),
('Room 4', 90, 1),
('Room 5', 80, 1),
('Room 6', 100, 1),
('Room 7', 150, 1),
('Room 8', 120, 1),

('Room 1', 100, 2),
('Room 2', 150, 2),
('Room 3', 150, 2),
('Room 4', 120, 2),
('Room 5', 100, 2),
('Room 6', 90, 2),
('Room 7', 140, 2),
('Room 8', 150, 2),
('Room 9', 130, 2),
('Room 10', 110, 2),

('Room 1', 120, 3),
('Room 2', 100, 3),
('Room 3', 150, 3),
('Room 4', 100, 3),
('Room 5', 180, 3),
('Room 6', 90, 3),
('Room 7', 130, 3),

('Room 1', 100, 4),
('Room 2', 120, 4),
('Room 3', 150, 4),
('Room 4', 80, 4),
('Room 5', 80, 4),

('Room 1', 90, 5),
('Room 2', 110, 5),
('Room 3', 120, 5),
('Room 4', 100, 5),
('Room 5', 150, 5),
('Room 6', 80, 5);

-- SeatType Table
INSERT INTO SeatType (Name, Price) VALUES
('Standard', 100000), -- Ghế tiêu chuẩn
('VIP', 200000),      -- Ghế VIP
('Couple', 300000);   -- Ghế đôi

-- Seat Table
DO $$
DECLARE
    room RECORD;
    row_letter CHAR := 'A';
    seat_number INT;
    seattype_id INT;
    total_rows INT; -- Tổng số hàng cho từng phòng
BEGIN
    -- Lặp qua từng phòng trong bảng Room
    FOR room IN SELECT Room_id, Capacity FROM Room LOOP
        seat_number := 1;
        row_letter := 'A';
        total_rows := CEIL(room.Capacity::FLOAT / 20); -- Giả định mỗi hàng có tối đa 20 ghế

        -- Tạo ghế cho từng phòng
        FOR i IN 1..room.Capacity LOOP
            -- Gán giá trị seattype_id theo điều kiện
            IF row_letter IN ('A', 'B') THEN
                seattype_id := 1; -- Standard (hai hàng đầu)
            ELSIF row_letter = CHR(ASCII('A') + total_rows - 1) THEN
                seattype_id := 3; -- Couple (hàng cuối cùng)
            ELSE
                seattype_id := 2; -- VIP (các hàng còn lại)
            END IF;

            INSERT INTO Seat (Row, Number, Seattype_id, Room_id)
            VALUES (row_letter, seat_number, seattype_id, room.Room_id);

            -- Tăng Seat_id và số ghế
            seat_number := seat_number + 1;

            -- Reset hàng khi số ghế vượt quá 20
            IF seat_number > 20 THEN
                seat_number := 1;
                row_letter := CHR(ASCII(row_letter) + 1);
            END IF;
        END LOOP;

        -- Reset hàng cho phòng tiếp theo
        row_letter := 'A';
    END LOOP;
END $$;

-- Voucher table
INSERT INTO Voucher (Description, Discount_Percentage, Expiry_Date, Points_Required) VALUES
('10% discount', 10, '2025-01-31 23:59:59', 100),
('20% discount', 20, '2025-03-31 23:59:59', 200),
('30% discount', 30, '2024-11-30 23:59:59', 300),
('40% discount', 40, '2024-09-30 23:59:59', 400),
('50% discount', 50, '2025-12-31 23:59:59', 500),
('60% discount', 60, '2025-05-31 23:59:59', 600),
('70% discount', 70, '2025-04-30 23:59:59', 700),
('80% discount', 80, '2025-07-31 23:59:59', 800),
('90% discount', 90, '2025-08-31 23:59:59', 900),
('100% discount', 100, '2025-10-31 23:59:59', 1000);

-- User table
DO $$
DECLARE
    name VARCHAR(100);
    email VARCHAR(100);
    password VARCHAR(50);
    phone VARCHAR(20);
    address VARCHAR(200);
    date_joined TIMESTAMP;
    dob DATE;
    loyalty_points INT;
BEGIN
    FOR i IN 1..100 LOOP
        -- Generate random data
        name := 'User_' || i;
        email := 'user_' || i || '@example.com';
        password := 'password' || i;
        phone := '0' || (1000000000 + FLOOR(RANDOM() * 9000000000)::BIGINT);
        address := 'Street ' || FLOOR(RANDOM() * 100)::TEXT || ', City ' || FLOOR(RANDOM() * 50)::TEXT;
        date_joined := '2023-01-01 00:00:00'::TIMESTAMP + (RANDOM() * INTERVAL '365 days');
        dob := '1970-01-01'::DATE + (RANDOM() * INTERVAL '18250 days'); -- Random date between 1970 and 2020
        loyalty_points := FLOOR(RANDOM() * 501)::INT; -- Points between 0 and 500
        
        -- Insert data
        INSERT INTO "User" (Name, Email, Password, Phone, Address, Date_Joined, Dob, Loyalty_Points)
        VALUES (name, email, password, phone, address, date_joined, dob, loyalty_points);
        
    END LOOP;
END $$;

-- Admin table
INSERT INTO Admin (Name, Email, Password, Phone, Dob) VALUES
('Admin_John Doe', 'admin_johndoe@example.com', 'adminpass123', '0912345678', '1985-04-15'),
('Admin_Jane Smith', 'admin_janesmith@example.com', 'adminpass456', '0923456789', '1990-06-20'),
('Admin_Michael Johnson', 'admin_michaelj@example.com', 'adminpass789', '0934567890', '1987-09-12'),
('Admin_Emily Davis', 'admin_emilyd@example.com', 'adminpass012', '0945678901', '1992-01-25'),
('Admin_William Brown', 'admin_williamb@example.com', 'adminpass345', '0956789012', '1980-03-05'),
('Admin_Olivia Wilson', 'admin_oliviaw@example.com', 'adminpass678', '0967890123', '1995-08-19'),
('Admin_James Martinez', 'admin_jamesm@example.com', 'adminpass901', '0978901234', '1989-11-03'),
('Admin_Sophia Anderson', 'admin_sophiaa@example.com', 'adminpass234', '0989012345', '1993-05-14'),
('Admin_Benjamin Clark', 'admin_benjaminc@example.com', 'adminpass567', '0990123456', '1984-07-22'),
('Admin_Ava Hernandez', 'admin_avah@example.com', 'adminpass890', '0911234567', '1998-02-10'),
('Admin_Liam Taylor', 'admin_liamt@example.com', 'adminpass101', '0922345678', '1983-10-29'),
('Admin_Isabella Moore', 'admin_isabellam@example.com', 'adminpass202', '0933456789', '1990-06-17'),
('Admin_Elijah Thomas', 'admin_elijaht@example.com', 'adminpass303', '0944567890', '1985-09-03'),
('Admin_Charlotte Lee', 'admin_charlottel@example.com', 'adminpass404', '0955678901', '1997-12-24'),
('Admin_Lucas White', 'admin_lucasw@example.com', 'adminpass505', '0966789012', '1981-04-12'),
('Admin_Amelia Harris', 'admin_ameliah@example.com', 'adminpass606', '0977890123', '1992-09-16'),
('Admin_Henry Martin', 'admin_henrym@example.com', 'adminpass707', '0988901234', '1988-07-09'),
('Admin_Mia Young', 'admin_miay@example.com', 'adminpass808', '0999012345', '1991-03-30'),
('Admin_Jackson Walker', 'admin_jacksonw@example.com', 'adminpass909', '0912345679', '1986-05-18'),
('Admin_Ella King', 'admin_ellak@example.com', 'adminpass010', '0923456780', '1994-08-11');

-- Movie table
INSERT INTO Movie (Title, Description, Language, Rating, Duration, Release_Date) VALUES
('The Great Adventure', 'An epic journey through uncharted lands.', 'EN', 8.2, 120, '2023-12-01'),
('Love in the Moonlight', 'A romantic drama set in the early 20th century.', 'EN', 7.5, 95, '2023-11-15'),
('Superheroes Unite', 'A team of superheroes come together to save the world.', 'EN', 8.7, 135, '2023-10-10'),
('Silent Whisper', 'A thriller that keeps you on the edge of your seat.', 'EN', 8.1, 110, '2023-09-05'),
('The Lost Kingdom', 'A story of a hidden kingdom and its mystical secrets.', 'EN', 7.8, 125, '2023-08-01'),
('Summer Memories', 'A heartfelt drama about growing up and finding love.', 'EN', 7.9, 115, '2023-07-10'),
('Dragon’s Flame', 'A fantasy film about a young warrior and a dragon.', 'EN', 8.5, 140, '2023-06-20'),
('Mystery at Midnight', 'A detective story that unfolds at midnight.', 'EN', 7.6, 100, '2023-05-15'),
('Space Odyssey', 'A journey through space to discover new planets.', 'EN', 9.0, 150, '2023-04-01'),
('The Shadow of the Past', 'A psychological drama about uncovering hidden secrets.', 'EN', 7.4, 105, '2023-03-12'),
('Time Traveler', 'A science fiction story about traveling through time.', 'EN', 8.3, 125, '2023-02-20'),
('The Heist', 'A high-stakes heist movie filled with action and suspense.', 'EN', 7.8, 130, '2023-01-15'),
('The Secret Garden', 'A magical journey through a hidden garden.', 'EN', 7.2, 95, '2022-12-10'),
('Under the Sea', 'A documentary about the wonders of the ocean.', 'EN', 8.0, 110, '2022-11-05'),
('Zombie Apocalypse', 'A group of survivors fight to stay alive in a world overrun by zombies.', 'EN', 6.9, 140, '2022-10-01'),
('The Golden Age', 'A historical drama set in the 18th century.', 'EN', 7.7, 130, '2022-09-10'),
('The Invisible Man', 'A thriller about a scientist who becomes invisible and goes rogue.', 'EN', 8.4, 120, '2022-08-15'),
('Dreams of Tomorrow', 'A futuristic tale of a world where dreams are controlled.', 'EN', 7.9, 125, '2022-07-01'),
('The Braveheart', 'A historical drama based on the true story of a brave warrior.', 'EN', 8.1, 140, '2022-06-10'),
('The Witch’s Curse', 'A dark fantasy about a powerful witch seeking revenge.', 'EN', 7.5, 115, '2022-05-20');

-- Redemption table
INSERT INTO Redemption (User_id, Voucher_id, Redeem_Date, Status) VALUES
(1, 1, '2024-12-01 14:00:00', 'Available'),
(2, 2, '2024-12-02 15:30:00', 'Available'),
(3, 3, '2024-12-03 16:00:00', 'Available'),
(4, 4, '2024-12-04 17:15:00', 'Available'),
(5, 5, '2024-12-05 18:45:00', 'Available'),
(6, 6, '2024-12-06 10:00:00', 'Available'),
(7, 7, '2024-12-07 11:30:00', 'Available'),
(8, 8, '2024-12-08 13:00:00', 'Available'),
(9, 9, '2024-12-09 14:30:00', 'Available'),
(10, 10, '2024-12-10 16:00:00', 'Available'),
(11, 1, '2024-12-11 17:00:00', 'Available'),
(12, 2, '2024-12-12 18:00:00', 'Available'),
(13, 3, '2024-12-13 19:30:00', 'Available'),
(14, 4, '2024-12-14 20:00:00', 'Available'),
(15, 5, '2024-12-15 21:30:00', 'Available'),
(16, 6, '2024-12-16 22:00:00', 'Available'),
(17, 7, '2024-12-17 23:00:00', 'Available'),
(18, 8, '2024-12-18 09:30:00', 'Available'),
(19, 9, '2024-12-19 10:00:00', 'Available'),
(20, 10, '2024-12-20 11:00:00', 'Available');

-- Genre table
INSERT INTO Genre (Name) VALUES
('Action'),
('Comedy'),
('Drama'),
('Thriller'),
('Romance'),
('Horror'),
('Sci-Fi'),
('Fantasy');

-- MovieGenre table 
INSERT INTO MovieGenre (Movie_id, Genre_id) VALUES
(1, 1),  -- The Great Adventure -> Action
(1, 7),  -- The Great Adventure -> Sci-Fi
(1, 8),  -- The Great Adventure -> Fantasy
(2, 5),  -- Love in the Moonlight -> Romance
(2, 3),  -- Love in the Moonlight -> Drama
(2, 8),  -- Love in the Moonlight -> Fantasy
(3, 1),  -- Superheroes Unite -> Action
(3, 7),  -- Superheroes Unite -> Sci-Fi
(3, 5),  -- Superheroes Unite -> Romance
(4, 4),  -- Silent Whisper -> Thriller
(4, 3),  -- Silent Whisper -> Drama
(4, 5),  -- Silent Whisper -> Romance
(5, 8),  -- The Lost Kingdom -> Fantasy
(5, 1),  -- The Lost Kingdom -> Action
(5, 3),  -- The Lost Kingdom -> Drama
(6, 5),  -- Summer Memories -> Romance
(6, 3),  -- Summer Memories -> Drama
(6, 7),  -- Summer Memories -> Sci-Fi
(7, 8),  -- Dragon’s Flame -> Fantasy
(7, 1),  -- Dragon’s Flame -> Action
(7, 4),  -- Dragon’s Flame -> Thriller
(8, 4),  -- Mystery at Midnight -> Thriller
(8, 3),  -- Mystery at Midnight -> Drama
(8, 5),  -- Mystery at Midnight -> Romance
(9, 7),  -- Space Odyssey -> Sci-Fi
(9, 8),  -- Space Odyssey -> Fantasy
(9, 1),  -- Space Odyssey -> Action
(10, 3), -- The Shadow of the Past -> Drama
(10, 1), -- The Shadow of the Past -> Action
(10, 5), -- The Shadow of the Past -> Romance
(11, 7), -- Time Traveler -> Sci-Fi
(11, 1), -- Time Traveler -> Action
(11, 8), -- Time Traveler -> Fantasy
(12, 1), -- The Heist -> Action
(12, 4), -- The Heist -> Thriller
(12, 7), -- The Heist -> Sci-Fi
(13, 7), -- The Secret Garden -> Sci-Fi
(13, 8), -- The Secret Garden -> Fantasy
(13, 1), -- The Secret Garden -> Action
(14, 1), -- Under the Sea -> Action
(14, 8), -- Under the Sea -> Fantasy
(14, 7), -- Under the Sea -> Sci-Fi
(15, 6), -- Zombie Apocalypse -> Horror
(15, 1), -- Zombie Apocalypse -> Action
(15, 7), -- Zombie Apocalypse -> Sci-Fi
(16, 3), -- The Golden Age -> Drama
(16, 8), -- The Golden Age -> Fantasy
(16, 1), -- The Golden Age -> Action
(17, 4), -- The Invisible Man -> Thriller
(17, 7), -- The Invisible Man -> Sci-Fi
(17, 3), -- The Invisible Man -> Drama
(18, 7), -- Dreams of Tomorrow -> Sci-Fi
(18, 1), -- Dreams of Tomorrow -> Action
(18, 4), -- Dreams of Tomorrow -> Thriller
(19, 3), -- The Braveheart -> Drama
(19, 8), -- The Braveheart -> Fantasy
(19, 4), -- The Braveheart -> Thriller
(20, 6), -- The Witch’s Curse -> Horror
(20, 4), -- The Witch’s Curse -> Thriller
(20, 8); -- The Witch’s Curse -> Fantasy

-- MovieManagement table
INSERT INTO MovieManagement (admin_id, movie_id, manage_date, description) VALUES
(1, 1, '2024-12-01 10:00:00', 'Added'),
(2, 2, '2024-12-02 14:30:00', 'Updated'),
(3, 3, '2024-12-03 16:00:00', 'Added'),
(4, 4, '2024-12-04 11:15:00', 'Removed'),
(5, 5, '2024-12-05 09:45:00', 'Updated'),
(6, 6, '2024-12-06 12:00:00', 'Added'),
(7, 7, '2024-12-07 13:30:00', 'Updated'),
(8, 8, '2024-12-08 15:00:00', 'Removed'),
(9, 9, '2024-12-09 17:00:00', 'Added'),
(10, 10, '2024-12-10 18:30:00', 'Updated'),
(11, 11, '2024-12-11 10:00:00', 'Added'),
(12, 12, '2024-12-12 14:00:00', 'Updated'),
(13, 13, '2024-12-13 16:00:00', 'Added'),
(14, 14, '2024-12-14 11:00:00', 'Removed'),
(15, 15, '2024-12-15 13:30:00', 'Updated'),
(16, 16, '2024-12-16 12:30:00', 'Added'),
(17, 17, '2024-12-17 14:30:00', 'Removed'),
(18, 18, '2024-12-18 15:30:00', 'Added'),
(19, 19, '2024-12-19 10:00:00', 'Updated'),
(20, 20, '2024-12-20 16:00:00', 'Removed');

-- VoucherManagement table
INSERT INTO VoucherManagement (admin_id, voucher_id, manage_date, description) VALUES
(1, 1, '2024-12-01 10:00:00', 'Added'),
(2, 2, '2024-12-02 14:30:00', 'Added'),
(3, 3, '2024-12-03 16:00:00', 'Added'),
(4, 4, '2024-12-04 11:15:00', 'Added'),
(5, 5, '2024-12-05 09:45:00', 'Added'),
(6, 6, '2024-12-06 12:00:00', 'Added'),
(7, 7, '2024-12-07 13:30:00', 'Added'),
(8, 8, '2024-12-08 15:00:00', 'Added'),
(9, 9, '2024-12-09 17:00:00', 'Added'),
(10, 10, '2024-12-10 18:30:00', 'Added');

-- Showtime table
DO $$
DECLARE
    room RECORD;
    showtime_id INT := 1;
    start_time TIME;
    end_time TIME;
    show_date DATE;
    movie_count INT;  -- Số lượng phim
    movie_index INT;  -- Chỉ số để chọn Movie_id
BEGIN
    -- Đếm số lượng phim trong bảng Movie
    SELECT COUNT(*) INTO movie_count FROM Movie;
    
    -- Lặp qua từng phòng trong bảng Room
    FOR room IN SELECT Room_id FROM Room LOOP
        -- Lặp qua 5 ngày
        FOR day_offset IN 1..5 LOOP
            show_date := CURRENT_DATE + day_offset;  -- Tính ngày bắt đầu từ ngày hiện tại
            
            -- Lặp qua 3 showtime trong 1 ngày
            FOR i IN 1..3 LOOP
                -- Tính thời gian bắt đầu và kết thúc showtime
                start_time := TIME '10:00' + (i - 1) * INTERVAL '3 hours';
                end_time := start_time + INTERVAL '2 hours';
                
                -- Tính Movie_id phân phối tuần tự
                movie_index := (showtime_id - 1) % movie_count + 1;

                -- Thêm record vào bảng Showtime
                INSERT INTO Showtime (Showtime_id, Start_Time, End_Time, Date, Room_id, Movie_id)
                VALUES (showtime_id, start_time, end_time, show_date, room.Room_id, movie_index);

                -- Tăng Showtime_id
                showtime_id := showtime_id + 1;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- ShowtimeManagament table
DO $$
DECLARE
    showtime RECORD;
    admin_id INT;
BEGIN
    -- Lặp qua từng Showtime trong bảng Showtime
    FOR showtime IN SELECT Showtime_id, Room_id FROM Showtime LOOP
        -- Lựa chọn ngẫu nhiên admin_id từ 1 đến 20
        admin_id := (SELECT FLOOR(1 + (RANDOM() * 20))::INT);
        
        -- Thêm record vào bảng ShowtimeManagement
        INSERT INTO ShowtimeManagement (admin_id, showtime_id, manage_date, description)
        VALUES (admin_id, showtime.Showtime_id, CURRENT_TIMESTAMP, 'Updated');
    END LOOP;
END $$;

--
DO $$
DECLARE
    user_id INT;
    showtime_id INT;
    seat_id INT;
    num_seats INT;
    status VARCHAR(10);
    available_seat RECORD;
    voucher_id INT;
    new_booking_id INT;  -- To capture the auto-generated Booking_id
BEGIN
    -- Lặp qua từng booking
    FOR i IN 1..100 LOOP
        -- Chọn ngẫu nhiên user_id từ 1 đến 100
        user_id := (SELECT FLOOR(1 + (RANDOM() * 100))::INT);
        
        -- Chọn ngẫu nhiên showtime_id từ bảng Showtime
        showtime_id := (SELECT FLOOR(1 + (RANDOM() * (SELECT COUNT(*) FROM Showtime)))::INT);
        
        -- Chọn ngẫu nhiên số ghế từ 1 đến 5
        num_seats := (SELECT FLOOR(1 + (RANDOM() * 5))::INT);
        
        -- Chọn ngẫu nhiên trạng thái từ 'Pending', 'Confirmed', 'Cancelled'
        status := (SELECT CASE 
                            WHEN RANDOM() < 0.5 THEN 'Pending'
                            WHEN RANDOM() < 0.8 THEN 'Confirmed'
                            ELSE 'Cancelled'
                          END);
        
        -- Chọn ngẫu nhiên voucher_id từ 1 đến 10 hoặc không chọn voucher
        IF RANDOM() < 0.3 THEN  -- 30% xác suất sử dụng voucher
            voucher_id := (SELECT FLOOR(1 + (RANDOM() * 10))::INT);
        ELSE
            voucher_id := NULL;
        END IF;
        
        -- Thêm bản ghi vào bảng Booking
        INSERT INTO Booking (Time, Status, User_id, Showtime_id, Voucher_id)
        VALUES (CURRENT_TIMESTAMP, status, user_id, showtime_id, voucher_id)
        RETURNING Booking_id INTO new_booking_id;  -- Capture the auto-generated Booking_id
        
        -- Lặp qua số ghế cần đặt (1 đến 5 ghế)
        FOR seat IN 1..num_seats LOOP
            -- Chọn ngẫu nhiên ghế chưa được đặt
            LOOP
                -- Lấy một ghế chưa được đặt (kiểm tra xem ghế đã được chọn chưa trong BookingSeat)
                SELECT s.Seat_id INTO available_seat
                FROM Seat s
                WHERE s.Seat_id NOT IN (
                    SELECT bs.Seat_id 
                    FROM BookingSeat bs
                    WHERE bs.Booking_id IN (
                        SELECT b.Booking_id
                        FROM Booking b
                        WHERE b.Status = 'Confirmed' OR b.Status = 'Pending' OR b.Status = 'Cancelled'
                    )
                )
                LIMIT 1;
                
                -- Nếu không có ghế chưa được đặt, dừng vòng lặp
                IF NOT FOUND THEN
                    EXIT;
                END IF;
                
                seat_id := available_seat.Seat_id;
                
                -- Thêm ghế vào bảng BookingSeat
                INSERT INTO BookingSeat (Booking_id, Seat_id)
                VALUES (new_booking_id, seat_id);
                
                -- Nếu ghế đã được book, chọn ghế tiếp theo
                EXIT;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;
