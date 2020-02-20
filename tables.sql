
--ЛЕКАРСТВА

--Лекарства
CREATE TABLE Medicine (
    id                 SERIAL PRIMARY KEY,    --id
    tradeName          TEXT UNIQUE NOT NULL,       --торговое название
    genericName        TEXT UNIQUE NOT NULL,       --международное непатентованное название
    dosageForm         TEXT NOT NULL,       --лекарственная форма
    manufacturer       TEXT NOT NULL,       --производитель
    activeSubstance    INTEGER REFERENCES ChemicalCompound,    --id вещества
    certificate        INT REFERENCES Certificate --id сертификата
);


--Действущее вещества ака химическое соединение
CREATE TABLE ChemicalCompound (
    id                  SERIAL PRIMARY KEY,    --id
    name                TEXT UNIQUE NOT NULL,       --название
    chemical_formula    TEXT UNIQUE NOT NULL       --химическая формула
);


--Сертификат
CREATE TABLE Certificate (
    id          SERIAL PRIMARY KEY,    --id
    number      INTEGER UNIQUE NOT NULL,    --номер сертификата
    validity    DATE NOT NULL,       --срок действия
    laboratory  INTEGER REFERENCES Laboratory  --id лаборатории
);

--Лаборатория
CREATE TABLE Laboratory (
    id              SERIAL PRIMARY KEY,    --id
    name            TEXT UNIQUE NOT NULL,       --название лаборатории
    headSurname     TEXT NOT NULL        --фамилия руководителя
);


--ОПТОВОЕ ХРАНЕНИЕ


--Дистрибьюторы
CREATE TABLE Distributor (
    id                  SERIAL PRIMARY KEY,    --id
    address             TEXT NOT NULL,       --адресс дистриббютера
    accountNumber       TEXT UNIQUE NOT NULL,       --номер банковского счета
    name                TEXT NOT NULL,       --имя контакного лица
    surname             TEXT NOT NULL,       --фамилия контакного лица
    phone               TEXT UNIQUE NOT NULL      --телефон контакного лица
);


--Поставка
CREATE TABLE Delivery (
    id                  SERIAL PRIMARY KEY,        --id
    distributor         INTEGER REFERENCES Distributor,        --id дистрибьютера
    storageNumber       INTEGER UNIQUE NOT NULL,        --номер склада
    storageAddress      TEXT NOT NULL,           --адрес склада
    arrivalTime         TIMESTAMP NOT NULL,      --время прибытия
    manName             TEXT UNIQUE NOT NULL         --фамилия кладовщика

);


--Таблица лекарств в поставке
CREATE TABLE DeliveryContent (
    deliveryId          INTEGER REFERENCES Delivery,    --id поставки
    medicineId          INTEGER REFERENCES Medicine,    --id лекарства
    bigNumber           INTEGER NOT NULL,    --количество перевозочных упаковок
    weight              INTEGER NOT NULL,    --вес одной перевозочной упаковки
    smallInBigNumber    INTEGER NOT NULL,    --количество отпукных упа- ковок в одной перевозочной
    cost                INTEGER NOT NULL  --закупочная стоимость одной отпускной упаковки
);



--РОЗНИЧНАЯ ПРОДАЖА

--Аптеки
CREATE TABLE Pharmacy (
    id          SERIAL PRIMARY KEY,    --id
    number      INTEGER UNIQUE NOT NULL,    --номер
    name        TEXT UNIQUE NOT NULL,       --название
    address     TEXT NOT NULL        --адресс
);


--Цены на лекарства в атеках
CREATE TABLE MedsInPharmas (
    pharmacyId      INTEGER REFERENCES Pharmacy,    --id аптеки
    medicineId      INTEGER REFERENCES Medicine``,    --id лекарства
    cost            INTEGER UNIQUE NOT NULL,    --цена лекарства в аптеке
    amount          INTEGER UNIQUE NOT NULL,    --количество лекарства в аптеке
);

--Автомобили
CREATE TABLE Car (
    id          SERIAL PRIMARY KEY,    --id
    number      TEXT UNIQUE NOT NULL,       --регистрационный номер
    tDate       DATE NOT NULL       --дата последнего техобслуживания
);


-- Задания автомобилей
CREATE TABLE Task (
    carId               INTEGER REFERENCES Car,    --id машины
    date                DATE UNIQUE NOT NULL,       --дата поездки
    storageAddress      TEXT UNIQUE NOT NULL,       --адрес склада
    number              INTEGER UNIQUE NOT NULL,    --количества лекарства в поставке
    medicineId          INTEGER REFERENCES Medicine,    --id лекарства
    pharmacyId          INTEGER REFERENCES Pharmacy     --id аптеки
);



-- Справочник. Если есть конечное множество значений.
-- Create Enum - просто перечсиление всех возможных значений
-- Create Table  с атрибутами id и value