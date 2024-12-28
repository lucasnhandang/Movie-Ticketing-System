CREATE TABLE "User" (
    User_id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    Date_Joined TIMESTAMP,
    Dob DATE,
    Loyalty_Points INT
);

CREATE TABLE Movie (
    Movie_id SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    Language VARCHAR(10),
    Rating DECIMAL(2, 1),
    Duration INT,
    Release_Date DATE
);

CREATE TABLE Genre (
    Genre_id SERIAL PRIMARY KEY,
    Name VARCHAR(20) NOT NULL
);

CREATE TABLE MovieGenre (
    Movie_id INT REFERENCES Movie(Movie_id),
    Genre_id INT REFERENCES Genre(Genre_id),
    PRIMARY KEY (Movie_id, Genre_id)
);

CREATE TABLE Theater (
    Theater_id SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(100),
    Total_Rooms INT
);

CREATE TABLE Room (
    Room_id SERIAL PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Capacity INT,
    Theater_id INT REFERENCES Theater(Theater_id)
);

CREATE TABLE SeatType (
    Seattype_id SERIAL PRIMARY KEY,
    Name VARCHAR(20),
    Price INT
);

CREATE TABLE Seat (
    Seat_id SERIAL PRIMARY KEY,
    Row VARCHAR(2) NOT NULL,
    Number INT NOT NULL,
    Seattype_id INT REFERENCES SeatType(Seattype_id),
    Room_id INT REFERENCES Room(Room_id)
);

CREATE TABLE Showtime (
    Showtime_id SERIAL PRIMARY KEY,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    Date DATE NOT NULL,
    Room_id INT REFERENCES Room(Room_id),
    Movie_id INT REFERENCES Movie(Movie_id)
);

CREATE TABLE Voucher (
    Voucher_id SERIAL PRIMARY KEY,
    Description TEXT,
    Discount_Percentage INT CHECK (Discount_Percentage BETWEEN 10 AND 100),
    Expiry_Date TIMESTAMP,
    Points_Required INT
);

CREATE TABLE Booking (
    Booking_id SERIAL PRIMARY KEY,
    Time TIMESTAMP NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    User_id INT NOT NULL REFERENCES "User"(User_id),
    Showtime_id INT NOT NULL REFERENCES Showtime(Showtime_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id)
);

CREATE TABLE BookingSeat (
    Booking_id INT REFERENCES Booking(Booking_id),
    Seat_id INT REFERENCES Seat(Seat_id),
    PRIMARY KEY (Booking_id, Seat_id)
);

CREATE TABLE Redemption (
    User_id INT REFERENCES "User"(User_id),
    Voucher_id INT REFERENCES Voucher(Voucher_id),
    Redeem_Date TIMESTAMP NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Available', 'Used', 'Expired')),
    PRIMARY KEY (User_id, Voucher_id)
);

CREATE TABLE Admin (
    Admin_id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Dob DATE
);

CREATE TABLE ShowtimeManagement (
    Manage_id SERIAL PRIMARY KEY,             
    Admin_id INT REFERENCES Admin(Admin_id),  
    Showtime_id INT REFERENCES Showtime(Showtime_id), 
    Manage_date TIMESTAMP NOT NULL,
    Description VARCHAR(10)
);

CREATE TABLE MovieManagement (
    Manage_id SERIAL PRIMARY KEY,             
    Admin_id INT REFERENCES Admin(Admin_id),  
    Movie_id INT REFERENCES Movie(Movie_id),  
    Manage_date TIMESTAMP NOT NULL,
    Description VARCHAR(10)                    
);

CREATE TABLE VoucherManagement (
    Manage_id SERIAL PRIMARY KEY,             
    Admin_id INT REFERENCES Admin(Admin_id),  
    Voucher_id INT REFERENCES Voucher(Voucher_id),
    Manage_date TIMESTAMP NOT NULL,
    Description VARCHAR(10)                     
);
