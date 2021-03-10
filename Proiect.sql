SET SERVEROUTPUT ON;
BEGIN
   FOR cur_rec IN (SELECT object_name, object_type
                   FROM user_objects
                   WHERE object_type IN
                             ('TABLE',
                              'VIEW',
                              'MATERIALIZED VIEW',
                              'PACKAGE',
                              'PROCEDURE',
                              'FUNCTION',
                              'SEQUENCE',
                              'SYNONYM',
                              'PACKAGE BODY'
                             ))
   LOOP
      BEGIN
         IF cur_rec.object_type = 'TABLE'
         THEN
            EXECUTE IMMEDIATE 'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '" CASCADE CONSTRAINTS';
         ELSE
            EXECUTE IMMEDIATE 'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '"';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line ('FAILED: DROP '
                                  || cur_rec.object_type
                                  || ' "'
                                  || cur_rec.object_name
                                  || '"'
                                 );
      END;
   END LOOP;
   FOR cur_rec IN (SELECT * 
                   FROM all_synonyms 
                   WHERE table_owner IN (SELECT USER FROM dual))
   LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || cur_rec.synonym_name;
      END;
   END LOOP;
END;
/

CREATE TABLE jobs(
    job_id VARCHAR(20) PRIMARY KEY,
    job_title VARCHAR(30) NOT NULL,
    min_salary INT NOT NULL,
    max_salary INT NOT NULL,
    UNIQUE(job_title),
    CHECK(min_salary<=max_salary)
);

CREATE TABLE employees(
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25),
    phone VARCHAR(20) NOT NULL,
    hire_date DATE DEFAULT SYSDATE NOT NULL,
    salary INT NOT NULL,
    commission_pct  NUMBER(2,2),
    manager_id REFERENCES employees(employee_id) ON DELETE SET NULL, --FK
    job_id VARCHAR(20) REFERENCES jobs(job_id) ON DELETE CASCADE, --FK
    UNIQUE(first_name,last_name),
    UNIQUE(phone),
    UNIQUE(email)
);

CREATE TABLE memberships(
    membership_id INT PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    price INT NOT NULL,
    CHECK(price>0),
    UNIQUE(name)
);

CREATE TABLE members(
    member_id INT PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25),
    phone VARCHAR(20),
    join_date DATE DEFAULT SYSDATE NOT NULL,
    membership_id INT REFERENCES memberships(membership_id) ON DELETE SET NULL, -- FK
    trainer_id INT REFERENCES employees(employee_id) ON DELETE SET NULL, -- FK
    UNIQUE(first_name,last_name),
    UNIQUE(phone),
    UNIQUE(email)
);

CREATE TABLE payments(
payment_id INT PRIMARY KEY,
value INT NOT NULL,
payment_date DATE DEFAULT SYSDATE NOT NULL,
member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
CHECK(value>0)
);

CREATE TABLE exercises(
exercise_id VARCHAR(30) PRIMARY KEY,
name VARCHAR(30) NOT NULL,
Description VARCHAR(300),
UNIQUE(name)
);
CREATE TABLE muscles(
muscle_id VARCHAR(30) PRIMARY KEY,
name VARCHAR(30) NOT NULL,
location VARCHAR(100)
);

CREATE TABLE equipment(
    equipment_id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE musclesWorked(
exercise_id VARCHAR(30) REFERENCES exercises(exercise_id) ON DELETE CASCADE,
muscle_id  VARCHAR(30) REFERENCES muscles(muscle_id) ON DELETE CASCADE,
CONSTRAINT musclesWorked_PK PRIMARY KEY (exercise_id, muscle_id)
);

CREATE TABLE requiredEquip(
equipment_id INT REFERENCES equipment(equipment_id) ON DELETE CASCADE,
exercise_id VARCHAR(30) REFERENCES exercises(exercise_id) ON DELETE CASCADE,
CONSTRAINT requiredEquip_PK PRIMARY KEY (equipment_id,exercise_id)
);

CREATE TABLE workouts(
workout_id INT PRIMARY KEY,
name VARCHAR(20) NOT NULL,
description VARCHAR(50),
UNIQUE(name)
);

CREATE TABLE workout_exercises(
exercise_id VARCHAR(30) REFERENCES exercises(exercise_id) ON DELETE CASCADE,
workout_id INT REFERENCES workouts(workout_id) ON DELETE CASCADE,
CONSTRAINT workout_exercises_PK PRIMARY KEY (exercise_id, workout_id)
);


CREATE TABLE classes(
class_id INT PRIMARY KEY,
name VARCHAR(30),
day_of_week VARCHAR(4),
start_time VARCHAR(5),
employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
workout_id INT REFERENCES workouts(workout_id) ON DELETE CASCADE
);

CREATE TABLE enrollments(
class_id INT REFERENCES classes(class_id) ON DELETE CASCADE,
member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
CONSTRAINT enrollments_PK PRIMARY KEY (class_id, member_id)
);

--DONE
SELECT * FROM equipment;
INSERT INTO equipment VALUES (1, 'Bench');
INSERT INTO equipment VALUES (2, 'Barbell');
INSERT INTO equipment VALUES (3, 'Squat Rack');
INSERT INTO equipment VALUES (4, 'Dumbbels');
INSERT INTO equipment VALUES (5, 'Leg Press Machine');
INSERT INTO equipment VALUES (6, 'Lat Pulldown Machine');
INSERT INTO equipment VALUES (7, 'Seated Row Machine');
INSERT INTO equipment VALUES (8, 'Shoulder Press Machine');
INSERT INTO equipment VALUES (9, 'Chest Press Machine');
INSERT INTO equipment VALUES (10, 'Lateral Shoulders Machine');
INSERT INTO equipment VALUES (11, 'Pulley System');
SELECT * FROM muscles;
INSERT INTO muscles VALUES (1,'Pectorals','Chest');
INSERT INTO muscles VALUES (2,'Quadriceps', 'Most of the frontal leg');
INSERT INTO muscles VALUES (3, 'Biceps', 'Front arm');
INSERT INTO muscles VALUES (4, 'Triceps', 'Opposite of biceps');
INSERT INTO muscles VALUES (5, 'Lateral Shoulders',NULL);
INSERT INTO muscles values (6, 'Abs', 'Between the pubis and the fifth, sixth, and seventh ribs.');
INSERT INTO muscles VALUES (7, 'Hamstrings', 'Back of your legs, right under the glutes');
INSERT INTO muscles VALUES (8, 'Glutes', 'Dorsal area');
INSERT INTO muscles VALUES (9, 'Trapezius','Upper back');
INSERT INTO muscles VALUES (10, 'Spinal Erectors', 'Lower back');
INSERT INTO muscles VALUES (11, 'Latissimus dorsi', 'The large V-shaped muscles that connect your arms to your vertebral column');
INSERT INTO muscles VALUES (12, 'Posterior Shoulders', NULL);
INSERT INTO muscles VALUES (13, 'Anterior Shoulders', NULL);

SELECT * FROM exercises;
INSERT INTO exercises VALUES ('LAT_PULLDOWN','Seated Lat Pulldown','While your arms are extended overhead, depress and retract your scapulae (pull shoulders back and down).');
INSERT INTO exercises VALUES ('TRI_PUSHDOWN', 'Triceps Pushdown', 'Pull the cable down until the bar touches your thighs and pause to squeeze your triceps at the bottom of the move.');
INSERT INTO exercises VALUES ('SKULL_CRSH', 'Triceps Skullcrushers', 'Hold the dumbbell with both hands above your chest, straight up, and with the dumbbell shaft in a vertical position.');
INSERT INTO exercises VALUES ('LAT_SH_RAISES','Lateral Shoulder Raises','Raise the weights to the sides and up to shoulder level, then lower them again');
INSERT INTO exercises VALUES ('CH_BAR_PRESS','Flat Barbell Chest Press', 'Grasp a barbell with an overhand grip just wider than shoulder-width apart.');
INSERT INTO exercises VALUES ('BIC_DB_CURL', 'Biceps Dumbell Curl', NULL);
INSERT INTO exercises VALUES ('BIC_BAR_CURL', 'Biceps Barbell Curl', 'Using an underhand grip, keep your chest up and your elbows tight to your sides, initiate the move by raising your hands slightly so you feel your biceps become engaged.');
INSERT INTO exercises VALUES ('LG_PRESS','Leg Press', 'Leg press using the leg press machine');
INSERT INTO exercises VALUES ('BAR_SQUAT','Barbell Squat', 'Trainees lowers their hips from a standing position and then stands back up.');
INSERT INTO exercises VALUES ('DEADLIFT','Deadlift','A loaded barbell or bar is lifted off the ground to the level of the hips, torso perpendicular to the floor, before being placed back on the ground.');
INSERT INTO exercises VALUES ('SH_DB_PRESS', 'Dumbbel Shoulder Press', 'Press the weights directly upwards until your arms are straight and the weights touch above your head.');
INSERT INTO exercises VALUES ('BAR_ROW','Bent Over Barbell Row', 'Lift the bar from the rack, bend forward at the hips, and keep the back straight with a slight bend in the knees.');
SELECT * FROM musclesworked;
INSERT INTO musclesWorked VALUES ('LAT_PULLDOWN',11);
INSERT INTO musclesWorked VALUES ('LAT_PULLDOWN',5);
INSERT INTO musclesWorked VALUES ('TRI_PUSHDOWN',4);
INSERT INTO musclesWorked VALUES ('SKULL_CRSH',4);
INSERT INTO musclesWorked VALUES ('LAT_SH_RAISES',5);
INSERT INTO musclesWorked VALUES ('LAT_SH_RAISES',13);
INSERT INTO musclesWorked VALUES ('CH_BAR_PRESS',1);
INSERT INTO musclesWorked VALUES ('CH_BAR_PRESS',4);
INSERT INTO musclesWorked VALUES ('CH_BAR_PRESS',5);
INSERT INTO musclesWorked VALUES ('CH_BAR_PRESS',13);
INSERT INTO musclesWorked VALUES ('SH_DB_PRESS',5);
INSERT INTO musclesWorked VALUES ('SH_DB_PRESS',13);
INSERT INTO musclesWorked VALUES ('BAR_SQUAT',2);
INSERT INTO musclesWorked VALUES ('BAR_SQUAT',7);
INSERT INTO musclesWorked VALUES ('BAR_SQUAT',8);
INSERT INTO musclesWorked VALUES ('BAR_SQUAT',6);
INSERT INTO musclesWorked VALUES ('LG_PRESS',2);
INSERT INTO musclesWorked VALUES ('LG_PRESS',7);
INSERT INTO musclesWorked VALUES ('LG_PRESS',8);
INSERT INTO musclesWorked VALUES ('DEADLIFT',2);
INSERT INTO musclesWorked VALUES ('DEADLIFT',10);
INSERT INTO musclesWorked VALUES ('DEADLIFT',9);
INSERT INTO musclesWorked VALUES ('BIC_DB_CURL',3);
INSERT INTO musclesWorked VALUES ('BIC_BAR_CURL',3);
INSERT INTO musclesWorked VALUES ('BAR_ROW',11);

SELECT * FROM requiredequip;
INSERT INTO requiredequip VALUES (6,'LAT_PULLDOWN');
INSERT INTO requiredequip VALUES (11,'TRI_PUSHDOWN');
INSERT INTO requiredequip VALUES (2,'SKULL_CRSH');
INSERT INTO requiredequip VALUES (1,'SKULL_CRSH');
INSERT INTO requiredequip VALUES (8,'LAT_SH_RAISES');
INSERT INTO requiredequip VALUES (1,'CH_BAR_PRESS');
INSERT INTO requiredequip VALUES (2,'CH_BAR_PRESS');
INSERT INTO requiredequip VALUES (4,'BIC_DB_CURL');
INSERT INTO requiredequip VALUES (2,'BIC_BAR_CURL');
INSERT INTO requiredequip VALUES (5,'LG_PRESS');
INSERT INTO requiredequip VALUES (3,'BAR_SQUAT');
INSERT INTO requiredequip VALUES (2,'BAR_SQUAT');
INSERT INTO requiredequip VALUES (2,'DEADLIFT');
INSERT INTO requiredequip VALUES (1,'SH_DB_PRESS');
INSERT INTO requiredequip VALUES (4,'SH_DB_PRESS');
INSERT INTO requiredequip VALUES (2,'BAR_ROW');

INSERT INTO workouts VALUES (1,'Push','A workout focused on pushing exercises');
INSERT INTO workouts VALUES (2,'Pull','A workout focused on pulling exercises');
INSERT INTO workouts VALUES (3,'Legs','Specially designed for massive legs');
INSERT INTO workouts VALUES (4,'Chest-Back-Triceps','Hit your whole upper body');
INSERT INTO workouts VALUES (5,'Shoulders-Biceps','Get boulder-like shoulders');

INSERT INTO workout_exercises VALUES ('CH_BAR_PRESS',1);
INSERT INTO workout_exercises VALUES ('SKULL_CRSH',1);
INSERT INTO workout_exercises VALUES ('SH_DB_PRESS',1);
INSERT INTO workout_exercises VALUES ('LAT_SH_RAISES',1);
INSERT INTO workout_exercises VALUES ('LAT_PULLDOWN',2);
INSERT INTO workout_exercises VALUES ('BIC_DB_CURL',2);
INSERT INTO workout_exercises VALUES ('BAR_ROW',2);
INSERT INTO workout_exercises VALUES ('BAR_SQUAT',3);
INSERT INTO workout_exercises VALUES ('LG_PRESS',3);
INSERT INTO workout_exercises VALUES ('DEADLIFT',3);

INSERT INTO memberships VALUES (1,'Bronze',150);
INSERT INTO memberships VALUES (2,'Silver',200);
INSERT INTO memberships VALUES (3,'Golden',230);

INSERT INTO jobs VALUES ('CLN_STF','Cleaning Staff',1400,2500);
INSERT INTO jobs VALUES ('P_TRN', 'Personal Trainer', 3000,9000);
INSERT INTO jobs VALUES ('SA_REP', 'Sales Representative', 1400,5000);
INSERT INTO jobs VALUES ('DESK','Front Desk Person',1400,3000);
INSERT INTO jobs VALUES ('ADM','Administration', 4000,8000);

INSERT INTO employees VALUES (1,'Dorothy','Haney','dorothy@gmail.com','973-722-4746','1-JUN-2010',7000,NULL,NULL,'ADM');
INSERT INTO employees VALUES (2,'Victor','Disney','victor23@gmail.com','563-449-0413','25-DEC-2012',1500,NULL,1,'CLN_STF');
INSERT INTO employees VALUES (3,'Lillian','Borton','lilly@gmail.com','518-454-9577','20-NOV-2011',7000,0.3,1,'P_TRN');
INSERT INTO employees VALUES (4,'Sally','Walden','sallynotsalty@yahoo.com','614-352-5238','20-JAN-2011',3500,NULL,3,'P_TRN');

INSERT INTO members VALUES (1, 'Lorraine','Wooldridge','LorWool@gmail.com','803-256-4224','22-NOV-2011',1,NULL);
INSERT INTO members VALUES (2, 'Shery','Sousa','Shery@gmail.com','832-664-1475','25-NOV-2011',3,3);
INSERT INTO members VALUES (3, 'Lisa','Barclay','lbarclay@gmail.com','214-277-8993','01-NOV-2011',1,4);
INSERT INTO members VALUES (4, 'Mindy','Coleman','MinColeman@yahoo.com','860-520-2878','03-FEB-2012',2,NULL);

INSERT INTO classes VALUES (1,'Killer Leg Workout','MON','19:30',3,3);
INSERT INTO classes VALUES (2,'Beach Ready Body','FRI','18:30',3,4);
INSERT INTO classes VALUES (3,'Boulder Shoulders','SUN','12:30',4,5);
INSERT INTO classes VALUES (4,'Beginner Pull Workout','MON','19:30',4,3);
INSERT INTO classes VALUES (5,'Advanced Push Workout','TUE','15:15',3,1);

INSERT INTO enrollments VALUES (1,1);
INSERT INTO enrollments VALUES (2,1);
INSERT INTO enrollments VALUES (5,1);
INSERT INTO enrollments VALUES (3,2);
INSERT INTO enrollments VALUES (5,2);
INSERT INTO enrollments VALUES (4,2);
INSERT INTO enrollments VALUES (3,3);
INSERT INTO enrollments VALUES (5,3);
INSERT INTO enrollments VALUES (4,3);
INSERT INTO enrollments VALUES (1,4);
INSERT INTO enrollments VALUES (2,4);
INSERT INTO enrollments VALUES (3,4);

INSERT INTO payments VALUES (1,150,'22-NOV-2011',1);
INSERT INTO payments VALUES (2,150,'22-DEC-2011',1);
INSERT INTO payments VALUES (3,150,'22-JAN-2012',1);
INSERT INTO payments VALUES (4,230,'25-NOV-2011',2);
INSERT INTO payments VALUES (5,150,'01-NOV-2011',3);
INSERT INTO payments VALUES (6,200,'03-FEB-2012',4);
--6
CREATE OR REPLACE TYPE employee_typ AS OBJECT (
    employee_id INT,
    first_name VARCHAR(25),
    last_name VARCHAR(25),
    email VARCHAR(25),
    phone VARCHAR(20),
    salary INT,
    commission_pct  NUMBER(2,2),
    MAP MEMBER FUNCTION getId RETURN NUMBER, -- Pt comparari
    MEMBER FUNCTION getSalary RETURN NUMBER,
    MEMBER PROCEDURE showData  (SELF IN OUT NOCOPY employee_typ) 
    -- NOCOPY e asemanator cu & din C++, ii spune compilatorului sa nu mai faca inca o copie obiectului. 
    -- SELF e asemanator cu this din C++ 
);
/

CREATE OR REPLACE TYPE BODY employee_typ AS
   MAP MEMBER FUNCTION getId RETURN NUMBER IS
   BEGIN
   RETURN employee_id;
   END;
   MEMBER FUNCTION getSalary RETURN NUMBER IS
   BEGIN
   RETURN salary*(1+commission_pct);
   END;
   MEMBER PROCEDURE showData  (SELF IN OUT NOCOPY employee_typ) IS
   BEGIN
   DBMS_OUTPUT.PUT_LINE('---- Employee ID: '|| employee_id || ' Full Name: ' || first_name || ' '||last_name || ' ----');
   DBMS_OUTPUT.PUT_LINE('Email: ' || email || ' Phone: ' || phone);
   DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
   END;
END;
/

CREATE OR REPLACE PROCEDURE showEmployees IS
  TYPE t_employee_typ IS TABLE OF employee_typ;
  t_emp t_employee_typ;
BEGIN
  SELECT employee_typ(employee_id, first_name, last_name, email, phone, salary, commission_pct)
  BULK COLLECT INTO t_emp FROM employees;
  FOR j IN t_emp.FIRST..t_emp.LAST LOOP
  t_emp(j).showData();
  END LOOP;
END showEmployees;
/

BEGIN
showEmployees();
END;
/
--7 Pt v_option = 1, se modifica salariul angajatilor cu salariul > threshold, altfel cu salariul < threshold.
CREATE OR REPLACE PROCEDURE modifySalary (v_option INTEGER, v_add INTEGER, v_sal INTEGER)
IS
TYPE empref IS REF CURSOR;
c_emp empref;
v_emp employees%ROWTYPE;
BEGIN
IF v_option = 1 THEN
  OPEN c_emp FOR
    'SELECT * FROM employees WHERE salary > :bind_var FOR UPDATE OF SALARY NOWAIT'
    USING v_sal;
  DBMS_OUTPUT.PUT_LINE('Adding ' || v_add || ' RON to employees whose monthly salary is BIGGER than '||v_sal || ' RON');
ELSIF v_option = 2 THEN
   OPEN c_emp FOR
    'SELECT * FROM employees WHERE salary < :bind_var FOR UPDATE OF SALARY WAIT 15'
    USING v_sal;
    DBMS_OUTPUT.PUT_LINE('Adding ' || v_add || ' RON to employees whose monthly salary is SMALLER than '||v_sal || ' RON');
ELSE 
 DBMS_OUTPUT.PUT_LINE('Invalid Option. Must be 1 for > or 2 for <');
END IF;
LOOP
FETCH c_emp INTO v_emp;
EXIT WHEN c_emp%NOTFOUND;
UPDATE employees
SET salary = salary+v_add
WHERE employee_id = v_emp.employee_id;
DBMS_OUTPUT.PUT_LINE('Updated ID: '||v_emp.employee_id|| ' Full Name: ' || v_emp.first_name || ' ' || v_emp.last_name || ' Salary: ' || v_emp.salary || ' -> ' || (v_emp.salary+v_add));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Processed '||c_emp%ROWCOUNT || ' lines.');
CLOSE c_emp;
END modifySalary;
/
BEGIN
modifysalary(2,-10,2);
END;
/

--8 O functie care sa returneze numarul de echipamente necesare pentru un workout dat ca parametru
CREATE OR REPLACE FUNCTION necessaryEquipment(v_name workouts.name%TYPE)
RETURN NUMBER IS
v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM workouts
  WHERE workouts.name = v_name;
  --Nu putem avea count > 1 din cauza constrangerii UNIQUE(name)
  IF v_count = 0 THEN
   raise NO_DATA_FOUND;
  END IF;
  SELECT COUNT(DISTINCT e.Name)
  INTO v_count
  FROM workouts wo, workout_exercises w, requiredequip r, equipment e, exercises ex 
  WHERE w.workout_id= wo.workout_id AND w.exercise_id = ex.exercise_id AND ex.exercise_id = r.exercise_id AND r.equipment_id=e.equipment_id AND UPPER(wo.name) = UPPER(v_name);
  RETURN v_count;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'There is no workout with this name');
END necessaryEquipment;
/

BEGIN
DBMS_OUTPUT.PUT_LINE(necessaryequipment('Pull'));
DBMS_OUTPUT.PUT_LINE(necessaryequipment('Pulls'));
END;
/

--9 O procedura care sa afiseze muschii lucrati de fiecare workout
CREATE OR REPLACE PROCEDURE p_musclesWorked
IS
v_count INTEGER;
TYPE refcursor IS REF CURSOR;
CURSOR c_work IS
  SELECT ws.name, CURSOR ( SELECT DISTINCT m.Name
FROM workouts wo, workout_exercises w, musclesWorked mw, muscles m, exercises ex 
WHERE w.workout_id= wo.workout_id AND w.exercise_id = ex.exercise_id AND ex.exercise_id = mw.exercise_id AND mw.muscle_id=m.muscle_id AND wo.name =ws.name) 
FROM workouts ws;
v_work_name workouts.name%TYPE;
v_cursor refcursor;
v_muscle_name muscles.name%TYPE;
BEGIN
  OPEN c_work;
  LOOP
    FETCH c_work INTO v_work_name, v_cursor;
    EXIT WHEN c_work%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE ('------ WORKOUT: '||v_work_name|| ' ------');
    LOOP
      FETCH v_cursor INTO v_muscle_name;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_cursor%ROWCOUNT || '. '||v_muscle_name);
    END LOOP;
  END LOOP;
  CLOSE c_work;
END p_musclesWorked;
/

BEGIN
p_musclesWorked;
END;
/

--10 Un trigger care limiteaza numarul de participanti intr-o clasa 
CREATE OR REPLACE TRIGGER limit_members_in_class
  FOR INSERT ON enrollments
  COMPOUND TRIGGER
  max_number constant number := 3;
  TYPE t_class_count IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
  class_count t_class_count;
  TYPE t_class_IDs IS TABLE OF enrollments.class_id%TYPE;
  c_class_IDs t_class_IDs;
  TYPE t_counts IS TABLE OF INTEGER;
  counts t_counts;
  
  BEFORE STATEMENT IS 
  BEGIN
    SELECT COUNT(*), class_id
    BULK COLLECT INTO counts, c_class_IDs
    FROM enrollments
    GROUP BY class_id;
  FOR i IN 1..c_class_IDs.COUNT() LOOP
    class_count(c_class_IDs(i)) := counts(i);
  END LOOP;
  END BEFORE STATEMENT;
  
  AFTER EACH ROW IS
  BEGIN
    IF class_count(:NEW.class_id) + 1 > max_number  THEN
      DBMS_OUTPUT.PUT_LINE('Too many members in Class ID: '||:NEW.class_id);
      DBMS_OUTPUT.PUT_LINE('Maximum number of allowed members: '|| max_number);
      RAISE_APPLICATION_ERROR(-20004, 'Too many members in the same class');
    END IF;
  END AFTER EACH ROW;
END limit_members_in_class;
/

INSERT INTO enrollments VALUES (3,1); -- Crapa
INSERT INTO enrollments VALUES (4,1); -- Merge
--11 Un trigger care sa verifice ca salariul la insert/update respecta limitele
CREATE OR REPLACE TRIGGER check_bounds
  BEFORE INSERT OR UPDATE OF salary ON employees
  FOR EACH ROW
DECLARE
  v_min INTEGER;
  v_max INTEGER;
BEGIN
  SELECT min_salary, max_salary 
  INTO v_min, v_max
  FROM employees e, jobs j 
  WHERE e.job_id=j.job_id AND j.job_id = :NEW.job_id;
  IF (:NEW.salary<v_min) OR (:NEW.salary > v_max) THEN
    raise_application_error(-20002, 'Salary is out of bounds for this job');
  END IF;
END;
/
COMMIT;
-- ADM are min 4000, max 8000
INSERT INTO employees VALUES (9,'Dorothy3','Haney3','dorothy33@gmail.com','973-722-47461','1-JUN-2010',10000,NULL,NULL,'ADM');
INSERT INTO employees VALUES (10,'Dorothy2','Haney2','dorothy32@gmail.com','973-722-47462','1-JUN-2010',5000,NULL,NULL,'ADM');
ROLLBACK;
--12
CREATE TABLE audit_log
( username VARCHAR2(30),
  command VARCHAR2(100),
  OBJECT_NAME VARCHAR2(50),
  time TIMESTAMP,
  ERROR VARCHAR2(100));
CREATE OR REPLACE TRIGGER audit_everything
  AFTER DDL OR SERVERERROR ON SCHEMA
  BEGIN
  IF SYS.SYSEVENT = 'SERVERERROR' THEN
   INSERT INTO audit_log VALUES (SYS.LOGIN_USER,'ERROR',SYS.DICTIONARY_OBJ_NAME,SYSDATE, DBMS_STANDARD.SERVER_ERROR(1)); --Top stack error
  ELSE
  INSERT INTO audit_log VALUES (SYS.LOGIN_USER,SYS.SYSEVENT,SYS.DICTIONARY_OBJ_NAME,SYSDATE, NULL); 
  END IF;
END audit_everything;
/
DROP TABLE testing;
CREATE TABLE testing(dummy INTEGER);
SELECT * FROM audit_log;
DROP TYPE employee_typ;
-- 13 Doar bagi toate subpunctele anterioare intr-un pachet
  CREATE OR REPLACE PACKAGE p13 AS
  PROCEDURE showEmployees;
  PROCEDURE modifySalary (v_option INTEGER, v_add INTEGER, v_sal INTEGER);
  FUNCTION necessaryEquipment(v_name workouts.name%TYPE) RETURN NUMBER;
  PROCEDURE p_musclesWorked;
  END p13;
  /
  
  CREATE OR REPLACE PACKAGE BODY p13 AS
    PROCEDURE showEmployees IS
      TYPE t_employee_typ IS TABLE OF employee_typ;
      t_emp t_employee_typ;
    BEGIN
      SELECT employee_typ(employee_id, first_name, last_name, email, phone, salary, commission_pct)
      BULK COLLECT INTO t_emp FROM employees;
      FOR j IN t_emp.FIRST..t_emp.LAST LOOP
      t_emp(j).showData();
      END LOOP;
    END showEmployees;
    
    PROCEDURE modifySalary (v_option INTEGER, v_add INTEGER, v_sal INTEGER)
IS
TYPE empref IS REF CURSOR;
c_emp empref;
v_emp employees%ROWTYPE;
BEGIN
IF v_option = 1 THEN
  OPEN c_emp FOR
    'SELECT * FROM employees WHERE salary > :bind_var FOR UPDATE OF SALARY NOWAIT'
    USING v_sal;
  DBMS_OUTPUT.PUT_LINE('Adding ' || v_add || ' RON to employees whose monthly salary is BIGGER than '||v_sal || ' RON');
ELSIF v_option = 2 THEN
   OPEN c_emp FOR
    'SELECT * FROM employees WHERE salary < :bind_var FOR UPDATE OF SALARY WAIT 15'
    USING v_sal;
    DBMS_OUTPUT.PUT_LINE('Adding ' || v_add || ' RON to employees whose monthly salary is SMALLER than '||v_sal || ' RON');
ELSE 
 DBMS_OUTPUT.PUT_LINE('Invalid Option. Must be 1 for > or 2 for <');
END IF;
LOOP
FETCH c_emp INTO v_emp;
EXIT WHEN c_emp%NOTFOUND;
UPDATE employees
SET salary = salary+v_add
WHERE employee_id = v_emp.employee_id;
DBMS_OUTPUT.PUT_LINE('Updated ID: '||v_emp.employee_id|| ' Full Name: ' || v_emp.first_name || ' ' || v_emp.last_name || ' Salary: ' || v_emp.salary || ' -> ' || (v_emp.salary+v_add));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Processed '||c_emp%ROWCOUNT || ' lines.');
CLOSE c_emp;
END modifySalary;

FUNCTION necessaryEquipment(v_name workouts.name%TYPE)
RETURN NUMBER IS
v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM workouts
  WHERE workouts.name = v_name;
  --Nu putem avea count > 1 din cauza constrangerii UNIQUE(name)
  IF v_count = 0 THEN
   raise NO_DATA_FOUND;
  END IF;
  SELECT COUNT(DISTINCT e.Name)
  INTO v_count
  FROM workouts wo, workout_exercises w, requiredequip r, equipment e, exercises ex 
  WHERE w.workout_id= wo.workout_id AND w.exercise_id = ex.exercise_id AND ex.exercise_id = r.exercise_id AND r.equipment_id=e.equipment_id AND UPPER(wo.name) = UPPER(v_name);
  RETURN v_count;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'There is no workout with this name');
END necessaryEquipment;

PROCEDURE p_musclesWorked
IS
v_count INTEGER;
TYPE refcursor IS REF CURSOR;
CURSOR c_work IS
  SELECT ws.name, CURSOR ( SELECT DISTINCT m.Name
FROM workouts wo, workout_exercises w, musclesWorked mw, muscles m, exercises ex 
WHERE w.workout_id= wo.workout_id AND w.exercise_id = ex.exercise_id AND ex.exercise_id = mw.exercise_id AND mw.muscle_id=m.muscle_id AND wo.name =ws.name) 
FROM workouts ws;
v_work_name workouts.name%TYPE;
v_cursor refcursor;
v_muscle_name muscles.name%TYPE;
BEGIN
  OPEN c_work;
  LOOP
    FETCH c_work INTO v_work_name, v_cursor;
    EXIT WHEN c_work%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE ('------ WORKOUT: '||v_work_name|| ' ------');
    LOOP
      FETCH v_cursor INTO v_muscle_name;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_cursor%ROWCOUNT || '. '||v_muscle_name);
    END LOOP;
  END LOOP;
  CLOSE c_work;
END p_musclesWorked;
  END p13;
  /

BEGIN
p13.p_musclesWorked();
END;
/
SELECT * FROM classes;
DESC classes
--14 Un pachet folosit la gestionarea membrilor
  -- functie care primeste nume, prenume antrenor si returneaza ID --hidden
  -- functie care primeste nume, prenume membru si returneaza ID --hidden
  -- functie care primeste o zi din saptamana, o ora de inceput si returneaza o lista de clase  -- hidden
  -- Nth most popular trainer RETURN TrainerTyp (Instructor,Nr) -- public
  -- procedura care modifica antrenorul unui membru -- public
  -- proceduri pt upgrade/downgrade la abonamentul unui membru si adauga automat plata --public 
  -- proceduri pt delete member (overloaded dupa id, nume+prenume) -- public
CREATE OR REPLACE PACKAGE member_manager AS
  TYPE class_list IS TABLE OF classes%ROWTYPE;
  FUNCTION getClasses (v_day VARCHAR2, v_hour VARCHAR2) RETURN class_list; 
  FUNCTION nthPopular (n NUMBER) RETURN employees.employee_id%TYPE;
  PROCEDURE changeTrainer(v_first members.first_name%TYPE, v_last members.last_name%TYPE, v_first_e employees.first_name%TYPE, v_last_e employees.last_name%TYPE);
  PROCEDURE upgradeMembership(v_first members.first_name%TYPE, v_last members.last_name%TYPE);
  PROCEDURE downgradeMembership(v_first members.first_name%TYPE, v_last members.last_name%TYPE);
  PROCEDURE deleteMember(v_first members.first_name%TYPE, v_last members.last_name%TYPE);
  PROCEDURE deleteMember(v_id members.member_id%TYPE);
END member_manager;
/
CREATE OR REPLACE PACKAGE BODY member_manager AS
  FUNCTION getEmployeeId (v_first employees.first_name%TYPE, v_last employees.last_name%TYPE) 
RETURN employees.employee_id%TYPE IS
v_ID employees.employee_id%TYPE;
BEGIN
  SELECT employee_id INTO v_ID FROM employees WHERE UPPER(first_name) = UPPER(v_first) AND UPPER(last_name) = UPPER(v_last);
  RETURN v_ID;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'There is no employee with this name');
  -- nu pot avea TOO MANY ROWS din cauza constrangerii de UNIQUE(first_name,last_name)
END getEmployeeId;

FUNCTION getMemberId (v_first members.first_name%TYPE, v_last members.last_name%TYPE) 
RETURN members.member_id%TYPE IS
v_ID  members.member_id%TYPE;
BEGIN
  SELECT member_id INTO v_ID FROM members WHERE UPPER(first_name) = UPPER(v_first) AND UPPER(last_name) = UPPER(v_last);
  RETURN v_ID;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'There is no employee with this name');
  -- nu pot avea TOO MANY ROWS din cauza constrangerii de UNIQUE(first_name,last_name)
END getMemberId;

FUNCTION getClasses (v_day VARCHAR2, v_hour VARCHAR2) RETURN class_list IS
t_classes class_list;
BEGIN
SELECT * BULK COLLECT INTO t_classes FROM classes WHERE UPPER(v_day) = day_of_week AND start_time>v_hour;
RETURN t_classes;

 EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002, 'There is no class in the requested day that starts after the given hour');
END getClasses;

FUNCTION nthPopular (n NUMBER) RETURN employees.employee_id%TYPE IS
 v_id employees.employee_id%TYPE;
 CURSOR desc_trainer IS
 SELECT trainer_id FROM members WHERE trainer_id IS NOT NULL GROUP BY trainer_id ORDER BY COUNT(*) DESC;
 BEGIN
 OPEN desc_trainer;
 FOR i IN 1..n LOOP
  FETCH desc_trainer INTO v_id;
 END LOOP;
 IF desc_trainer%ROWCOUNT < n THEN
  DBMS_OUTPUT.PUT_LINE('N is bigger than the number of trainers, returning id of the least popular trainer');
 END IF;
 CLOSE desc_trainer;
 RETURN v_id;
 END nthPopular;
 
  PROCEDURE changeTrainer(v_first members.first_name%TYPE, v_last members.last_name%TYPE, v_first_e employees.first_name%TYPE, v_last_e employees.last_name%TYPE) IS
  v_member_id members.member_id%TYPE := getmemberid(v_first,v_last);
  v_trainer_id employees.employee_id%TYPE := getemployeeid(v_first_e,v_last_e);
  BEGIN
  UPDATE members SET trainer_id = v_trainer_id WHERE member_id = v_member_id;
  END changeTrainer;
  
   PROCEDURE upgradeMembership(v_first members.first_name%TYPE, v_last members.last_name%TYPE) IS
    v_member_id members.member_id%TYPE := getmemberid(v_first,v_last);
     v_currentMembership members.membership_id%TYPE;
     v_maxMembership members.membership_id%TYPE;
    BEGIN
    SELECT MAX(membership_id) INTO v_maxMembership FROM memberships;
     SELECT membership_id INTO v_currentMembership FROM members WHERE member_id = v_member_id;
     IF v_currentmembership < v_maxMembership THEN
     UPDATE members SET membership_id = membership_id+1 WHERE member_id = v_member_id;
     ELSE
     RAISE_APPLICATION_ERROR(-20004,'Member already has the best available membership');
    END IF;
    END upgradeMembership;
    
     PROCEDURE downgradeMembership(v_first members.first_name%TYPE, v_last members.last_name%TYPE) IS
    v_member_id members.member_id%TYPE := getmemberid(v_first,v_last);
    v_currentMembership members.membership_id%TYPE;
    BEGIN
    SELECT membership_id INTO v_currentMembership FROM members WHERE member_id = v_member_id;
    IF v_currentMembership > 1 THEN
     UPDATE members SET membership_id = membership_id-1 WHERE member_id = v_member_id;
    ELSE
    RAISE_APPLICATION_ERROR(-20005,'Member already has the lowest available membership');
    END IF;
    END downgradeMembership;
    
     PROCEDURE deleteMember(v_first members.first_name%TYPE, v_last members.last_name%TYPE) IS
    v_member_id members.member_id%TYPE := getmemberid(v_first,v_last);
     BEGIN
      DELETE FROM members WHERE member_id = v_member_id;
     END deleteMember;
     
     PROCEDURE deleteMember(v_id members.member_id%TYPE) IS
     BEGIN
     DELETE FROM members WHERE member_id = v_id;
     END deleteMember;
END member_manager;
/

