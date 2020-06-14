-- 1-10

-- 3

ALTER TABLE Doctors ADD UNIQUE (email);
ALTER TABLE Doctors ADD CHECK (phone LIKE '375%');
INSERT INTO Doctors (id,name,phone,email,title) VALUES (200,'Malachi Carter','2540436133','malesuada.ut.sem@suscipitest.net','диетолог');

-- 5
SELECT name, email FROM Patients WHERE id=32;
UPDATE Patients SET email='ivan_line@yandex.com' WHERE id=32;

DELETE FROM Patients WHERE id=32;

-- 6
-- «Больные-пенсионеры» (условная выборка)

SELECT name, phone, birth_date FROM Patients
WHERE EXTRACT(YEAR FROM TO_DATE(birth_date, 'DD/MM/YYYY')) < 1955 AND phone LIKE '37544%';

-- 7
-- «Количество больных в каждой палате» (итоговый запрос)
SELECT room_number, COUNT(Visits.id) AS "Количество больных в палате" FROM Visits
INNER JOIN Hospital_Beds
    ON Visits.bed_id = Hospital_Beds.id
INNER JOIN Hospital_Rooms
    ON Hospital_Rooms.id = Hospital_Beds.room_id
GROUP BY room_number
ORDER BY "Количество больных в палате" DESC;

-- 8
-- «Палаты больных с заданной температурой» (параметрический запрос)

DEFINE targetTemperature = 37.9;

SELECT Hospital_Rooms.room_number FROM Visits
INNER JOIN Hospital_Beds
    ON Visits.bed_id = Hospital_Beds.id
INNER JOIN Hospital_Rooms
    ON Hospital_Rooms.id = Hospital_Beds.room_id
WHERE temperature = '&targetTemperature'
GROUP BY Hospital_Rooms.room_number;

-- 9
--«Общий список врачей с количеством обслуженных больных и больных с количеством дней
--пребывания» (запрос на объединение);

COLUMN "Doctors - patients count" HEADING 'Doctors + Patients list'
Select * FROM (
   SELECT 'dr. ' || Doctors.name || ' - ' || Visits_qty.quantity AS "Doctors - patients count" FROM Doctors
  LEFT JOIN 
    (SELECT COUNT(Visits.id) AS quantity, Visits.doctor_id FROM Visits GROUP BY Visits.doctor_id) Visits_qty
  ON Doctors.id = Visits_qty.doctor_id
UNION ALL
  SELECT 'p. ' || Patients.name || ' - ' || Sick_days.days AS "Patients - sick days" FROM Patients
  LEFT JOIN (
    SELECT patient_id,
    TO_DATE(discharge_date, 'DD/MM/YYYY') - TO_DATE(visit_date, 'DD/MM/YYYY') AS days
    FROM Visits) Sick_days
  ON Patients.id = Sick_days.patient_id
);

-- 10
-- «Количество заболевших по годам» (запрос по полю с типом дата).

SELECT count(id), EXTRACT(YEAR FROM TO_DATE(visit_date, 'DD/MM/YYYY')) as visit_year
FROM Visits
Group BY EXTRACT(YEAR FROM TO_DATE(visit_date, 'DD/MM/YYYY'));

-- 11

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