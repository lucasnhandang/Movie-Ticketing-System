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
def generate_users(n):
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
            "User_id": _ + 1,
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


# Theaters
def generate_theaters(n):
    # Generate a base list of 50 unique theater names
    base_theater_names = [
        "Galaxy Cinema", "CGV Cinemas", "Lotte Cinema", "BHD Star Cineplex",
        "MegaStar Cineplex", "Platinum Cineplex", "Cinestar", "StarLight Cinema",
        "Sunshine Cinema", "The Grand Cinema", "Moonlight Cinema", "FilmCity",
        "Silver Screen", "Golden Reel", "Infinity Cinema", "DreamCinema",
        "Vision Theater", "Eclipse Cinema", "Nova Cineplex", "Starlight Reel",
        "Aurora Screen", "Celestial Theater", "Nimbus Cinema", "Orion Cineplex",
        "Comet Theater", "Zenith Cinema", "Astro Cineplex", "Lunar Theater",
        "Nebula Cinema", "Spectrum Cineplex", "Mirage Cinema", "Cosmos Theater",
        "Fusion Reel", "Vortex Cinema", "Echo Theater", "Pulse Cineplex",
        "Flicker Cinema", "Radiance Theater", "Euphoria Screen", "Harmony Cinema",
        "Serenity Cineplex", "Tranquil Theater", "Bliss Cinema", "Majestic Reel",
        "Crown Theater", "Summit Cinema", "Pinnacle Cineplex", "Horizon Theater",
        "Voyager Cinema"
    ]

    theater_names = [f"{name} {suffix}" for name in base_theater_names for suffix in range(1, 50)]

    theaters = []
    for i in range(n):
        theaters.append({
            "Theater_id": i + 1,
            "Name": random.choice(theater_names),
            "Address": fake.address().replace("\n", " "),
            "City": fake.city(),  # Thành phố
            "Total_Rooms": 7
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
                "Capacity": random.choice([20, 50]),
                "Theater_id": theater['Theater_id']
            })
            room_id += 1
    return rooms


# Generate Seat Types
def generate_seat_types():
    return [
        {"Seattype_id": 1, "Name": "Standard", "Price": 100},
        {"Seattype_id": 2, "Name": "VIP", "Price": 200},
        {"Seattype_id": 3, "Name": "Couple", "Price": 300}
    ]


# Generate Seats
def generate_seats(rooms, seat_types):
    seats = []
    seat_id = 1
    for room in rooms:
        capacity = room['Capacity']
        rows = []
        for row in "ABCDEFGH":  # Using rows A-H for simplicity
            rows.append(row)

        row_count = len(rows)
        seats_per_row = capacity // row_count
        remaining_seats = capacity % row_count

        for i, row in enumerate(rows):
            seat_count = seats_per_row + (1 if i < remaining_seats else 0)
            for number in range(1, seat_count + 1):
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
def generate_showtimes(rooms, movies, n):
    showtimes = []
    for i in range(n):
        start_date = datetime.now() - timedelta(days=365)
        end_date = datetime.now()
        show_date = fake.date_between(start_date=start_date, end_date=end_date).strftime('%Y-%m-%d')

        room = random.choice(rooms)
        movie = random.choice(movies)

        start_hour = random.randint(8, 22)  # 8:00 to 22:00
        start_minute = random.randint(0, 59)
        start_time = timedelta(hours=start_hour, minutes=start_minute)  # TIME
        end_time = start_time + timedelta(minutes=movie["Duration"])

        start_time_str = (datetime.min + start_time).time().strftime('%H:%M:%S')
        end_time_str = (datetime.min + end_time).time().strftime('%H:%M:%S')

        showtimes.append({
            "Showtime_id": i + 1,
            "Start_Time": start_time_str,  # TIME
            "End_Time": end_time_str,  # TIME
            "Date": show_date,
            "Room_id": room['Room_id'],
            "Movie_id": movie['Movie_id']
        })
    return showtimes


# Generate Voucher
def generate_vouchers(n):
    vouchers = []
    for i in range(n):
        discount = random.randint(10, 100)
        expiry_date = datetime.now() + timedelta(days=random.randint(60, 365))

        vouchers.append({
            "Voucher_id": i + 1,
            "Description": fake.sentence(),
            "Discount_Percentage": discount,
            "Expiry_Date": expiry_date.strftime('%Y-%m-%d %H:%M:%S'),
            "Points_Required": discount
        })
    return vouchers


# Generate Bookings
def generate_bookings(users, showtimes, vouchers, n):
    bookings = []
    for i in range(n):
        booking_time = fake.date_time_this_year().strftime('%Y-%m-%d %H:%M:%S')

        bookings.append({
            "Booking_id": i + 1,
            "Time": booking_time,
            "Status": random.choice(['Pending', 'Confirmed', 'Cancelled']),
            "User_id": random.choice(users)['User_id'],
            "Showtime_id": random.choice(showtimes)['Showtime_id'],
            "Voucher_id": random.choice(vouchers)['Voucher_id'] if random.random() > 0.5 else None
        })
    return bookings


# Generate Admins
def generate_admins(n):
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
            "Admin_id": _ + 1,
            "Name": fake.name(),
            "Email": email,  # Ensure unique email
            "Password": fake.password(),
            "Phone": phone_number,  # Ensure phone number is max 15 digits
            "Dob": fake.date_of_birth().strftime('%Y-%m-%d')
        })
    return admins

# Generate BookingSeat
def generate_booking_seat(bookings, seats):
    booking_seat = []
    for booking in bookings:
        seat = random.choice(seats)
        booking_seat.append({
            "Booking_id": booking['Booking_id'],
            "Seat_id": seat['Seat_id'],
        })
    return booking_seat


# Generate Redemption
def generate_redemptions(users, vouchers, n):
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
                "description": random.choice(['delete', 'update', 'add'])
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
                "description": random.choice(['delete', 'update', 'add'])
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
                "description": random.choice(['delete', 'update', 'add'])
            })

    return managements

# Movies
def generate_movies(n):
    movies_by_language = {
        "Vietnamese": [
            "Em va Trinh", "Mat Biec", "Co Ba Sai Gon", "Hai Phuong", "Bo Gia",
            "Thang Nam Ruc Ro", "Hoa Vang Tren Co Xanh", "Chi Muoi Ba", "De Hoi Tinh", "Kieu",
            "Tam Cam Chuyen Chua Ke", "Ve Si Sai Gon", "Chi Pheo Ngoai Truyen", "Song Song", "Rung Xanh",
            "Bi Mat Tham Do", "Linh Duyen", "Ngoai Gio Lam", "Truy Sat", "So Do",
            "Tam Biet Thang Gieng", "Nhung Thang Nam De Danh", "Song Cung Lich Su", "Anh Trai Yeu Quai", "Loi Nho",
            "Sac Dep Ngan Can", "Tinh Yeu Va Tham Vong", "Tuoi Tre Bat Tan", "Lac Loi", "Doi Cua Ai",
            "Ngoc Vien Dong", "Toi Thay Hoa Vang Tren Co Xanh", "Canh Sat Hoang Gia", "Toi La Me Bao Mau", "Dua Con Xua",
            "Chuyen Tinh Lao Dai", "Nhung Chuyen Di Dinh Menh", "Ky An Duong Pho", "Hoa Binh", "Tinh Khuc Bach Dinh",
            "Mo Cua Tinh Yeu", "Vo Ba", "Ho Chi Minh Va Nguoi", "Con Gai Thoi Chien", "Mot Lan Thoang Qua", "Song Moi",
            "Dung Si Me O", "Long Lan", "Mai Mai Tinh Yeu", "Tro Ve", "Nguoi Tinh Mu"
        ],
        "English": [
            "The Shawshank Redemption", "Inception", "The Dark Knight", "Avatar", "Titanic",
            "Forrest Gump", "The Godfather", "Gladiator", "Pulp Fiction", "The Matrix",
            "Interstellar", "The Prestige", "Fight Club", "The Green Mile", "The Lion King",
            "Saving Private Ryan", "Schindlers List", "Jurassic Park", "The Avengers", "Iron Man",
            "The Wolf of Wall Street", "Black Panther", "Toy Story", "Up", "Coco",
            "Finding Nemo", "The Incredibles", "Frozen", "Shrek", "Aladdin",
            "Harry Potter", "The Lord of the Rings", "Star Wars", "The Social Network", "Joker",
            "Mad Max Fury Road", "The Silence of the Lambs", "Se7en", "The Usual Suspects", "Goodfellas",
            "Braveheart", "Inglourious Basterds", "Django Unchained", "Whiplash", "La La Land",
            "A Beautiful Mind", "The Pursuit of Happyness", "Slumdog Millionaire", "The Pianist", "The Big Short"
        ],
        "French": [
            "Amelie", "La Haine", "Intouchables", "Les Choristes", "Blue Is the Warmest Color",
            "The Artist", "A Prophet", "Delicatessen", "The Grand Illusion", "Breathless",
            "The 400 Blows", "Cleo from 5 to 7", "The Diving Bell and the Butterfly", "Hiroshima Mon Amour",
            "Portrait of a Lady on Fire", "La Vie en Rose", "The Chorus", "Cache", "Jules and Jim",
            "The Past", "L Atalante", "A Very Long Engagement", "The Class", "Tell No One",
            "The Intouchables", "A Prophet", "The Lovers on the Bridge", "Rust and Bone", "Love Me If You Dare",
            "Wild Reeds", "Read My Lips", "A Summer Tale", "The King and the Mockingbird", "Last Year at Marienbad",
            "Army of Shadows", "Jean de Florette", "Manon des Sources", "My Life as a Zucchini", "The Triplets of Belleville",
            "La Femme Nikita", "A Town Called Panic", "Goodbye First Love", "On My Way", "The Beat That My Heart Skipped",
            "The Beautiful Troublemaker", "The Lovers", "Under the Roofs of Paris", "Amour", "Rififi"
        ],
        "Spanish": [
            "Pans Labyrinth", "Roma", "The Sea Inside", "The Motorcycle Diaries", "Volver",
            "Talk to Her", "Biutiful", "The Secret in Their Eyes", "All About My Mother", "Open Your Eyes",
            "Pain and Glory", "Wild Tales", "The Platform", "Campeones", "The Invisible Guest",
            "Even the Rain", "Julieta", "Women on the Verge of a Nervous Breakdown", "Marshland",
            "Black Bread", "Truman", "Summer 1993", "The Last Suit", "The Flower of My Secret",
            "Broken Embraces", "Butterfly Tongue", "Lovers of the Arctic Circle", "Dark Blue Almost Black",
            "The Orphanage", "Cell 211", "The Endless Trench", "The Lighthouse of the Orcas", "Y Tu Mama Tambien",
            "Instructions Not Included", "Like Water for Chocolate", "Macario", "No One Writes to the Colonel",
            "Cronos", "Amores Perros", "The Devils Backbone", "The Crime of Father Amaro", "Burnt Money",
            "Nine Queens", "Son of the Bride", "The Headless Woman", "XXY", "Zama"
        ],
        "German": [
            "Das Boot", "Good Bye Lenin", "The Lives of Others", "Run Lola Run", "Downfall",
            "Nowhere in Africa", "The Baader Meinhof Complex", "Wings of Desire", "Toni Erdmann", "Victoria",
            "The White Ribbon", "Phoenix", "Barbara", "Oh Boy", "Transit",
            "Never Look Away", "The Counterfeiters", "Head On", "The Edukators", "Soul Kitchen",
            "The Wave", "We Are Young We Are Strong", "The Captain", "Alone in Berlin", "Rosenstrasse",
            "The Nasty Girl", "Stalingrad", "A Coffee in Berlin", "Summer Storm", "In the Fade",
            "Cloud Atlas", "Perfume", "The Experiment", "The Harmonists", "The Tin Drum",
            "Germany Year Zero", "Marlene", "The Marriage of Maria Braun",
            "The Blue Angel", "Nosferatu", "Metropolis", "Triumph of the Will", "Fitzcarraldo",
            "Aguirre the Wrath of God", "Stroszek", "Grizzly Man", "My Best Fiend"
        ],
        "Mandarin": [
            "Crouching Tiger Hidden Dragon", "Hero", "Raise the Red Lantern", "Farewell My Concubine", "Red Cliff",
            "House of Flying Daggers", "Infernal Affairs", "Kung Fu Hustle", "The Grandmaster", "A Touch of Sin",
            "To Live", "Ip Man", "Shaolin Soccer", "City of Life and Death", "Still Life",
            "A City Called Macau", "Crazy Rich Asians", "Ash Is Purest White", "Shadow", "Better Days",
            "Song of the Phoenix", "Chungking Express", "In the Mood for Love", "2046", "Spring in a Small Town",
            "Aftershock", "The Taking of Tiger Mountain", "Detective Chinatown", "Monster Hunt", "The Wandering Earth",
            "Legend of the Demon Cat", "Ne Zha", "Hi Mom", "Leap", "Shock Wave 2",
            "The Captain", "Operation Red Sea", "Wolf Warrior 2", "The Battle at Lake Changjin", "The Eight Hundred",
            "Devils on the Doorstep", "Not One Less", "Blind Shaft", "The Blue Kite", "Red Sorghum"
        ],
        "Hindi": [
            "3 Idiots", "Dangal", "Lagaan", "Sholay", "Kabhi Khushi Kabhie Gham",
            "Chak De India", "Baahubali", "PK", "Barfi", "Bajrangi Bhaijaan",
            "Padmaavat", "Sanju", "Andhadhun", "Tumbbad", "Zindagi Na Milegi Dobara",
            "Dilwale Dulhania Le Jayenge", "Swades", "Rang De Basanti", "Queen", "Gully Boy",
            "Stree", "Article 15", "Kaabil", "Raazi", "Drishyam",
            "Mimi", "The Lunchbox", "Piku", "Hindi Medium", "Newton",
            "Talvar", "Sonu Ke Titu Ki Sweety", "Ludo", "Chhichhore", "Kabir Singh",
            "Badhaai Ho", "Bhool Bhulaiyaa", "Race", "Dhoom", "Krrish",
            "My Name Is Khan", "Don", "War", "Ek Tha Tiger", "Sultan"
        ]
    }

    movies = []
    used_titles = set()

    for i in range(1, n + 1):
        while True:
            # Xác định ngôn ngữ
            language = random.choice(list(movies_by_language.keys()))
            # Lấy tiêu đề phim phù hợp và thêm hậu tố
            base_title = random.choice(movies_by_language[language]).replace("'", "").replace(".", "")
            title = f"{base_title} {random.randint(1, 10)}"
            if title not in used_titles:
                used_titles.add(title)
                break

        movies.append({
            "Movie_id": i,
            "Title": title,
            "Description": fake.text(max_nb_chars=100),
            "Language": language,
            "Rating": round(random.uniform(5.0, 9.9), 1),
            "Duration": random.randint(90, 180),  # Duration in minutes
            "Release_Date": fake.date_between(start_date='-5y', end_date='today').strftime('%Y-%m-%d')
        })

    return movies


# Genres
def generate_genres():
    genre_names = [
        "Action", "Comedy", "Drama", "Horror", "Sci-Fi",
        "Romance", "Thriller", "Documentary", "Fantasy", "Adventure"
    ]
    genres = [{"Genre_id": i + 1, "Name": genre_names[i]} for i in range(len(genre_names))]
    return genres

# MovieGenre
def generate_movie_genres(movies, genres):
    movie_genres = []
    for movie in movies:
        genre_count = random.randint(1, 3)  # Assign 1 to 3 genres per movie
        assigned_genres = random.sample(genres, genre_count)
        for genre in assigned_genres:
            movie_genres.append({
                "Movie_id": movie['Movie_id'],
                "Genre_id": genre['Genre_id']
            })
    return movie_genres


# Example Usage
users = generate_users(n=100000)
movies = generate_movies(n=1500)
genres = generate_genres()
movie_genres = generate_movie_genres(movies, genres)
theaters = generate_theaters(n=10000)
rooms = generate_rooms(theaters)
seat_types = generate_seat_types()
seats = generate_seats(rooms, seat_types)
showtimes = generate_showtimes(rooms, movies, n=1000000)
vouchers = generate_vouchers(n=10000)
bookings = generate_bookings(users, showtimes, vouchers, n=1000000)
admins = generate_admins(n=2000)
booking_seat = generate_booking_seat(bookings, seats)
redemptions = generate_redemptions(users, vouchers, n=1000000)
showtime_management = generate_showtime_management(admins, showtimes)
movie_management = generate_movie_management(admins)
voucher_management = generate_voucher_management(admins, vouchers)

# TO SQL
write_to_sql('1_users.sql', users, 'User')
write_to_sql('2_movies.sql', movies, 'Movie')
write_to_sql('3_genres.sql', genres, 'Genre')
write_to_sql('4_moviegenres.sql', movie_genres, 'MovieGenre')
write_to_sql('5_theaters.sql', theaters, 'Theater')
write_to_sql('6_rooms.sql', rooms, 'Room')
write_to_sql('7_seat_types.sql', seat_types, 'SeatType')
write_to_sql('8_seats.sql', seats, 'Seat')
write_to_sql('9_showtimes.sql', showtimes, 'Showtime')
write_to_sql('10_vouchers.sql', vouchers, 'Voucher')
write_to_sql('11_bookings.sql', bookings, 'Booking')
write_to_sql('12_admins.sql', admins, 'Admin')
write_to_sql('13_booking_seat.sql', booking_seat, 'BookingSeat')
write_to_sql('14_redemptions.sql', redemptions, 'Redemption')
write_to_sql('15_showtime_management.sql', showtime_management, 'ShowtimeManagement')
write_to_sql('16_movie_management.sql', movie_management, 'MovieManagement')
write_to_sql('17_voucher_management.sql', voucher_management, 'VoucherManagement')

print("SQL INSERT statements have been generated successfully.")

# # Generate data
# generate_all_data()