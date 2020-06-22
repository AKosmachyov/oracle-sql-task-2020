-- 3-16 (task numbers)

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
RIGHT JOIN Visit_Diagnoses
  ON Visits.id = Visit_Diagnoses.visit_id
LEFT JOIN Diagnoses
  ON Visit_Diagnoses.diagnosis_id = Diagnoses.id
WHERE Diagnoses.name IN ('Пневмонит', 'Грипп');

SELECT Patients.name || ' phone: ' || Patients.phone || ' date:' || Visits.visit_date FROM Patients
RIGHT JOIN Visits
  ON Visits.patient_id = Patients.id
WHERE EXTRACT(YEAR FROM TO_DATE(BIRTH_DATE, 'DD/MM/YYYY')) > ANY 
(SELECT EXTRACT(YEAR FROM TO_DATE(CREATE_DATE, 'DD/MM/YYYY')) FROM DOCTORS);

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

CREATE OR REPLACE PROCEDURE print_room_status(for_date IN DATE) IS
    -- пустая, свободных мест нет, мужская, женская, смешанная
    room_type    VARCHAR2(100) := '';
    is_empty_bed BOOLEAN       := false;
BEGIN
    FOR room IN (SELECT Hospital_Rooms.id, Hospital_Rooms.room_number, Bed_qty.quantity
                 FROM Hospital_Rooms
                          LEFT JOIN
                      (SELECT COUNT(id) AS quantity, room_id FROM Hospital_Beds GROUP BY room_id) Bed_qty
                      ON Hospital_Rooms.id = Bed_qty.room_id
                 ORDER BY room_number ASC)
        LOOP
            is_empty_bed := false;
            room_type := 'пустая';
            FOR bed IN (SELECT visits.GENDER
                        FROM HOSPITAL_BEDS
                                 LEFT JOIN
                             (SELECT visits.BED_ID, P.GENDER
                              FROM VISITS
                                       LEFT JOIN PATIENTS P on VISITS.PATIENT_ID = P.ID
                              WHERE for_date >= TO_DATE(visit_date, 'DD/MM/YYYY')
                                AND (for_date <= TO_DATE(discharge_date, 'DD/MM/YYYY') OR
                                     discharge_date IS NULL)) visits
                             ON id = visits.BED_ID
                        WHERE ROOM_ID = room.id)
                LOOP
                    if bed.GENDER is NULL THEN
                        is_empty_bed := true;
                        CONTINUE;
                    end if;
                    if bed.GENDER = 'm' AND room_type = 'пустая' THEN
                        room_type := 'мужская';
                        CONTINUE;
                    end if;
                    if bed.GENDER = 'w' AND room_type = 'пустая' THEN
                        room_type := 'мужская';
                        CONTINUE;
                    end if;
                    room_type := 'смешанная';
                end loop;
            if is_empty_bed = false THEN
                room_type := 'cвободных мест нет';
            end if;
            dbms_output.put_line('#' || room.ROOM_NUMBER || ' - ' || room.quantity || 'qt. ' || room_type);
        end loop;
EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
/
EXEC print_room_status(TO_DATE('11/06/2021', 'DD/MM/YYYY'));

-- 13

-- Написать функцию, возвращающую строку «больше месяца», если со
-- времени поступления пациента прошло более одного месяца. В качестве
-- параметра использовать диагноз и заменять для такого пациента его лечащего
-- врача на того, у кого меньше всего больных.
CREATE OR REPLACE FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS_NAME IN VARCHAR2) RETURN VARCHAR2
    IS
    visit_id     number;
    doctor_id    number;
    diagnosis_id number;
    cursor visit_cursor is
        SELECT VISITS.ID
        INTO visit_id
        FROM Visits
                 LEFT JOIN VISIT_DIAGNOSES VD on VISITS.ID = VD.VISIT_ID
        WHERE TO_DATE(discharge_date, 'DD/MM/YYYY') - TO_DATE(visit_date, 'DD/MM/YYYY') > 30
          AND diagnosis_id = diagnosis_id FETCH FIRST 1 ROWS ONLY;

    cursor diagnosis_cursor is
        SELECT ID
        FROM DIAGNOSES
        WHERE NAME LIKE DIAGNOSIS_NAME;

    no_diagnosis_founded EXCEPTION;
BEGIN
    open diagnosis_cursor;
    fetch diagnosis_cursor into diagnosis_id;
    close diagnosis_cursor;

    if diagnosis_id is null then
        RAISE no_diagnosis_founded;
    end if;

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

    UPDATE Visits SET doctor_id=doctor_id WHERE id = visit_id;
    COMMIT;
    RETURN 'More than 30 days. Visit ' || visit_id || ' updated with doctor id: ' || doctor_id;

EXCEPTION
    WHEN no_diagnosis_founded THEN
        return 'Диагноз с таким название не найден!';
    WHEN OTHERS THEN
        return SQLERRM;
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
	
	FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS_NAME IN VARCHAR2) RETURN VARCHAR2;

	PROCEDURE print_room_status( text VARCHAR2 );

    PROCEDURE print_room_status( for_date IN DATE );
	
END;
/
create or replace PACKAGE BODY alex_pkg AS
    FUNCTION UPDATE_DOCTORS_FOR_VISIT(DIAGNOSIS_NAME IN VARCHAR2) RETURN VARCHAR2
        IS
        visit_id     number;
        doctor_id    number;
        diagnosis_id number;
        cursor visit_cursor is
            SELECT VISITS.ID
            INTO visit_id
            FROM Visits
                    LEFT JOIN VISIT_DIAGNOSES VD on VISITS.ID = VD.VISIT_ID
            WHERE TO_DATE(discharge_date, 'DD/MM/YYYY') - TO_DATE(visit_date, 'DD/MM/YYYY') > 30
            AND diagnosis_id = diagnosis_id FETCH FIRST 1 ROWS ONLY;

        cursor diagnosis_cursor is
            SELECT ID
            FROM DIAGNOSES
            WHERE NAME LIKE DIAGNOSIS_NAME;

        no_diagnosis_founded EXCEPTION;
    BEGIN
        open diagnosis_cursor;
        fetch diagnosis_cursor into diagnosis_id;
        close diagnosis_cursor;

        if diagnosis_id is null then
            RAISE no_diagnosis_founded;
        end if;

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

        UPDATE Visits SET doctor_id=doctor_id WHERE id = visit_id;
        COMMIT;
        RETURN 'More than 30 days. Visit ' || visit_id || ' updated with doctor id: ' || doctor_id;

    EXCEPTION
        WHEN no_diagnosis_founded THEN
            return 'Диагноз с таким название не найден!';
        WHEN OTHERS THEN
            return SQLERRM;
    END;

    PROCEDURE print_room_status(text VARCHAR2) IS
    BEGIN
        dbms_output.put_line('Procedure result: ' || text);
    END;

    PROCEDURE print_room_status(for_date IN DATE) IS
        -- пустая, свободных мест нет, мужская, женская, смешанная
        room_type    VARCHAR2(100) := '';
        is_empty_bed BOOLEAN       := false;
    BEGIN
        FOR room IN (SELECT Hospital_Rooms.id, Hospital_Rooms.room_number, Bed_qty.quantity
                     FROM Hospital_Rooms
                              LEFT JOIN
                          (SELECT COUNT(id) AS quantity, room_id FROM Hospital_Beds GROUP BY room_id) Bed_qty
                          ON Hospital_Rooms.id = Bed_qty.room_id
                     ORDER BY room_number ASC)
            LOOP
                is_empty_bed := false;
                room_type := 'пустая';
                FOR bed IN (SELECT visits.GENDER
                            FROM HOSPITAL_BEDS
                                     LEFT JOIN
                                 (SELECT visits.BED_ID, P.GENDER
                                  FROM VISITS
                                           LEFT JOIN PATIENTS P on VISITS.PATIENT_ID = P.ID
                                  WHERE for_date >= TO_DATE(visit_date, 'DD/MM/YYYY')
                                    AND (for_date <= TO_DATE(discharge_date, 'DD/MM/YYYY') OR
                                         discharge_date IS NULL)) visits
                                 ON id = visits.BED_ID
                            WHERE ROOM_ID = room.id)
                    LOOP
                        if bed.GENDER is NULL THEN
                            is_empty_bed := true;
                            CONTINUE;
                        end if;
                        if bed.GENDER = 'm' AND room_type = 'пустая' THEN
                            room_type := 'мужская';
                            CONTINUE;
                        end if;
                        if bed.GENDER = 'w' AND room_type = 'пустая' THEN
                            room_type := 'мужская';
                            CONTINUE;
                        end if;
                        room_type := 'смешанная';
                    end loop;
                if is_empty_bed = false THEN
                    room_type := 'cвободных мест нет';
                end if;
                dbms_output.put_line('#' || room.ROOM_NUMBER || ' - ' || room.quantity || 'qt. ' || room_type);
            end loop;
        EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
    END;

END alex_pkg;
/

--16 

declare
    retvar varchar2(255);
begin
    retvar := alex_pkg.UPDATE_DOCTORS_FOR_VISIT('Грипп');
    dbms_output.Put_line(retvar);
    alex_pkg.print_room_status('Some user text');
    dbms_output.Put_line('');
    alex_pkg.print_room_status(TO_DATE('05/06/2021', 'DD/MM/YYYY'));
    dbms_output.Put_line('');
    alex_pkg.print_room_status(TO_DATE('05/02/2021', 'DD/MM/YYYY'));
    dbms_output.Put_line('');
    dbms_output.Put_line(alex_pkg.UPDATE_DOCTORS_FOR_VISIT('qwe'));
end;
/
