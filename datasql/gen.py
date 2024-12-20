import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

# Helper function for generating unique values
def generate_unique(fake_function, existing_set, *args, **kwargs):
    while True:
        value = fake_function(*args, **kwargs)
        if value not in existing_set:
            existing_set.add(value)
            return value

# Function to write data to INSERT INTO SQL file
def write_to_sql(filename, data, table_name):
    with open(filename, 'w', encoding='utf-8') as file:
        # Write the header insert statement
        columns = ', '.join(data[0].keys())
        file.write(f"INSERT INTO {table_name} ({columns}) VALUES\n")
        
        # Write all data rows
        for i, row in enumerate(data):
            values = ', '.join([f"'{v}'" if isinstance(v, str) else str(v) for v in row.values()])
            if i < len(data) - 1:
                file.write(f"({values}),\n")
            else:
                file.write(f"({values});\n")  # Close with semicolon at the very end

# Generate Users
def generate_users(n=5000):
    users = []
    used_emails = set()  # Set to keep track of already used emails
    
    for _ in range(n):
        address = fake.address().replace('\n', ' ').replace('\r', ' ')  # Remove newline characters
        
        # Generate a phone number with a maximum of 15 digits
        phone_number = fake.phone_number()
        phone_number = ''.join(filter(str.isdigit, phone_number))[:15]  # Keep only digits and limit to 15 digits

        # Ensure email is unique
        email = fake.email()
        while email in used_emails:
            email = fake.email()  # Regenerate email if it's already used
        used_emails.add(email)  # Add email to the set of used emails

        users.append({
            "User_id": _+1,
            "Name": fake.name(),
            "Email": email,  # Ensure unique email
            "Password": fake.password(),
            "Phone": phone_number,  # Ensure phone number is max 15 digits
            "Address": address,  # Now address is a single line
            "Date_Joined": fake.date_this_decade().strftime('%Y-%m-%d %H:%M:%S'),
            "Dob": fake.date_of_birth().strftime('%Y-%m-%d'),
            "Loyalty_Points": random.randint(0, 1000)
        })
    return users

# Generate Theaters
def generate_theaters(n=20):
    theaters = []
    for i in range(n):
        theaters.append({
            "Theater_id": i + 1,
            "Name": fake.company(),
            "Address": fake.address().replace("\n", " "),
            "City": fake.city(),
            "Total_Rooms": random.randint(10, 15)
        })
    return theaters

# Generate Rooms
def generate_rooms(theaters):
    rooms = []
    room_id = 1
    for theater in theaters:
        for _ in range(theater['Total_Rooms']):
            rooms.append({
                "Room_id": room_id,
                "Name": f"Room {room_id}",
                "Capacity": random.choice([50, 100]),
                "Theater_id": theater['Theater_id']
            })
            room_id += 1
    return rooms

# Generate Seat Types
def generate_seat_types():
    return [
        {"Seattype_id": 1, "Name": "Standard", "Price": 50},
        {"Seattype_id": 2, "Name": "VIP", "Price": 100},
        {"Seattype_id": 3, "Name": "Couple", "Price": 150}
    ]

# Generate Seats
def generate_seats(rooms, seat_types):
    seats = []
    seat_id = 1
    for room in rooms:
        for row in "ABCDEFGH":
            for number in range(1, 20):
                seat_type = random.choice(seat_types)
                seats.append({
                    "Seat_id": seat_id,
                    "Row": row,
                    "Number": number,
                    "Seattype_id": seat_type['Seattype_id'],
                    "Room_id": room['Room_id']
                })
                seat_id += 1
    return seats

# Generate Showtimes
def generate_showtimes(rooms, n=500):
    showtimes = []
    for i in range(n):
        showtimes.append({
            "Showtime_id": i + 1,
            "Start_Time": fake.time(),
            "End_Time": fake.time(),
            "Date": fake.date_this_year().strftime('%Y-%m-%d'),
            "Room_id": random.choice(rooms)['Room_id'],
            "Movie_id": random.randint(1, 20)  # Movie_id constrained to 1-20
        })
    return showtimes

# Generate Vouchers
def generate_vouchers(n=20):
    vouchers = []
    for i in range(n):
        discount = random.randint(10, 100)
        vouchers.append({
            "Voucher_id": i + 1,
            "Description": fake.sentence(),
            "Discount_Percentage": discount,
            "Expiry_Date": (datetime.now() + timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d %H:%M:%S'),
            "PointsRequired": discount
        })
    return vouchers

# Generate Bookings
def generate_bookings(users, showtimes, vouchers, n=10000):
    bookings = []
    for i in range(n):
        bookings.append({
            "Booking_id": i + 1,
            "Date": fake.date_this_year().strftime('%Y-%m-%d'),
            "Status": random.choice(['Pending', 'Confirmed', 'Cancelled']),
            "User_id": random.choice(users)['User_id'],
            "Showtime_id": random.choice(showtimes)['Showtime_id'],
            "Voucher_id": random.choice(vouchers)['Voucher_id'] if random.random() > 0.5 else None
        })
    return bookings

# Generate Admins
def generate_admins(n=30):
    admins = []
    used_emails = set()  # Set to keep track of already used emails
    used_phones = set()  # Set to keep track of already used phone numbers
    
    for _ in range(n):
        # Generate a phone number with a maximum of 15 digits
        phone_number = fake.phone_number()
        phone_number = ''.join(filter(str.isdigit, phone_number))[:15]  # Keep only digits and limit to 15 digits
        
        # Ensure phone number is unique
        while phone_number in used_phones:
            phone_number = fake.phone_number()  # Regenerate phone number if it's already used
            phone_number = ''.join(filter(str.isdigit, phone_number))[:15]  # Ensure it's no more than 15 digits
        used_phones.add(phone_number)  # Add phone number to the set of used phone numbers
        
        # Ensure email is unique
        email = fake.email()
        while email in used_emails:
            email = fake.email()  # Regenerate email if it's already used
        used_emails.add(email)  # Add email to the set of used emails
        
        admins.append({
            "Admin_id": _+1,
            "Name": fake.name(),
            "Email": email,  # Ensure unique email
            "Password": fake.password(),
            "Phone": phone_number,  # Ensure phone number is max 15 digits
            "Dob": fake.date_of_birth().strftime('%Y-%m-%d')
        })
    return admins

# Generate BookingSeatShowtime
def generate_booking_seat_showtime(bookings, seats, showtimes):
    booking_seat_showtime = []
    for booking in bookings:
        seat = random.choice(seats)
        booking_seat_showtime.append({
            "Booking_id": booking['Booking_id'],
            "Seat_id": seat['Seat_id'],
            "Showtime_id": booking['Showtime_id']
        })
    return booking_seat_showtime

# Generate Redemption
def generate_redemptions(users, vouchers, n=5000):
    redemptions = []
    unique_pairs = set()

    while len(redemptions) < n:
        user_id = random.choice(users)['User_id']
        voucher_id = random.choice(vouchers)['Voucher_id']

        if (user_id, voucher_id) not in unique_pairs:
            unique_pairs.add((user_id, voucher_id))
            redemptions.append({
                "User_id": user_id,
                "Voucher_id": voucher_id,
                "Redeem_Date": fake.date_this_year().strftime('%Y-%m-%d %H:%M:%S'),
                "Status": random.choice(['Available', 'Used', 'Expired'])
            })

    return redemptions

# Generate ShowtimeManagement
def generate_showtime_management(admins, showtimes):
    managements = []
    unique_showtime_ids = set()

    for showtime in showtimes:
        admin_id = random.choice(admins)['Admin_id']
        if showtime['Showtime_id'] not in unique_showtime_ids:
            unique_showtime_ids.add(showtime['Showtime_id'])
            managements.append({
                "manage_id": len(managements) + 1,
                "admin_id": admin_id,
                "showtime_id": showtime['Showtime_id'],
                "manage_date": fake.date_this_year().strftime('%Y-%m-%d %H:%M:%S'),
                "description": random.choice(['create', 'update', 'add'])
            })

    return managements

# Generate MovieManagement
def generate_movie_management(admins):
    managements = []
    unique_movie_ids = set()

    for movie_id in range(1, 21):  # Movie_id constrained to 1-20
        admin_id = random.choice(admins)['Admin_id']
        if movie_id not in unique_movie_ids:
            unique_movie_ids.add(movie_id)
            managements.append({
                "manage_id": len(managements) + 1,
                "admin_id": admin_id,
                "movie_id": movie_id,
                "manage_date": fake.date_this_year().strftime('%Y-%m-%d %H:%M:%S'),
                "description": random.choice(['create', 'update', 'add'])
            })

    return managements

# Generate VoucherManagement
def generate_voucher_management(admins, vouchers):
    managements = []
    unique_voucher_ids = set()

    for voucher in vouchers:
        admin_id = random.choice(admins)['Admin_id']
        if voucher['Voucher_id'] not in unique_voucher_ids:
            unique_voucher_ids.add(voucher['Voucher_id'])
            managements.append({
                "manage_id": len(managements) + 1,
                "admin_id": admin_id,
                "voucher_id": voucher['Voucher_id'],
                "manage_date": fake.date_this_year().strftime('%Y-%m-%d %H:%M:%S'),
                "description": random.choice(['create', 'update', 'add'])
            })

    return managements

# Integrate Movie and Genre constraints
# Movie IDs are 1 to 20, Genre IDs are 1 to 19
# Ensure compatibility for mapping purposes
# movie_ids = list(range(1, 21))
# genre_ids = list(range(1, 20))

# # Generate MovieGenre relationships
# def generate_movie_genres():
#     movie_genres = []
#     for movie_id in movie_ids:
#         assigned_genres = random.sample(genre_ids, random.randint(1, 3))  # Each movie gets 1-3 genres
#         for genre_id in assigned_genres:
#             movie_genres.append({
#                 "Movie_id": movie_id,
#                 "Genre_id": genre_id
#             })
#     return movie_genres

# Example Usage
users = generate_users(5000)
theaters = generate_theaters(30)
rooms = generate_rooms(theaters)
seat_types = generate_seat_types()
seats = generate_seats(rooms, seat_types)
showtimes = generate_showtimes(rooms)
vouchers = generate_vouchers(20)
bookings = generate_bookings(users, showtimes, vouchers, 10000)
admins = generate_admins(30)
booking_seat_showtime = generate_booking_seat_showtime(bookings, seats, showtimes)
redemptions = generate_redemptions(users, vouchers, 5000)
showtime_management = generate_showtime_management(admins, showtimes)
movie_management = generate_movie_management(admins)
voucher_management = generate_voucher_management(admins, vouchers)

# write_to_sql('users.sql', users, 'Users')
# write_to_sql('theaters.sql', theaters, 'Theaters')
# write_to_sql('rooms.sql', rooms, 'Room')
# write_to_sql('seat_types.sql', seat_types, 'SeatTypes')
# write_to_sql('seats.sql', seats, 'Seat')
# write_to_sql('showtimes.sql', showtimes, 'Showtimes')
# write_to_sql('vouchers.sql', vouchers, 'Vouchers')
# write_to_sql('bookings.sql', bookings, 'Bookings')
# write_to_sql('admins.sql', admins, 'Admins')
# write_to_sql('booking_seat_showtime.sql', booking_seat_showtime, 'BookingSeatShowtime')
# write_to_sql('redemptions.sql', redemptions, 'Redemptions')
write_to_sql('showtime_management.sql', showtime_management, 'ShowtimeManagement')
write_to_sql('movie_management.sql', movie_management, 'MovieManagement')
write_to_sql('voucher_management.sql', voucher_management, 'VoucherManagement')

print("SQL INSERT statements have been generated successfully.")

# # Generate data
# generate_all_data()