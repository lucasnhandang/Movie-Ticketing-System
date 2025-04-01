-- PRIVILEGE

-- ################################################################################

-- Tạo role cho User
CREATE ROLE user_role;

-- Tạo role cho Admin
CREATE ROLE admin_role;

-- Tạo tài khoản PostgreSQL cho User
CREATE USER user_user WITH PASSWORD 'user_password';
GRANT user_role TO user_user;

-- Tạo tài khoản PostgreSQL cho Admin
CREATE USER admin_user WITH PASSWORD 'admin_password';
GRANT admin_role TO admin_user;

-- ################################################################################

-- Kích hoạt Row-Level Security để kiểm soát quyền truy cập của User và Admin
ALTER TABLE "User" ENABLE ROW LEVEL SECURITY;
ALTER TABLE Admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE Booking ENABLE ROW LEVEL SECURITY;
ALTER TABLE Redemption ENABLE ROW LEVEL SECURITY;

-- Policy cho User
-- 1: Người dùng chỉ được sửa thông tin cá nhân của chính họ
CREATE POLICY user_update_own_policy ON "User"
FOR UPDATE
USING (User_id = current_setting('app.user_id')::INT);

-- 2: Người dùng chỉ được xem thông tin cá nhân của chính họ
CREATE POLICY user_select_own_policy ON "User"
FOR SELECT
USING (User_id = current_setting('app.user_id')::INT);

-- 3: Người dùng chỉ được xem các booking của chính họ
CREATE POLICY user_booking_policy ON Booking
FOR SELECT
USING (User_id = current_setting('app.user_id')::INT);

-- 4: Người dùng chỉ được xem các redemption của chính họ
CREATE POLICY user_redemption_policy ON Redemption
FOR SELECT
USING (User_id = current_setting('app.user_id')::INT);

-- Policy cho Admin
-- 1: Admin chỉ được sửa thông tin cá nhân của chính họ
CREATE POLICY admin_update_own_policy ON Admin
FOR UPDATE
USING (Admin_id = current_setting('app.admin_id')::INT);

-- 1,5: Admin chỉ được xem thông tin cá nhân của chính họ
CREATE POLICY admin_select_own_policy ON Admin
FOR SELECT
USING (Admin_id = current_setting('app.admin_id')::INT);

-- 2: Admin không được phép xem thông tin người dùng trong bảng User
CREATE POLICY admin_no_access_user_policy ON "User"
USING (FALSE); -- Chặn hoàn toàn quyền truy cập

-- 3: Admin được toàn quyền trên bảng Booking
CREATE POLICY admin_booking_management_policy ON Booking
FOR ALL
USING (TRUE); -- Không giới hạn hàng

-- ################################################################################

-- USER
-- Xem thông tin cá nhân 
REVOKE ALL ON "User" FROM user_role;
GRANT SELECT ON "User" TO user_role;

-- Sửa các cột thông tin cá nhân
GRANT UPDATE ON "User" TO user_role;

-- Truy cập các thông tin phim, suất chiếu, ghế, voucher
GRANT SELECT ON Movie, MovieGenre, Genre, Showtime, Seat, SeatType, Room, Theater, Voucher TO user_role;

-- Thêm hoặc xem dữ liệu trong bảng Booking và Redemption
GRANT INSERT, SELECT ON Booking, Redemption TO user_role;

-- ADMIN
-- Chặn quyền truy cập vào bảng User
REVOKE ALL ON "User" FROM admin_role;
REVOKE ALL ON Admin FROM admin_role;

-- Sửa thông tin cá nhân của chính họ
GRANT UPDATE ON Admin TO admin_role;

-- Xem
GRANT SELECT ON Admin TO admin_role;

-- Cho phép tạo tài khoản admin mới
GRANT INSERT ON Admin TO admin_role;

-- Quản lý toàn quyền các bảng Movie, Showtime, Voucher và Booking
GRANT ALL PRIVILEGES ON Movie, MovieManagement, Showtime, ShowtimeManagement,
Voucher, VoucherManagement, Booking, BookingSeat, Redemption TO admin_role;

-- ################################################################################


