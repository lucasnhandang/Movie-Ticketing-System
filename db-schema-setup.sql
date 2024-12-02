CREATE TABLE "User" (
    User_id INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
	Phone VARCHAR(20),
    Address TEXT,
	Date_Joined TIMESTAMP,
	Dob DATE,
    Loyalty_Points INT
);

CREATE TABLE Movie (
    Movie_id INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
	Description TEXT,
    Language VARCHAR(50),
	Rating DECIMAL(2, 1),
    Duration INT,
    Release_Date DATE
);

CREATE TABLE Genre (
	Genre_id INT PRIMARY KEY,
	Name VARCHAR(20) NOT NULL
);

CREATE TABLE MovieGenre (
	Movie_id INT REFERENCES Movie(Movie_id),
	Genre_id INT REFERENCES Genre(Genre_id),
	PRIMARY KEY (Movie_id, Genre_id)
);

CREATE TABLE Theater (
    Theater_id INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(100),
    Total_Rooms INT
);

CREATE TABLE Room (
	Room_id INT PRIMARY KEY,
	Name VARCHAR(20) NOT NULL,
	Capacity INT,
	Theater_id INT REFERENCES Theater(Theater_id)
);

CREATE TABLE Seat (
    Seat_id INT PRIMARY KEY,
    Name VARCHAR(10),
    Type VARCHAR(10) CHECK (Type IN ('Standard', 'VIP', 'Couple')),
	Price INT,
	Room_id INT REFERENCES Room(Room_id)
);

CREATE TABLE Showtime (
    Showtime_id INT PRIMARY KEY,
    Start_Time TIME,
    End_Time TIME,
    Date DATE,
	Room_id INT REFERENCES Room(Room_id),
	Movie_id INT REFERENCES Movie(Movie_id)
);

CREATE TABLE Booking (
    Booking_id INT PRIMARY KEY,
    Date DATE,
    Status VARCHAR(10) CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    User_id INT REFERENCES "User"(User_id),
    Showtime_id INT REFERENCES Showtime(Showtime_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id)
);

CREATE TABLE BookingSeat (
	Booking_id INT REFERENCES Booking(Booking_id),
	Seat_id INT REFERENCES Seat(Seat_id),
	PRIMARY KEY (Booking_id, Seat_id)
);

CREATE TABLE Voucher (
    Voucher_id INT PRIMARY KEY,
	Description TEXT,
    Discount_Percentage INT CHECK (Discount_Percentage BETWEEN 10 AND 100),
    Expiry_Date TIMESTAMP,
    PointsRequired INT
);

CREATE TABLE Redemption (
    User_id INT REFERENCES "User"(User_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id),
    Redeem_Date TIMESTAMP,
    Status VARCHAR(10) CHECK (Status IN ('Active', 'Used', 'Expired')),
    PRIMARY KEY (User_id, Voucher_id)
);

CREATE TABLE Admin (
	Admin_id INT PRIMARY KEY,
	Name VARCHAR(100) NOT NULL,
	Email VARCHAR(50) UNIQUE NOT NULL,
	Password VARCHAR(100) NOT NULL,
	Phone VARCHAR(20),
	Dob DATE
);

CREATE TABLE ShowtimeManagement (
	Admin_id INT REFERENCES Admin(Admin_id),
	Showtime_id INT REFERENCES Showtime(Showtime_id),
	Manage_Date TIMESTAMP,
	PRIMARY KEY (Admin_id, Showtime_id)
);

CREATE TABLE MovieManagement (
	Admin_id INT REFERENCES Admin(Admin_id),
	Movie_id INT REFERENCES Movie(Movie_id),
	Manage_Date TIMESTAMP,
	PRIMARY KEY (Admin_id, Movie_id)
);

CREATE TABLE VoucherManagement (
	Admin_id INT REFERENCES Admin(Admin_id),
	Voucher_id INT REFERENCES Voucher(Voucher_id),
	Manage_Date TIMESTAMP,
	PRIMARY KEY (Admin_id, Voucher_id)
);

