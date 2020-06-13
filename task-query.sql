-- 1-2, 4
-- 9, 11 скипнул

-- 3

ALTER TABLE Doctors ADD UNIQUE (email);
ALTER TABLE Doctors ADD CHECK (phone LIKE '375%');
INSERT INTO Doctors (id,name,phone,email,title) VALUES (200,'Malachi Carter','2540436133','malesuada.ut.sem@suscipitest.net','диетолог');

-- 5
SELECT name, email FROM Patients WHERE id=32;
UPDATE Patients SET email='ivan_line@yandex.com' WHERE id=32;

DELETE FROM Patients WHERE id=32;

-- 6

SELECT name, phone, birth_date FROM Patients
WHERE EXTRACT(YEAR FROM TO_DATE(birth_date, 'DD/MM/YYYY')) < 1955 AND phone LIKE '37544%';

-- 7

SELECT room_id, COUNT(Visits.id) AS "Количество больных в палате" FROM Visits
INNER JOIN Hospital_Beds
    ON Visits.bed_id = Hospital_Beds.id
INNER JOIN Hospital_Rooms
    ON Hospital_Rooms.id = Hospital_Beds.room_id
GROUP BY room_id
ORDER BY "Количество больных в палате" DESC;

-- 8

Палаты больных с заданной температурой

SELECT room_id FROM Visits WHERE 
INNER JOIN Hospital_Beds
    ON Visits.bed_id = Hospital_Beds.id
INNER JOIN Hospital_Rooms
    ON Hospital_Rooms.id = Hospital_Beds.room_id
GROUP BY room_id
ORDER BY "Количество больных в палате" DESC;


-- 9

COLUMN table_name HEADING 'from list'
COLUMN table_name HEADING 'from list'
Select Z.id
FROM (
SELECT name, phone, 'patient' AS table_name FROM Patients
WHERE phone LIKE '37525%'
UNION ALL
SELECT name, phone, 'doctor' as table_name HEADING 'From' FROM Doctors
WHERE phone LIKE '37525%'
) as TOTAL
Group By Z.id 


SELECT City, Country FROM Patients
WHERE Country='Germany'
UNION ALL
SELECT City, Country FROM Doctors
WHERE Country='Germany'
ORDER BY City;

-- 10

SELECT temperature || ' | ' || Patients.name || ' | ' || visit_date, reason
FROM Visits
INNER JOIN Patients
    ON Visits.patient_id = Patients.id
WHERE EXTRACT(YEAR FROM TO_DATE(visit_date, 'DD/MM/YYYY HH24:MI:SS')) > 2018;

-- 12

-- enable print
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE print_doctors (
    doctor_id NUMBER 
)
IS
  el Doctors%ROWTYPE;
BEGIN
  SELECT * INTO el FROM Doctors WHERE id = doctor_id;

  dbms_output.put_line( el.name || ' ' || el.email || ' ' ||' ' );

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line( SQLERRM );
END;
/
EXEC print_doctors (1);