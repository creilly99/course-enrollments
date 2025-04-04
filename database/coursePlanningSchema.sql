/*
   Copyright 2025 Christine F. Reilly

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
***
Schema for database that stores data about students' enrollments in courses.
A paper describing this database is presented at the CCSC-NE 2025 Conference
(https://ccscne.org/) and will be published in the Journal of Computing 
Sciences in Colleges.
*/


DROP SCHEMA IF EXISTS CoursePlanning;
CREATE SCHEMA CoursePlanning;
USE CoursePlanning;

/* 
* Each row represents one student
* id = college student id
* year = expected graduation year
*/
DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
    id      VARCHAR(10)    NOT NULL,
    first_name    VARCHAR(200),
    last_name    VARCHAR(200),
    email       VARCHAR(200),
    classyear    YEAR, 
    PRIMARY KEY(id),
    UNIQUE KEY(email)
);

/*
* Each row represents one course, as listed in the college catalog.
* id = automatically generated for internal database use
* num = college course number
* dept = abbreviation for department offering the course
* title = name of the course
*/
DROP TABLE IF EXISTS Course;
CREATE TABLE Course (
    id      INT AUTO_INCREMENT,
    num     INT     NOT NULL, /* course number */
    dept    VARCHAR(10) NOT NULL, /* department prefix */
    title   VARCHAR(100),
    PRIMARY KEY(id),
    UNIQUE KEY(dept, num)
);


/*
* Each row represents one term or semester. The id is the term code used by the
* Registrar's office. Season is the season of the semester (Fall, Spring, Summer1, Summer2).
* Year is the calendar year.
*/
DROP TABLE IF EXISTS Term;
CREATE TABLE Term (
    id      INT,
    season  VARCHAR(20),
    calendar_year    YEAR,
    PRIMARY KEY(id)
);

/*
* Each row represents one section (offering) of a course.
* crn = Course Record Number (college's unique identifier for each course section)
* course_id = reference to the automatically generated id in the Course table
* semester = semester (within a year) when the section was offered (e.g. Fall, Spring)
* offerYear = calendar year when the section was offered
*/
DROP TABLE IF EXISTS Section;
CREATE TABLE Section (
    crn     INT NOT NULL,
    course_id   INT,
    term_id     INT,
    ele200      BOOL,
    ele300      BOOL,
    PRIMARY KEY(crn, term_id),
    FOREIGN KEY(course_id) REFERENCES Course(id),
    FOREIGN KEY(term_id) REFERENCES Term(id)
);

/*
* Each row represents a student taking a section of a course.
*/
DROP TABLE IF EXISTS Takes;
CREATE TABLE Takes (
    student_id     VARCHAR(10) NOT NULL,
    crn     INT NOT NULL,
    term_id INT NOT NULL,
    PRIMARY KEY(crn, term_id, student_id),
    FOREIGN KEY(student_id) REFERENCES Student(id),
    FOREIGN KEY(crn, term_id) REFERENCES Section(crn, term_id),
    FOREIGN KEY(term_id) REFERENCES Term(id)
);

/*
* List of ids of studednts majoring in computer science.
* Decided to have this single attribute table to enable easily updating the list
* of students on a regular basis (such as every semester) because of the
* frequency of changes in this data. This table can be emptied and re-populated 
* with the current list of majors.
*/
DROP TABLE IF EXISTS CSMajor;
CREATE TABLE CSMajor (
    email      VARCHAR(200)    NOT NULL,
    PRIMARY KEY(email),
    FOREIGN KEY(email) REFERENCES Student(email)
);

/*
* List of ids of studednts minoring in computer science.
* Decided to have this single attribute table to enable easily updating the list
* of students on a regular basis (such as every semester) because of the
* frequency of changes in this data. This table can be emptied and re-populated 
* with the current list of minors.
*/
DROP TABLE IF EXISTS CSMinor;
CREATE TABLE CSMinor (
    email      VARCHAR(200)    NOT NULL,
    PRIMARY KEY(email),
    FOREIGN KEY(email) REFERENCES Student(email)
);

/* Grant read/write permissions to the user */
GRANT INSERT,DELETE,UPDATE,SELECT
on CoursePlanning.*
TO 'coursewriter'@'localhost';

/*
* The Computer Science courses we are interested in tracking.
* These are courses at Skidmore College.
*/
INSERT INTO Course (num, dept, title) VALUES
(106, "CS", "Introduction to Computer Science"),
(209, "CS", "Data Structures and Mathematical Foundations"),
(225, "CS", "Applied Data Science"),
(226, "CS", "Software Design"),
(230, "CS", "Programming Languages"),
(276, "CS", "Topics in Computer Science"),
(277, "CS", "Topics in Computer Science"),
(305, "CS", "Design and Analysis of Algorithms"),
(306, "CS", "Computability, Complexity, and Heuristics"),
(316, "CS", "Foundations of Machine Learning"),
(318, "CS", "Introduction to Computer Organization"),
(322, "CS", "Artificial Intelligence"),
(325, "CS", "Computer Graphics"),
(326, "CS", "Software Engineering"),
(327, "CS", "Computer Networks"),
(328, "CS", "Mobile Computing"),
(329, "CS", "Operating Systems"),
(331, "CS", "Computer Vision"),
(355, "CS", "Database Systems"),
(376, "CS", "Advanced Topics in Computer Science"),
(305, "IL", "Robotics"),
(351, "PY", "Robotics"),
(302, "MA", "Graph Theory"),
(305, "MA", "Introduction to Probability"),
(316, "MA", "Numerical Algorithms"),
(251, "MS", "Topics in Statistics");


