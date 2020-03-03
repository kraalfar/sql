CREATE OR REPLACE FUNCTION GenerateData(factor INT) RETURNS VOID AS $$
BEGIN

-- добавляем лекарственные формы
INSERT INTO DosageForm(type)
SELECT unnest(ARRAY['Таблека', 'Капсула', 'Ампула']);


-- добавляем производителей
INSERT INTO Manufacturer(info)
SELECT unnest(ARRAY['Европе', 'Китай', 'Вася со двора']);

-- добавляем химические формулы
INSERT INTO ChemicalCompound(name, chemical_formula)
VALUES  ('спирт', 'C2H5(OH)'),
        ('вода', 'H2O'),
        ('фтор', 'F');


-- добавляем лаборатории
INSERT INTO Laboratory(name, headSurname)
VALUES  ('Первая', 'Енгалыч'),
        ('Вторая', 'Вирко'),
        ('Третья', 'Горбенко'),
        ('Четвертая', 'Багиров');


-- добавляем сертификаты
WITH Numbers as(
    SELECT unnest(ARRAY[42, 12, 64]) as number
)
INSERT INTO Certificate(number, validity, laboratory)
SELECT number, ('2020-01-01'::DATE + random()*365*5 * INTERVAL '1 day')::DATE,
    (0.5 + random() * (SELECT COUNT(*) FROM Laboratory))::int FROM Numbers;


-- добавляем лекарства
WITH Names as(
    SELECT unnest(ARRAY['Нурофен', 'Кагоцел', 'Фурацилин', 'Анальгин', 'Мирамистин', 'Плацебо']) as tName,
           unnest(ARRAY['Нурофен1', 'Кагоцел2', 'Фурацилин3', 'Анальгин4', 'Мирамистин5', 'Плацебо6']) as gName
)
INSERT INTO Medicine(tradeName, genericName, dosageForm, manufacturer, activeSubstance, certificate)
SELECT tName, gName,
    (0.5 + random() * (SELECT COUNT(*) FROM DosageForm))::int,
    (0.5 + random() * (SELECT COUNT(*) FROM Manufacturer))::int,
    (0.5 + random() * (SELECT COUNT(*) FROM ChemicalCompound))::int,
    (0.5 + random() * (SELECT COUNT(*) FROM Certificate))::int
    FROM Names;



-- добавляем аптеки
INSERT INTO Pharmacy(number, name, address)
VALUES  (1, 'Радуга', 'Павлова'),
        (2, 'Береза', 'Попова'),
        (3, 'Медбрат', 'Хлопина');

WITH Meds as(
    SELECT id as medId from Medicine
), Parmas as(
    SELECT id as pharmacyId from Pharmacy
)
INSERT INTO MedsInPharmas (pharmacyId, medicineId,cost ,amount)
SELECT pharmacyId, medId,  (random() * 10)::int, (random() * 10)::int FROM Meds CROSS JOIN Parmas;


END;
$$ LANGUAGE plpgsql;