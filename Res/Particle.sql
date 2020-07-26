--
-- Файл сгенерирован с помощью SQLiteStudio v3.2.1 в Вт мар 31 01:33:20 2020
--
-- Использованная кодировка текста: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Таблица: Chast
DROP TABLE IF EXISTS Chast;

CREATE TABLE Chast (
    ID   INTEGER      PRIMARY KEY AUTOINCREMENT
                      NOT NULL
                      UNIQUE,
    Name STRING (256) NOT NULL
                      COLLATE NOCASE
);


-- Таблица: Fails
DROP TABLE IF EXISTS Fails;

CREATE TABLE Fails (
    ID        INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_PART   INTEGER REFERENCES Parts (ID) ON DELETE CASCADE
                                            ON UPDATE CASCADE
                      NOT NULL,
    FailCount INTEGER DEFAULT (0),
    WorkHours INTEGER DEFAULT (0) 
);


-- Таблица: Missile
DROP TABLE IF EXISTS Missile;

CREATE TABLE Missile (
    ID       INTEGER      PRIMARY KEY AUTOINCREMENT
                          UNIQUE
                          NOT NULL,
    ID_CHAST INTEGER      REFERENCES Chast (ID) ON DELETE CASCADE
                                                ON UPDATE CASCADE
                          NOT NULL,
    Name     STRING (256) NOT NULL
                          COLLATE NOCASE
);


-- Таблица: Parts
DROP TABLE IF EXISTS Parts;

CREATE TABLE Parts (
    ID           INTEGER      PRIMARY KEY AUTOINCREMENT
                              NOT NULL,
    ID_MISSILE   INTEGER      REFERENCES Missile (ID) ON DELETE CASCADE
                                                      ON UPDATE CASCADE
                              NOT NULL,
    Producer     STRING (255) COLLATE NOCASE,
    Name         STRING (255) COLLATE NOCASE,
    AllowFails   INTEGER      NOT NULL
                              DEFAULT (0),
    WarrantyTime INTEGER      DEFAULT (0) 
);


-- Индекс: IDX_Fails_ID_PART
DROP INDEX IF EXISTS IDX_Fails_ID_PART;

CREATE INDEX IDX_Fails_ID_PART ON Fails (
    ID_PART ASC
);


-- Индекс: IDX_Missile_ID_Chast
DROP INDEX IF EXISTS IDX_Missile_ID_Chast;

CREATE INDEX IDX_Missile_ID_Chast ON Missile (
    ID_CHAST ASC
);


-- Индекс: IDX_PartList_ID_MISSILE
DROP INDEX IF EXISTS IDX_PartList_ID_MISSILE;

CREATE INDEX IDX_PartList_ID_MISSILE ON Parts (
    ID_MISSILE ASC
);


-- Представление: MissileList
DROP VIEW IF EXISTS MissileList;
CREATE VIEW MissileList AS
    SELECT m.ID AS ID,
           c.Name AS ChastName,
           m.Name AS Name
      FROM Missile AS m
           LEFT JOIN
           Chast c ON c.ID = m.ID_CHAST;


-- Представление: PartList
DROP VIEW IF EXISTS PartList;
CREATE VIEW PartList AS
    SELECT pl.ID AS ID,
           c.Name AS ChastName,
           m.Name AS MissileName,
           pl.Name,
           pl.Producer,
           pl.AllowFails,
           pl.WarrantyTime,
           coalesce(f.fc, 0) AS TotalFail,
           coalesce(f.wc, 0) AS TotalWork
      FROM Parts AS pl
           LEFT JOIN
           Missile m ON m.ID = pl.ID_MISSILE
           LEFT JOIN
           Chast c ON c.ID = m.ID_CHAST
           LEFT JOIN
           (
               SELECT ID_PART,
                      Sum(FailCount) AS fc,
                      Sum(WorkHours) AS wc
                 FROM Fails
                GROUP BY ID_PART
           )
           AS f ON f.ID_PART = pl.ID;


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
