CREATE TABLE "User" (
    User_id INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
	Phone VARCHAR(20),
    Address VARCHAR(200),
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
    Name VARCHAR(200) NOT NULL,
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

CREATE TABLE SeatType (
    Seattype_id INT PRIMARY KEY,
    Name VARCHAR(20),
    Price INT
);

CREATE TABLE Seat (
    Seat_id INT PRIMARY KEY,
    Row VARCHAR(2),
    Number INT,
    Seattype_id INT REFERENCES SeatType(Seattype_id),
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

CREATE TABLE Voucher (
    Voucher_id INT PRIMARY KEY,
	Description TEXT,
    Discount_Percentage INT CHECK (Discount_Percentage BETWEEN 10 AND 100),
    Expiry_Date TIMESTAMP,
    PointsRequired INT
);

CREATE TABLE Booking (
    Booking_id INT PRIMARY KEY,
    Date DATE,
    Status VARCHAR(10) CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    User_id INT REFERENCES "User"(User_id),
    Showtime_id INT REFERENCES Showtime(Showtime_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id)
);

CREATE TABLE BookingSeatShowtime (
    Booking_id INT REFERENCES Booking(Booking_id),
    Seat_id INT REFERENCES Seat(Seat_id),
    Showtime_id INT REFERENCES Showtime(Showtime_id),
    PRIMARY KEY (Booking_id, Seat_id, Showtime_id)
);

CREATE TABLE Redemption (
    User_id INT REFERENCES "User"(User_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id),
    Redeem_Date TIMESTAMP,
    Status VARCHAR(10) CHECK (Status IN ('Available', 'Used', 'Expired')),
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
    manage_id INT PRIMARY KEY,             
    admin_id INT REFERENCES Admin(Admin_id),  
    showtime_id INT REFERENCES Showtime(Showtime_id), 
    manage_date TIMESTAMP,
	description VARCHAR(10)
);

CREATE TABLE MovieManagement (
    manage_id INT PRIMARY KEY,             
    admin_id INT REFERENCES Admin(Admin_id),  
    movie_id INT REFERENCES Movie(Movie_id),  
    manage_date TIMESTAMP,
	description VARCHAR(10)                    
);

CREATE TABLE VoucherManagement (
    manage_id INT PRIMARY KEY,             
    admin_id INT REFERENCES Admin(Admin_id),  
    voucher_id INT REFERENCES Voucher(Voucher_id),
    manage_date TIMESTAMP,
	description VARCHAR(10)                     
);
