--Действущие вещества ака химическое соединение
DROP TABLE IF EXISTS ChemicalCompound CASCADE;
CREATE TABLE ChemicalCompound (
    id                  SERIAL PRIMARY KEY,        --id
    name                TEXT UNIQUE NOT NULL,      --название
    chemical_formula    TEXT UNIQUE NOT NULL       --химическая формула
);


--Лаборатория
DROP TABLE IF EXISTS Laboratory CASCADE;
CREATE TABLE Laboratory (
    id              SERIAL PRIMARY KEY,         --id
    name            TEXT UNIQUE NOT NULL,       --название лаборатории
    headSurname     TEXT NOT NULL               --фамилия руководителя
);


--Сертификат
DROP TABLE IF EXISTS Laboratory CASCADE;
CREATE TABLE Laboratory (
    id          SERIAL PRIMARY KEY,            --id
    number      INTEGER UNIQUE NOT NULL,       --номер сертификата
    validity    DATE NOT NULL,                 --срок действия
    laboratory  INTEGER REFERENCES Laboratory  --id лаборатории
);


--Лекарства
DROP TABLE IF EXISTS Medicine CASCADE;
CREATE TABLE Medicine (
    id                 SERIAL PRIMARY KEY,                     --id
    tradeName          TEXT UNIQUE NOT NULL,                   --торговое название
    genericName        TEXT UNIQUE NOT NULL,                   --международное непатентованное название
    dosageForm         TEXT NOT NULL,                          --лекарственная форма
    manufacturer       TEXT NOT NULL,                          --производитель
    activeSubstance    INTEGER REFERENCES ChemicalCompound,    --id вещества
    certificate        INT REFERENCES Certificate              --id сертификата
);






--Дистрибьюторы
DROP TABLE IF EXISTS Distributor CASCADE;
CREATE TABLE Distributor (
    id                  SERIAL PRIMARY KEY,                --id
    address             TEXT NOT NULL,                     --адресс дистриббютера
    accountNumber       VARCHAR(16) UNIQUE NOT NULL,       --номер банковского счета
    name                TEXT NOT NULL,                     --имя контакного лица
    surname             TEXT NOT NULL,                     --фамилия контакного лица
    phone               TEXT UNIQUE NOT NULL               --телефон контакного лица
);


--Поставка
DROP TABLE IF EXISTS Delivery CASCADE;
CREATE TABLE Delivery (
    id                  SERIAL PRIMARY KEY,                    --id
    distributor         INTEGER REFERENCES Distributor,        --id дистрибьютера
    storageNumber       INTEGER UNIQUE NOT NULL,               --номер склада
    storageAddress      TEXT NOT NULL,                         --адрес склада
    arrivalTime         TIMESTAMP,                             --время прибытия
    manName             TEXT                                   --фамилия кладовщика

);


--Таблица лекарств в поставке
DROP TABLE IF EXISTS DeliveryContent CASCADE;
CREATE TABLE DeliveryContent (
    deliveryId          INTEGER REFERENCES Delivery,                    --id поставки
    medicineId          INTEGER REFERENCES Medicine,                    --id лекарства
    bigNumber           INTEGER NOT NULL CHECK (bigNumber>0),           --количество перевозочных упаковок
    weight              INTEGER NOT NULL CHECK (weight>0),              --вес одной перевозочной упаковки
    smallInBigNumber    INTEGER NOT NULL CHECK (smallInBigNumber>0),    --количество отпукных упаковок в одной перевозочной
    cost                INTEGER NOT NULL CHECK (cost>0)                 --закупочная стоимость одной отпускной упаковки
);




--Аптеки
DROP TABLE IF EXISTS Pharmacy CASCADE;
CREATE TABLE Pharmacy (
    id          SERIAL PRIMARY KEY,         --id
    number      INTEGER UNIQUE NOT NULL,    --номер
    name        TEXT UNIQUE NOT NULL,       --название
    address     TEXT NOT NULL               --адресс
);


--Цены на лекарства в атеках
DROP TABLE IF EXISTS MedsInPharmas CASCADE;
CREATE TABLE MedsInPharmas (
    pharmacyId      INTEGER REFERENCES Pharmacy,              --id аптеки
    medicineId      INTEGER REFERENCES Medicine,              --id лекарства
    cost            INTEGER NOT NULL CHECK (cost > -1),       --цена лекарства в аптеке
    amount          INTEGER NOT NULL CHECK (amount > -1)      --количество лекарства в аптеке
);

--Автомобили
DROP TABLE IF EXISTS Car CASCADE;
CREATE TABLE Car (
    id          SERIAL PRIMARY KEY,             --id
    number      VARCHAR(10) UNIQUE NOT NULL,    --регистрационный номер
    tDate       DATE NOT NULL                   --дата последнего техобслуживания
);


-- Задания автомобилей
DROP TABLE IF EXISTS Task CASCADE;
CREATE TABLE Task (
    carId               INTEGER REFERENCES Car,                         --id машины
    date                DATE UNIQUE NOT NULL,                           --дата поездки
    storageAddress      TEXT UNIQUE NOT NULL,                           --адрес склада
    number              INTEGER UNIQUE NOT NULL CHECK (number > 0),     --количества лекарства в поставке
    medicineId          INTEGER REFERENCES Medicine,                    --id лекарства
    pharmacyId          INTEGER REFERENCES Pharmacy                     --id аптеки
);








-- Справочник. Если есть конечное множество значений.
-- Create Enum - просто перечсиление всех возможных значений
-- Create Table  с атрибутами id и value