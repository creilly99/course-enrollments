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
Queries to run in the CoursePlanning database.
This file is not indented to run on its own, use these queries at
the command line or in an application program.
A paper describing the database and some of these queries is presented at the 
CCSC-NE 2025 Conference(https://ccscne.org/) and will be published in the Journal 
of Computing Sciences in Colleges.
*/

/* List the students in a specific class-year who have taken a specific course */
SELECT S.id, S.first_name, S.last_name
FROM Student S, Takes T, Section E, Course C
WHERE S.classyear = 2028
AND S.id = T.student_id 
AND T.crn = E.crn AND T.term_id = E.term_id
AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 106;

/* List the majors in a specific class-year */
SELECT S.id, S.first_name, S.last_name
FROM Student S, CSMajor M
WHERE S.email = M.email AND S.classyear = 2025
ORDER BY S.last_name,S.first_name;

/* List the majors in a specific class-year who have taken a specific course */
SELECT S.id, S.first_name, S.last_name
FROM Student S, CSMajor M, Takes T, Section E, Course C
WHERE S.email = M.email AND S.classyear = 2026
AND S.id = T.student_id 
AND T.crn = E.crn AND T.term_id = E.term_id
AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 331;

/* List the majors in a specific class-year who have NOT taken a specific course */
SELECT S2.id, S2.first_name, S2.last_name
FROM Student S2, CSMajor M2
WHERE S2.email = M2.email AND S2.classyear = 2026
AND S2.ID NOT IN (
    SELECT T.student_id
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 305
);

/* List the majors in a specific class-year who have taken exactly one 300-level elective */
/* First sub-query: students who have taken a 300-level elective */
/* Second sub-query: the same student has not taken a different 300-level elective */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S, CSMajor M
WHERE S.email = M.email AND S.classyear = 2025
AND S.id IN (
    SELECT T.student_id 
    FROM Takes T, Section E
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.ele300 AND NOT EXISTS (
        SELECT T2.student_id
        FROM Takes T2, Section E2
        WHERE T2.crn = E2.crn AND T2.term_id = E2.term_id
        AND T2.student_id = T.student_id
        AND E2.ele300 AND E2.crn <> E.crn AND E2.term_id <> E.term_id
    )
);

/* List the majors in a specific class year along with the count of electives they have taken */
SELECT S.id, S.first_name, S.last_name, 
    COALESCE(SE2.count200, 0) AS ele200, 
    COALESCE(SE3.count300, 0) AS ele300,
    (COALESCE(SE2.count200, 0) + COALESCE(SE3.count300, 0)) AS eleTotal
FROM (Student S INNER JOIN CSMajor M ON S.email = M.email)
    LEFT JOIN
    (SELECT T2.student_id, COUNT(T2.student_id) AS count200
    FROM Takes T2, Section E2
    WHERE T2.crn = E2.crn AND T2.term_id = E2.term_id
    AND E2.ele200
    GROUP BY T2.student_id
    ) AS SE2 ON S.id = SE2.student_id
    LEFT JOIN
    (SELECT T3.student_id, COUNT(T3.student_id) AS count300
    FROM Takes T3, Section E3
    WHERE T3.crn = E3.crn AND T3.term_id = E3.term_id
    AND E3.ele300
    GROUP BY T3.student_id
    ) AS SE3 ON S.id = SE3.student_id
WHERE S.classyear = 2026
ORDER BY ele300;



/* How many students in class of ? have taken both 209 and 226? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2027
AND S.id IN (
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 209)
    INTERSECT
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 226)
);

/* How many students in class of 2025 took both 209 and 226 by the end of sophomore year? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2025
AND S.id IN (
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 209 
    AND T.term_id NOT IN 
        (SELECT R.id FROM Term R 
        WHERE (R.calendar_year = 2025 AND R.season = 'Spring')
        OR (R.calendar_year = 2024 AND R.season = 'Fall') 
        OR (R.calendar_year = 2024 AND R.season = 'Spring') 
        OR (R.calendar_year = 2023 AND R.season = 'Fall')  
    ))
    INTERSECT
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 226
    AND T.term_id NOT IN 
        (SELECT R.id FROM Term R 
        WHERE (R.calendar_year = 2025 AND R.season = 'Spring')
        OR (R.calendar_year = 2024 AND R.season = 'Fall') 
        OR (R.calendar_year = 2024 AND R.season = 'Spring') 
        OR (R.calendar_year = 2023 AND R.season = 'Fall')  
    ))
);

/* How many students in class of 2026 took both 209 and 226 by the end of sophomore year? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2026
AND S.id IN (
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 209 
    AND T.term_id NOT IN 
        (SELECT R.id FROM Term R 
        WHERE (R.calendar_year = 2026 AND R.season = 'Spring')
        OR (R.calendar_year = 2025 AND R.season = 'Fall') 
        OR (R.calendar_year = 2025 AND R.season = 'Spring') 
        OR (R.calendar_year = 2024 AND R.season = 'Fall')  
    ))
    INTERSECT
    (SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 226
    AND T.term_id NOT IN 
        (SELECT R.id FROM Term R 
        WHERE (R.calendar_year = 2026 AND R.season = 'Spring')
        OR (R.calendar_year = 2025 AND R.season = 'Fall') 
        OR (R.calendar_year = 2025 AND R.season = 'Spring') 
        OR (R.calendar_year = 2024 AND R.season = 'Fall')  
    ))
);


/* How many students in class of 2025 took 106 by the fall of sophomore year (F22)? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2025
AND S.id IN (
    SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 106 
    AND T.term_id NOT IN (SELECT R.id FROM Term R WHERE 
        (R.calendar_year = 2024 AND R.season = 'Fall') 
        OR (R.calendar_year = 2024 AND R.season = 'Spring') 
        OR (R.calendar_year = 2023 AND R.season = 'Fall') 
        OR (R.calendar_year = 2023 AND R.season = 'Spring')
    )
);

/* How many students in class of 2026 took 106 by the fall of sophomore year (F23)? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2026
AND S.id IN (
    SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 106 
    AND T.term_id NOT IN (SELECT R.id FROM Term R WHERE 
        (R.calendar_year = 2024 AND R.season = 'Fall') 
        OR (R.calendar_year = 2024 AND R.season = 'Spring') 
    )
);

/* How many students in class of ? have taken at least one of: 230, 305, 318? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2027
AND S.id IN (
    SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' 
    AND (C.num = 230 OR C.num = 305 OR C.num = 318)
);

/* How many students in class of ? have taken at least one of: 209, 226? */
SELECT DISTINCT S.id, S.first_name, S.last_name
FROM Student S
WHERE S.classyear = 2028
AND S.id IN (
    SELECT T.student_id 
    FROM Takes T, Section E, Course C
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.course_id = C.id AND C.dept = 'CS' 
    AND (C.num = 209 OR C.num = 226)
);

/* Email addresses of students who took a CS class in a specific academic year,
    but have not graduated. */
SELECT DISTINCT S.email
FROM Student S
WHERE S.classyear > 2024
AND S.id IN (
    SELECT T.student_id
    FROM Takes T, Section E, Term R
    WHERE T.crn = E.crn AND T.term_id = E.term_id
    AND E.term_id = R.id
    AND R.id IN (
        SELECT R2.id FROM Term R2
        WHERE (R2.season = 'Fall' AND R2.calendar_year = 2023)
        OR (R2.season = 'Spring' AND R2.calendar_year = 2024)
    )
);

/* Class of 2025 might need coda in S25 */
/* How many students in class of 2025 have not taken at least one of: */
/* CS331, CS355, IL305 in Fall 2024? */
/* term_id for F24 is 202490 */
/* crns are: 93862, 93804, 93315 */
SELECT S2.id, S2.first_name, S2.last_name
FROM Student S2, CSMajor M2
WHERE S2.email = M2.email AND S2.classyear = 2025
AND S2.ID NOT IN (
    SELECT S.id
    FROM Student S, Takes T, Section E
    WHERE S.id = T.student_id 
    AND T.crn = E.crn AND T.term_id = E.term_id
    AND E.term_id = 202490
    AND E.crn IN (93862, 93804, 93315)
);

/* List the students in a specific class-year who took a specific course in specific semesters */
/* Such as took 106 in their first year */
SELECT S.id, S.first_name, S.last_name
FROM Student S, Takes T, Section E, Course C
WHERE S.classyear = 2025
AND S.id = T.student_id 
AND T.crn = E.crn AND T.term_id = E.term_id
AND E.course_id = C.id AND C.dept = 'CS' AND C.num = 106
AND T.term_id IN (SELECT R.id FROM Term R WHERE 
        (R.calendar_year = 2021 AND R.season = 'Fall') 
        OR (R.calendar_year = 2022 AND R.season = 'Spring') 
);