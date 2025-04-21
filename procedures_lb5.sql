-- 1. Перевірка існуючих баз
EXEC sp_databases;

-- 2. Перевірка існуючих таблиць в базі
EXEC sp_tables;

-- 3. Перевірка структури таблиці Animal
EXEC sp_help 'Animal';

-- 1. Глобальна тимчасова процедура: Додавання тварини
CREATE PROCEDURE ##InsertAnimal
    @Nickname VARCHAR(50),
    @Gender CHAR(6),
    @Age INT,
    @Purpose VARCHAR(10)
AS
BEGIN
    INSERT INTO Animal (Nickname, Gender, Age, Purpose)
    VALUES (@Nickname, @Gender, @Age, @Purpose);
END;

-- 2. Отримання списку тварин
CREATE PROCEDURE ##GetAnimals
AS
BEGIN
    SELECT * FROM Animal;
END;

-- 3. Видалення тварини за ID
CREATE PROCEDURE ##DeleteAnimalByID
    @ID INT
AS
BEGIN
    DELETE FROM Animal WHERE AnimalID = @ID;
END;

-- 1. Тимчасова процедура для оновлення віку
CREATE PROCEDURE #UpdateAnimalAge
    @ID INT,
    @NewAge INT
AS
BEGIN
    UPDATE Animal SET Age = @NewAge WHERE AnimalID = @ID;
END;

-- 2. Тимчасова процедура для вибірки за статтю
CREATE PROCEDURE #GetByGender
    @Gender CHAR(6)
AS
BEGIN
    SELECT * FROM Animal WHERE Gender = @Gender;
END;

-- 3. Тимчасова процедура для підрахунку кількості тварин
CREATE PROCEDURE #CountAnimals
AS
BEGIN
    SELECT COUNT(*) AS Total FROM Animal;
END;

-- Користувацькі збережені процедури + транзакції
CREATE PROCEDURE InsertAnimalTransaction
    @Nickname VARCHAR(50),
    @Gender CHAR(6),
    @Age INT,
    @Purpose VARCHAR(10)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Animal (Nickname, Gender, Age, Purpose)
        VALUES (@Nickname, @Gender, @Age, @Purpose);
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Помилка вставки тварини!';
    END CATCH;
END;

--Процедура з параметром кількості рядків
CREATE PROCEDURE InsertMultipleAnimals
    @Count INT
AS
BEGIN
    DECLARE @i INT = 1;
    WHILE @i <= @Count
    BEGIN
        INSERT INTO Animal (Nickname, Gender, Age, Purpose)
        VALUES (CONCAT('Pig_', @i), 'male', FLOOR(RAND()*5 + 1), 'breeding');
        SET @i += 1;
    END;
END;

-- Створення функції, яка вставляє запис і повертає первинний ключ
CREATE FUNCTION InsertAnimalWithSequence (
    @Nickname VARCHAR(50),
    @Gender CHAR(6),
    @Age INT,
    @Purpose VARCHAR(10)
)
RETURNS INT
AS
BEGIN
    DECLARE @NewID INT;

    BEGIN TRY
        -- Отримати нове значення ключа
        SET @NewID = NEXT VALUE FOR Seq_AnimalID;

        -- Вставити новий запис
        INSERT INTO Animal (AnimalID, Nickname, Gender, Age, Purpose)
        VALUES (@NewID, @Nickname, @Gender, @Age, @Purpose);

        RETURN @NewID;
    END TRY
    BEGIN CATCH
        RETURN NULL;
    END CATCH;
END;
