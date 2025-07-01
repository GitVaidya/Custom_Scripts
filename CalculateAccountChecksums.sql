CREATE OR ALTER PROCEDURE dbo.CalculateAccountChecksums
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Drop and recreate the output table
    IF OBJECT_ID('Staging.dbo.ChecksumResult', 'U') IS NOT NULL
        DROP TABLE Staging.dbo.ChecksumResult;

    CREATE TABLE Staging.dbo.ChecksumResult (
        AccountNumber VARCHAR(11) PRIMARY KEY,
        RawChecksum INT,
        FinalChecksum INT
    );

    -- Step 2: Calculate checksums and insert
    INSERT INTO Staging.dbo.ChecksumResult (AccountNumber, RawChecksum, FinalChecksum)
    SELECT 
        AccountNumber,
        WeightedSum % 11 AS RawChecksum,
        CASE 
            WHEN WeightedSum % 11 = 1 THEN -1
            WHEN WeightedSum % 11 != 0 THEN 11 - (WeightedSum % 11)
            ELSE 0
        END AS FinalChecksum
    FROM (
        SELECT 
            AccountNumber,
            -- Weighted sum calculation
            (
                TRY_CAST(SUBSTRING(AccountNumber, 1, 1) AS INT) * 2048 +
                TRY_CAST(SUBSTRING(AccountNumber, 2, 1) AS INT) * 1024 +
                TRY_CAST(SUBSTRING(AccountNumber, 3, 1) AS INT) * 512 +
                TRY_CAST(SUBSTRING(AccountNumber, 4, 1) AS INT) * 256 +
                TRY_CAST(SUBSTRING(AccountNumber, 5, 1) AS INT) * 128 +
                TRY_CAST(SUBSTRING(AccountNumber, 6, 1) AS INT) * 64 +
                TRY_CAST(SUBSTRING(AccountNumber, 7, 1) AS INT) * 32 +
                TRY_CAST(SUBSTRING(AccountNumber, 8, 1) AS INT) * 16 +
                TRY_CAST(SUBSTRING(AccountNumber, 9, 1) AS INT) * 8 +
                TRY_CAST(SUBSTRING(AccountNumber, 10, 1) AS INT) * 4 +
                TRY_CAST(SUBSTRING(AccountNumber, 11, 1) AS INT) * 2
            ) AS WeightedSum
        FROM Staging.dbo.NewAccountNumbers
        WHERE 
            LEN(AccountNumber) = 11 AND
            AccountNumber NOT LIKE '%[^0-9]%' -- only digits
    ) AS ValidAccounts;
END;
GO



--To EXECUTE

EXEC dbo.CalculateAccountChecksums;
