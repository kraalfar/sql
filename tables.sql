
--ЛЕКАРСТВА

--Лекарства
CREATE TABLE Medicine (
    id                 INTEGER,    --id
    tradeName          TEXT,       --торговое название
    genericName        TEXT,       --еждународное непатен- тованное название
    dosageForm         TEXT,       --лекарственная форма
    manufacturer       TEXT,       --производитель
    activeSubstance    INTEGER,    --id вещества
    certificate        INTEGER     --id сертификата
);


--Действущее вещества ака химическое соединение
CREATE TABLE ChemicalCompound (
    id                  INTEGER,    --id
    name                TEXT,       --название
    chemical_formula    TEXT        --химическая формула
);


--Сертификат
CREATE TABLE Certificate (
    id          INTEGER,    --id
    number      INTEGER,    --номер сертификата
    validity    DATE,       --срок действия
    laboratory  INTEGER     --id лаборатории
);

--Лаборатория
CREATE TABLE Laboratory (
    id              INTEGER,    --id
    name            TEXT,       --название лаборатории
    headSurname     TEXT        --фамилия руководителя
);


--ОПТОВОЕ ХРАНЕНИЕ


--Дистрибьюторы
CREATE TABLE Distributor (
    id                  INTEGER,    --id
    address             TEXT,       --адресс дистриббютера
    accountNumber       INTEGER,    --номер банковского счета
    name                TEXT,       --имя контакного лица
    surname             TEXT,       --фамилия контакного лица
    phone               TEXT        --телефон контакного лица
);


--Поставка
CREATE TABLE Delivery (
    id                  INTEGER,        --id
    distributor         INTEGER,        --id дистрибьютера
    storageNumber       INTEGER,        --номер склада
    storageAddress      TEXT,           --адрес склада
    arrivalTime         TIMESTAMP,      --время прибытия
    manName             TEXT            --фамилия кладовщика

);


--Таблица лекарств в поставке
CREATE TABLE DeliveryContent (
    deliveryId          INTEGER,    --id поставки
    medicineId          INTEGER,    --id лекарства
    bigNumber           INTEGER,    --количество перевозочных упаковок
    weight              INTEGER,    --вес одной перевозочной упаковки
    smallInBigNumber    INTEGER,    --количество отпукных упа- ковок в одной перевозочной
    cost                INTEGER     --закупочная стоимость одной отпускной упаковки
);



--РОЗНИЧНАЯ ПРОДАЖА

CREATE TABLE Pharmacy (
    id          INTEGER,    --id
    number      INTEGER,    --номер
    name        TEXT,       --название
    address     TEXT        --адресс
);


--Цены на лекарства в атеках
CREATE TABLE MedsInPharmas (
    pharmacyId      INTEGER,    --id аптеки
    medicineId      INTEGER,    --id лекарства
    cost            INTEGER,    --цена лекарства в аптеке
    amount          INTEGER,    --количество лекарства в аптеке
);

--Автомобили
CREATE TABLE Car (
    id          INTEGER,    --id
    number      INTEGER,    --регистрационный номер
    tDate       DATE        --дата последнего техобслуживания
);


-- Задания автомобилей
CREATE TABLE Task (
    carId               INTEGER,    --id машины
    date                DATE,       --дата поездки
    storageAddress      TEXT,       --адрес склада
    number              INTEGER,    --количества лекарства в поставке
    medicineId          INTEGER,    --id лекарства
    pharmacyId          INTEGER     --id аптеки
);

