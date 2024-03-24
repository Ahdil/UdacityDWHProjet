
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseParquetFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseParquetFormat] 
	WITH ( FORMAT_TYPE = PARQUET)
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'parquet_synapsedwhstoragedlgen2_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://parquet@synapsedwhstoragedlgen2.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE dbo.dim_rider
WITH (
	LOCATION = 'dims/dim_rider.parquet',
	DATA_SOURCE = [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
AS  
SELECT 
     [rider_id] 
    ,[is_member]
    ,[account_start_date]
    ,concat([first],' ',[last]) as [fullname]
   	,[birthday] 
    ,DATEDIFF(year, birthday, account_start_date) as [age_at_accountstart] 
FROM 
    staging.rider
GO


SELECT TOP 100 * FROM dim_rider	
GO