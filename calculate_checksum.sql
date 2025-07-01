CREATE OR ALTER PROCEDURE dbo.GenerateChecksumForNewAccounts
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert valid account numbers and checksum results
    INSERT INTO Staging.dbo.ChecksumResult (
        AccountNumber,
        RawChecksum,
        FinalChecksum,
        LoadTimestamp
    )
    SELECT 
        AccountNumber,
        
        -- RawChecksum: Weighted sum mod 11
        (D1 * 2048 + D2 * 1024 + D3 * 512 + D4 * 256 + D5 * 128 + 
         D6 * 64 + D7 * 32 + D8 * 16 + D9 * 8 + D10 * 4 + D11 * 2) % 11 AS RawChecksum,

        -- FinalChecksum calculation
        CASE 
            WHEN (D1 * 2048 + D2 * 1024 + D3 * 512 + D4 * 256 + D5 * 128 + 
                  D6 * 64 + D7 * 32 + D8 * 16 + D9 * 8 + D10 * 4 + D11 * 2) % 11 = 1 
                THEN -1
            WHEN (D1 * 2048 + D2 * 1024 + D3 * 512 + D4 * 256 + D5 * 128 + 
                  D6 * 64 + D7 * 32 + D8 * 16 + D9 * 8 + D10 * 4 + D11 * 2) % 11 != 0 
                THEN 11 - ((D1 * 2048 + D2 * 1024 + D3 * 512 + D4 * 256 + D5 * 128 + 
                            D6 * 64 + D7 * 32 + D8 * 16 + D9 * 8 + D10 * 4 + D11 * 2) % 11)
            ELSE 0
        END AS FinalChecksum,

        GETDATE() AS LoadTimestamp

    FROM (
        SELECT 
            AccountNumber,
            -- Extract digits as integers
            TRY_CAST(SUBSTRING(AccountNumber, 1, 1) AS INT) AS D1,
            TRY_CAST(SUBSTRING(AccountNumber, 2, 1) AS INT) AS D2,
            TRY_CAST(SUBSTRING(AccountNumber, 3, 1) AS INT) AS D3,
            TRY_CAST(SUBSTRING(AccountNumber, 4, 1) AS INT) AS D4,
            TRY_CAST(SUBSTRING(AccountNumber, 5, 1) AS INT) AS D5,
            TRY_CAST(SUBSTRING(AccountNumber, 6, 1) AS INT) AS D6,
            TRY_CAST(SUBSTRING(AccountNumber, 7, 1) AS INT) AS D7,
            TRY_CAST(SUBSTRING(AccountNumber, 8, 1) AS INT) AS D8,
            TRY_CAST(SUBSTRING(AccountNumber, 9, 1) AS INT) AS D9,
            TRY_CAST(SUBSTRING(AccountNumber, 10, 1) AS INT) AS D10,
            TRY_CAST(SUBSTRING(AccountNumber, 11, 1) AS INT) AS D11
        FROM NewAccountNumbers
        WHERE 
            LEN(AccountNumber) = 11 
            AND AccountNumber NOT LIKE '%[^0-9]%'  -- Ensure it's all numeric
    ) AS ValidAccounts;
END;
GO









--To EXECUTE

EXEC dbo.GenerateChecksumForNewAccounts;
