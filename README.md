
# Enrollment Management System

## Developer Information

- **Developer:** Shairha May B. Ejares
- **Program:** Bachelor of Science in Information Technology
- **Institution:** Don Bosco Technical College – Cebu, Inc.
- **Academic Year:** 2026–2027

## Project Overview

The Enrollment Management System is a Flutter-based desktop application designed to manage student information, subjects, class schedules, enrollments, and academic grades.

The system uses Neon PostgreSQL as its cloud database, allowing information to be stored, retrieved, updated, and managed persistently.

The application follows the Model-View-ViewModel (MVVM) architecture to maintain an organized, modular, and maintainable code structure.

## Project Objectives

- Develop a database-integrated enrollment management application.
- Implement Create, Read, Update, and Delete (CRUD) operations.
- Manage student information and academic records efficiently.
- Prevent duplicate enrollments and overlapping class schedules.
- Monitor class capacity and available enrollment slots.
- Manage student grades and calculate average grades.
- Maintain database integrity through constraints and triggers.

## System Features

### 1. Student Management

- Add new students.
- View student information.
- Update student records.
- Delete eligible student records.
- Search and filter students.
- Mark students as favorites.
- Display student profile images.
- View individual academic records.

### 2. Subject Management

- Add new subjects.
- View available subjects.
- Update subject information.
- Delete eligible subjects.
- Manage subject codes, names, and units.

### 3. Schedule Management

- Create class schedules.
- View available schedules.
- Update schedule information.
- Delete eligible schedules.
- Manage class days, times, rooms, and capacity.
- Display enrolled students and available slots.

### 4. Enrollment Management

- Enroll students in available subjects.
- View enrollment records.
- Change class schedules.
- Drop enrolled subjects.
- Delete dropped enrollment records.
- Prevent duplicate subject enrollments.
- Detect overlapping class schedules.
- Prevent enrollment in full classes.

### 5. Grades Management

- Assign grades to actively enrolled students.
- View recorded grades.
- Update existing grades.
- Delete grade records.
- Validate grades from 0 to 100.
- Display Passed and Failed remarks.
- Calculate average grades.
- Filter grades by student.

### 6. Academic Records

- Display enrolled subjects within Student Details.
- View class schedules and room assignments.
- Display total enrolled subjects.
- Calculate total enrolled units.
- Display individual subject grades.
- Calculate the average of recorded grades.
- Identify subjects that have not yet been graded.

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Flutter | Desktop application development |
| Dart | Programming language |
| Neon PostgreSQL | Cloud database |
| PostgreSQL | Relational database management |
| Provider | State management |
| PostgreSQL Dart Package | Database connectivity |
| MVVM | Application architecture |
| Git | Version control |
| GitHub | Source code repository |
| Visual Studio Code | Development environment |

## Application Architecture

The system follows the MVVM architecture.

- **Model:** Represents database entities and application data.
- **View:** Displays the user interface.
- **ViewModel:** Manages application state and business logic.
- **Repository:** Handles database queries and CRUD operations.
- **Core:** Manages the PostgreSQL database connection.

## Project Structure

    lib/
    ├── core/
    │   └── db_connection.dart
    ├── models/
    ├── repositories/
    ├── viewmodels/
    ├── views/
    ├── connection_test.dart
    ├── student_test.dart
    └── main.dart

## Database Design

The system uses the following primary database tables:

| Table | Description |
|-------|-------------|
| programs | Stores academic programs |
| students | Stores student information |
| subjects | Stores subject information |
| schedules | Stores class schedules |
| enrollments | Stores student enrollment records |
| enrollment_grades | Stores grades associated with enrollments |


### Database Schema Script

The complete PostgreSQL database structure is provided in:

    database/schema.sql

The SQL script contains table definitions, relationships,
constraints, indexes, views, functions, and validation triggers.

The export contains database structure only. Existing student
records and confidential database credentials are not included.

To recreate the database, review and execute the SQL script
in a separate compatible PostgreSQL database.


### Database Views

- available_schedules
- student_grade_details
- student_academic_records

### Database Validation

The database implements primary keys, foreign keys, unique constraints, check constraints, indexes, and triggers to maintain data integrity.

Validation includes:

- Prevention of duplicate subject enrollments.
- Prevention of overlapping class schedules.
- Prevention of enrollment beyond class capacity.
- Validation of grades between 0 and 100.
- Validation of active enrollment before assigning grades.

## Installation and Setup

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Git
- Windows desktop development environment
- Visual Studio with Desktop Development with C++ workload
- Authorized Neon PostgreSQL database access

### Step 1: Clone the Repository

    git clone -b feature/final_project https://github.com/Shayy511/IT314AB_Ejares.git

### Step 2: Open the Project

    cd IT314AB_Ejares

### Step 3: Install Dependencies

    flutter pub get

### Step 4: Configure Database Credentials

Create a local db_config.json file in the project root.

Use the configuration variable names defined in lib/core/db_connection.dart and provide authorized PostgreSQL connection credentials.

The configuration file is excluded from GitHub for security purposes.

### Step 5: Run the Application

    flutter run -d windows --dart-define-from-file=db_config.json

## Application Testing

The following commands can be used to analyze and test the application:

    flutter analyze

    flutter test

The automated tests verify grade classification, including the passing-grade boundary.

Manual functional testing covers student, subject, schedule, enrollment, and grades management.

## Windows Release Build

To build the Windows desktop application:

    flutter build windows --release --dart-define-from-file=db_config.json

The compiled application can be found in:

    build/windows/x64/runner/Release/

The entire Release folder is required to run the compiled application.

## Grading System

| Grade Range | Remarks |
|-------------|---------|
| 75–100 | Passed |
| 0 to below 75 | Failed |
| Below 0 or above 100 | Invalid |

The displayed average grade is the arithmetic mean of recorded grades. Ungraded subjects are excluded from the average.

## Security and Privacy

Database credentials are stored in a local configuration file and excluded from version control.

The following files and folders are not intended for submission:

- db_config.json
- Environment configuration files
- Private keys
- Compiled application files
- Local database backups

The application is intended for controlled academic demonstration. Direct database connectivity from a desktop client is not recommended for production environments because compiled applications may contain extractable credentials.

## Conclusion

The Enrollment Management System demonstrates the integration of Flutter, PostgreSQL, database management, state management, and software architecture.

The system provides an organized approach to managing students, subjects, schedules, enrollments, and grades while implementing database validation and maintaining data integrity.

## Project Purpose

This project was developed for academic purposes as part of the Bachelor of Science in Information Technology program at Don Bosco Technical College – Cebu, Inc.
