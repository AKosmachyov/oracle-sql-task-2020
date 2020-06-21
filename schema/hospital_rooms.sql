DROP TABLE Hospital_Rooms;

CREATE TABLE Hospital_Rooms (
  id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  floor NUMBER NOT NULL,
  room_number NUMBER NOT NULL
);

INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (1,1,1);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (2,1,2);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (3,1,3);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (4,1,5);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (5,2,21);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (6,2,22);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (7,2,23);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (8,2,25);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (9,2,26);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (10,3,34);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (11,3,35);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (12,3,36);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (13,3,37);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (14,3,38);
INSERT INTO Hospital_Rooms(id,floor,room_number) VALUES (15,3,34);