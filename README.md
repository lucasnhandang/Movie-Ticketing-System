# Movie Ticketing System

A project for managing movie ticket bookings, developed as part of the **IT3290E - Database Lab** course during the 20241 semester at the Hanoi University of Science and Technology (HUST). This system facilitates user registrations, ticket bookings, and showtime management, demonstrating practical database design and implementation.

---

## Overview

The **Movie Ticketing System** is designed to simulate the operations of an online movie ticket booking platform. It includes features like real-time seat selection, showtime browsing, and an admin interface for managing schedules and movies. The project demonstrates key database management concepts such as normalization, indexing, and query optimization.

---

## Features

- **User Authentication**: Register, login, and manage user profiles.
- **Movie Listings**: Browse movies with showtimes, genres, and descriptions.
- **Seat Booking**: Real-time selection and booking of seats.
- **Payment Integration**: Simulated payment gateway for booking confirmation.
- **Admin Panel**: Add/update/delete movies, manage schedules, and view bookings.

---

## Technical Specifications

- **Database**: PostgreSQL for relational data management.
- **Tools Used**: 
  - ERD design with **drawio**.
  - RS design with **dbdiagram.io**.
  - SQL scripts for database schema creation and queries.

---

## Structure

```plaintext
Movie-Ticketing-Sys/
│
├── data/                         # Sample data for the system
│   ├── MTS-1m/
│   ├── MTS-1m-FIN/
│   └── MTS-15k/
│
├── setup/                        # Configuration and DB initialization
│   ├── db-schema-setup.sql       # Database schema setup
│   └── data_demo_setup.sql       # Demo data setup
│
├── sql/                          # Custom SQL scripts and logic
│   ├── privilege.sql             # Access permissions
│   ├── index.sql                 # Index definitions
│   ├── stored_procedure.sql      # Stored procedures
│   ├── Trigger.sql               # Database triggers
│   ├── view.sql                  # Views for queries/reports
│   └── functions.sql             # User-defined SQL functions
│
├── scripts/                      # Python scripts to generate data
│   └── gen.py
│
├── docs/                         # Documentation and diagrams
│   ├── MTS_ERD_FINAL.png         # Final Entity-Relationship Diagram
│   ├── MTS_RS_FINAL.png          # Final Relational Schema
│   └── MTS_Report.pdf            # Project report
│
├── .gitignore
└── README.md
```

## Contributing
If you want to contribute to this project and make it better with new ideas, your pull request is very welcomed! 
Here's how you can help:
1. Fork this repository.
2. Create a new branch (feature/your-feature-name).
3. Commit your changes and push to the branch.
4. Open a **Pull Request** with a description of your changes.

--- 
## Contributors

| **Name**           | **Student ID**               | **Role**    |
|---------------------|------------------------|-------------|
| Dang Van Nhan       | 20225990      | Team Leader |
| Nguyen Lan Nhi           | 20225991      | Member      |
| Duong Phuong Thao         | 20226001     | Member      |
