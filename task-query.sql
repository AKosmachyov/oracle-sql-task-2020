-- 1-11

-- 3

ALTER TABLE Doctors ADD UNIQUE (email);
ALTER TABLE Doctors ADD CHECK (phone LIKE '375%');
INSERT INTO Doctors (id,name,phone,email,title) VALUES (200,'Malachi Carter','2540436133','malesuada.ut.sem@suscipitest.net','диетолог');

-- 5
SELECT name, email FROM Patients WHERE id=32;
UPDATE Patients SET email='ivan_line23@yandex.com' WHERE id=32;
SELECT name, email FROM Patients WHERE id=32;

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

SELECT Hospital_Beds.id, Hospital_Beds.purchase_date, Hospital_Rooms.room_number
FROM Hospital_Beds
INNER JOIN Hospital_Rooms ON Hospital_Beds.room_id = Hospital_Rooms.id;

SELECT Visits.id || ' - ' || Diagnoses.name FROM Visits
LEFT JOIN Visit_Diagnoses
  ON Visits.id = Visit_Diagnoses.visit_id
LEFT JOIN Diagnoses
  ON Visit_Diagnoses.diagnosis_id = Diagnoses.id
WHERE Diagnoses.name IN ('Пневмонит', 'Грипп')

SELECT Patients.name || ' phone: ' || Patients.phone || ' date:' || Visits.visit_date FROM Patients
LEFT JOIN Visits
  ON Visits.patient_id = Patients.id
WHERE phone = ANY (SELECT phone FROM Doctors);

SELECT name FROM Doctors 
WHERE EXISTS (
   SELECT * FROM Visits
   WHERE Visits.patient_id = 13 AND Visits.doctor_id = Doctors.id
);

-- 12

-- enable print
SET SERVEROUTPUT ON

-- Создать процедуру, выводящую список палат с указанием количества коек и статуса палаты:
-- «пустая», если в палате никто не лежит;
-- «свободных мест нет», если палата заполнена;
-- «мужская», если в палате лежат только мужчины;
-- «женская», если в палате лежат только женщины;
-- «смешанная» во всех остальных случаях.

CREATE OR REPLACE PROCEDURE print_room_status( for_date IN DATE )
IS
  v_employeeRecord Visits%ROWTYPE;
BEGIN

  -- bed - bed type

  SELECT * INTO v_employeeRecord FROM Visits
  WHERE for_date >= TO_DATE(visit_date, 'DD/MM/YYYY') AND
  (for_date <= TO_DATE(discharge_date, 'DD/MM/YYYY') OR discharge_date IS NULL);
  

  dbms_output.put_line( for_date);

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line( SQLERRM );
END;
/
EXEC print_room_status(TO_DATE('11/06/2021', 'DD/MM/YYYY'));

CREATE OR REPLACE PROCEDURE print_room_status(for_date IN DATE)
    IS

    CURSOR asd IS SELECT
    CURSOR names_cur IS
        SELECT
        FROM student.student_details
        WHERE class_id = 'C';
    names_t names_cur%ROWTYPE;
    TYPE names_ntt IS TABLE OF names_t%TYPE; -- must use type
    l_names names_ntt;
BEGIN

    -- room - bed count
    SELECT Hospital_Rooms.room_number, Bed_qty.quantity
    FROM Hospital_Rooms
             LEFT JOIN
         (SELECT COUNT(id) AS quantity, room_id FROM Hospital_Beds GROUP BY room_id) Bed_qty
         ON Hospital_Rooms.id = Bed_qty.room_id
    ORDER BY room_number ASC;

    -- bed - gender
    SELECT ROOM_ID, visits.GENDER
    FROM HOSPITAL_BEDS
             LEFT JOIN
         (SELECT visits.BED_ID, P.GENDER
          FROM VISITS
                   LEFT JOIN PATIENTS P on VISITS.PATIENT_ID = P.ID
          WHERE TO_DATE('11/06/2021', 'DD/MM/YYYY') >= TO_DATE(visit_date, 'DD/MM/YYYY')
            AND (TO_DATE('11/06/2021', 'DD/MM/YYYY') <= TO_DATE(discharge_date, 'DD/MM/YYYY') OR
                 discharge_date IS NULL)) visits
         ON id = visits.BED_ID;


    dbms_output.put_line(for_date);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
/



  FOR v_employeeRecord IN v_employeeRecords LOOP
          /* Do something with v_employeeRecord */
  END LOOP;

  SELECT * INTO el FROM Doctors WHERE id = 1;

  dbms_output.put_line( el.name || ' ' || el.email || ' ' ||' ' );/
-- 

SELECT
    name.firstName,
    CASE
       WHEN Mood.mood IS NOT NULL
       THEN 'Unhappy'
       ELSE 'Happy'
    END Unhappy
FROM name
LEFT JOIN Mood ON
    mood.firstName = name.firstName AND
    mood.type IN ('Hungry','Tired','Fatigued','Bored') AND
    mood.value > 5

-- 13

-- Написать функцию, возвращающую строку «больше месяца», если со
-- времени поступления пациента прошло более одного месяца. В качестве
-- параметра использовать диагноз и заменять для такого пациента его лечащего
-- врача на того, у кого меньше всего больных.
CREATE OR REPLACE FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS IN VARCHAR2) RETURN VARCHAR2
IS
    visit_id number;
    doctor_id number;
    cursor visit_cursor is
        SELECT VISITS.ID
        INTO visit_id
        FROM Visits
                 LEFT JOIN VISIT_DIAGNOSES VD on VISITS.ID = VD.VISIT_ID
                 LEFT JOIN DIAGNOSES D on VD.DIAGNOSIS_ID = D.ID
        WHERE TO_DATE(discharge_date, 'DD/MM/YYYY') - TO_DATE(visit_date, 'DD/MM/YYYY') > 30
          AND D.NAME LIKE DIAGNOSIS FETCH FIRST 1 ROWS ONLY;
BEGIN
    open visit_cursor;
    fetch visit_cursor into visit_id;

    if visit_cursor%notfound then
        close visit_cursor;
        return 'all visit less than 30 days';
    end if;

    SELECT Doctors.id INTO doctor_id FROM Doctors
      LEFT JOIN VISITS
        ON VISITS.doctor_id = Doctors.id
    Group BY Doctors.id
    ORDER BY COUNT(VISITS.id) ASC
    FETCH FIRST 1 ROWS ONLY;

    if doctor_id IS NULL then
        close visit_cursor;
        return 'Doctor not found';
    end if;

    close visit_cursor;

    UPDATE Visits SET doctor_id=doctor_id WHERE id=visit_id;
    COMMIT;
    RETURN 'More than 30 days. Visit ' || visit_id || ' updated with doctor id: ' || doctor_id;
END;
/

declare
    retvar varchar2(255);
begin
    retvar := UPDATE_DOCTORS_FOR_VISIT('Пневмонит');
    dbms_output.Put_line(retvar);
end;
/

-- 14

CREATE OR REPLACE PROCEDURE print_room_status( text VARCHAR2 ) IS
BEGIN

  dbms_output.put_line('Procedure result: ' || text);

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line( SQLERRM );
END;
/

EXEC print_room_status('user text');

-- 15

CREATE OR REPLACE PACKAGE alex_pkg AS
	
	FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS IN VARCHAR2) RETURN VARCHAR2;

	PROCEDURE print_room_status( text VARCHAR2 );

  PROCEDURE print_room_status( for_date IN DATE );
	
END;
/
create or replace PACKAGE BODY alex_pkg AS

    FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS IN VARCHAR2) RETURN VARCHAR2 IS
        visit_id number;
        doctor_id number;
        cursor visit_cursor is
            SELECT VISITS.ID
            INTO visit_id
            FROM Visits
                LEFT JOIN VISIT_DIAGNOSES VD on VISITS.ID = VD.VISIT_ID
                LEFT JOIN DIAGNOSES D on VD.DIAGNOSIS_ID = D.ID
            WHERE TO_DATE(discharge_date, 'DD/MM/YYYY') - TO_DATE(visit_date, 'DD/MM/YYYY') > 30
                AND D.NAME LIKE DIAGNOSIS FETCH FIRST 1 ROWS ONLY;
    BEGIN
        open visit_cursor;
        fetch visit_cursor into visit_id;

        if visit_cursor%notfound then
            close visit_cursor;
            return 'all visit less than 30 days';
        end if;

        SELECT Doctors.id INTO doctor_id FROM Doctors
            LEFT JOIN VISITS ON VISITS.doctor_id = Doctors.id
        Group BY Doctors.id
        ORDER BY COUNT(VISITS.id) ASC
        FETCH FIRST 1 ROWS ONLY;

        if doctor_id IS NULL then
            close visit_cursor;
            return 'Doctor not found';
        end if;

        close visit_cursor;

        UPDATE Visits SET doctor_id=doctor_id WHERE id=visit_id;
        COMMIT;
        RETURN 'More than 30 days. Visit ' || visit_id || ' updated with doctor id: ' || doctor_id;
    END;

    PROCEDURE print_room_status( text VARCHAR2 ) IS
    BEGIN
     dbms_output.put_line('Procedure result: ' || text);
    END;

    PROCEDURE print_room_status(for_date IN DATE) IS
    BEGIN
         dbms_output.put_line( for_date );
    END;

END alex_pkg;
/


declare
    retvar varchar2(255);
begin
    retvar := alex_pkg.UPDATE_DOCTORS_FOR_VISIT('грипп');
    dbms_output.Put_line(retvar);
end;
/

-- 17

