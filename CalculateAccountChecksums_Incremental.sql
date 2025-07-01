--- Final Optimized Incremental Stored Procedure

CREATE OR ALTER PROCEDURE dbo.CalculateAccountChecksums_Incremental
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @EndTime DATETIME;
    DECLARE @RowCount INT = 0;
    DECLARE @Status VARCHAR(20) = 'Success';
    DECLARE @ErrorMessage NVARCHAR(1000) = NULL;

    BEGIN TRY
        -- Step 1: Insert only new Account Numbers (not already in ChecksumResult)
        INSERT INTO Staging.dbo.ChecksumResult (AccountNumber, RawChecksum, FinalChecksum, LoadTimestamp)
        SELECT
            A.AccountNumber,
            C.RawChecksum,
            C.FinalChecksum,
            GETDATE()
        FROM Staging.dbo.NewAccountNumbers AS A
        LEFT JOIN Staging.dbo.ChecksumResult AS R
            ON A.AccountNumber = R.AccountNumber
        WHERE 
            R.AccountNumber IS NULL -- Exclude already processed
            AND LEN(A.AccountNumber) = 11
            AND A.AccountNumber LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        CROSS APPLY (
            SELECT 
                CAST(SUBSTRING(A.AccountNumber, 1, 1) AS INT) * 2048 +
                CAST(SUBSTRING(A.AccountNumber, 2, 1) AS INT) * 1024 +
                CAST(SUBSTRING(A.AccountNumber, 3, 1) AS INT) * 512  +
                CAST(SUBSTRING(A.AccountNumber, 4, 1) AS INT) * 256  +
                CAST(SUBSTRING(A.AccountNumber, 5, 1) AS INT) * 128  +
                CAST(SUBSTRING(A.AccountNumber, 6, 1) AS INT) * 64   +
                CAST(SUBSTRING(A.AccountNumber, 7, 1) AS INT) * 32   +
                CAST(SUBSTRING(A.AccountNumber, 8, 1) AS INT) * 16   +
                CAST(SUBSTRING(A.AccountNumber, 9, 1) AS INT) * 8    +
                CAST(SUBSTRING(A.AccountNumber, 10, 1) AS INT) * 4   +
                CAST(SUBSTRING(A.AccountNumber, 11, 1) AS INT) * 2
            AS Total
        ) AS B
        CROSS APPLY (
            SELECT 
                B.Total % 11 AS RawChecksum,
                CASE 
                    WHEN B.Total % 11 = 1 THEN -1
                    WHEN B.Total % 11 <> 0 THEN 11 - (B.Total % 11)
                    ELSE 0
                END AS FinalChecksum
        ) AS C;

        -- Step 2: Get row count inserted
        SET @RowCount = @@ROWCOUNT;

    END TRY
    BEGIN CATCH
        SET @Status = 'Failed';
        SET @ErrorMessage = ERROR_MESSAGE();
    END CATCH;

    SET @EndTime = GETDATE();

    -- Step 3: Log to audit table
    INSERT INTO Staging.dbo.Checksum_AuditLog (
        StartTime, EndTime, RecordsInserted, Status, ErrorMessage
    )
    VALUES (
        @StartTime, @EndTime, @RowCount, @Status, @ErrorMessage
    );
END;
GO
