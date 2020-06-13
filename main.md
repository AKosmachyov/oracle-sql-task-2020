```sql
# First run login
sqlplus sys/GetStarted18c@//localhost:1521/XEPDB1 as sysdba
# create user
@.\user.sql
# login with new user

set NLS_LANG=.AL32UTF8
sqlplus alex/admin@//localhost:1521/XEPDB1
CONNECT alex/admin@//localhost:1521/XEPDB1

# create tables
@.\doctors.sql;
@.\patients.sql;
@.\hospital_rooms.sql;
@.\hospital_beds.sql;
@.\diagnoses.sql;
@.\visits.sql;
@.\visit_diagnoses.sql;

DROP TABLE Visit_Diagnoses;
DROP TABLE Visits;
DROP TABLE Patients;
DROP TABLE doctors;
DROP TABLE DIAGNOSES;
DROP TABLE HOSPITAL_BEDS;
DROP TABLE HOSPITAL_ROOMS;

SELECT table_name FROM user_tables ORDER BY table_name;
SELECT name FROM DIAGNOSES;

SELECT Visits.temperature  || '|' || Patients.name FROM Visits
INNER JOIN Patients
    ON Visits.patient_id = Patients.id
WHERE Visits.temperature > 39;

SELECT Visits.temperature, Patients.name, Diagnoses.name FROM Visit_Diagnoses
INNER JOIN Visits
    ON Visits.patient_id = Visit_Diagnoses.visit_id
INNER JOIN Diagnoses
    ON Visit_Diagnoses.diagnosis_id = Diagnoses.id
INNER JOIN Patients
    ON Visits.patient_id = Patients.id
WHERE Visits.temperature > 39.5;

```