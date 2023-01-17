USE iths;
/* UNF Tabell */

DROP TABLE IF EXISTS UNF;
CREATE TABLE `UNF` (
    `Id` DECIMAL(38, 0) NOT NULL,
    `Name` VARCHAR(26) NOT NULL,
    `Grade` VARCHAR(11) NOT NULL,
    `Hobbies` VARCHAR(25),
    `City` VARCHAR(10) NOT NULL,
    `School` VARCHAR(30) NOT NULL,
    `HomePhone` VARCHAR(15),
    `JobPhone` VARCHAR(15),
    `MobilePhone1` VARCHAR(15),
    `MobilePhone2` VARCHAR(15)
)  ENGINE=INNODB;
LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv'
INTO TABLE UNF
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/* Student Tabell */

DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
    StudentId INT NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (StudentId)
)  ENGINE=INNODB;
INSERT INTO Student (StudentId, FirstName, LastName) 
SELECT DISTINCT Id, SUBSTRING_INDEX(Name, ' ', 1), SUBSTRING_INDEX(Name, ' ', -1) 
FROM UNF;


/* School Tabell */

DROP TABLE IF EXISTS School;
CREATE TABLE School AS SELECT DISTINCT 0 AS SchoolId, School AS Name, City FROM UNF;
SET @id = 0;
UPDATE School SET SchoolId = (SELECT @id := @id + 1);
ALTER TABLE School ADD PRIMARY KEY(SchoolId);


/* StudentSchool Tabell */

DROP TABLE IF EXISTS StudentSchool;
CREATE TABLE StudentSchool AS SELECT DISTINCT UNF.Id AS StudentId, School.SchoolId
FROM UNF INNER JOIN School ON UNF.School = School.Name;
ALTER TABLE StudentSchool MODIFY COLUMN StudentId INT;
ALTER TABLE StudentSchool MODIFY COLUMN SchoolId INT;
ALTER TABLE StudentSchool ADD PRIMARY KEY(StudentId, SchoolId);


/* Phone Tabell */

DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone (
    PhoneId INT NOT NULL AUTO_INCREMENT,
    StudentId INT NOT NULL,
    Type VARCHAR(32),
    Number VARCHAR(32) NOT NULL,
    CONSTRAINT PRIMARY KEY(PhoneId)
);
INSERT INTO Phone(StudentId, Type, Number)
SELECT ID As StudentId, "Home" AS Type, HomePhone as Number FROM UNF
WHERE HomePhone IS NOT NULL AND HomePhone != ''
UNION SELECT ID As StudentId, "Job" AS Type, JobPhone as Number FROM UNF
WHERE JobPhone IS NOT NULL AND JobPhone != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone1 as Number FROM UNF
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone2 as Number FROM UNF
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != ''
;

/* School Hobby */

DROP TABLE IF EXISTS Hobby;
CREATE TABLE Hobby(
HobbyId INT NOT NULL AUTO_INCREMENT,
Name VARCHAR (100) NOT NULL,
CONSTRAINT PRIMARY KEY(HobbyId)
)ENGINE = INNODB;
INSERT INTO Hobby(Name)
 SELECT  trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing'
UNION
SELECT trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing'
UNION
SELECT trim(substring_index(Hobbies, ",", -1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing';


/* School StudentHobby */

DROP TABLE IF EXISTS StudentHobby;
CREATE TABLE StudentHobby(
HobbyId INT NOT NULL ,
StudentId INT NOT NULL,
CONSTRAINT PRIMARY KEY(HobbyId, StudentId)
);
INSERT INTO StudentHobby(StudentId, HobbyId)
SELECT StudentIdHobbyName.Id, Hobby.HobbyId FROM
( SELECT Id, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
UNION
SELECT  Id, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) AS Hobby FROM UNF
UNION
SELECT Id, trim(substring_index(Hobbies, ",", -1)) AS Hobby FROM UNF) AS StudentIdHobbyName
JOIN Hobby ON Hobby.Name = StudentIdHobbyName.Hobby;


/* School Grade */

DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade AS SELECT 0 AS GradeId, Grade AS Name FROM (
SELECT DISTINCT CASE 
	WHEN Grade LIKE "%some" THEN "Awesome"
	WHEN Grade LIKE "%able" THEN "Admirable"
	WHEN Grade LIKE "%lent" THEN "Excellent"
	WHEN Grade LIKE "%lass" THEN "First class"
	WHEN Grade LIKE "%est" THEN "Best"
	END AS Grade FROM UNF
) AS Grade WHERE Grade IS NOT NULL;
SET @id = 0;
UPDATE Grade SET GradeId = (SELECT @id := @id + 1);
ALTER TABLE Grade ADD PRIMARY KEY(GradeId);
ALTER TABLE Student ADD COLUMN GradeId INT NOT NULL;
