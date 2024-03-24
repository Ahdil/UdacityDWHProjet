
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



CREATE EXTERNAL TABLE dbo.fact_money_spent 
WITH (
	LOCATION = 'facs/fact_money_spend.parquet',
	DATA_SOURCE = [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
AS  
SELECT 
  [payment_id] 
 ,[date] as [date_id]
 ,[dim_rider].[rider_id]
 ,[amount]
FROM staging.payment
  INNER JOIN dim_rider ON dim_rider.rider_id = staging.payment.rider_id
GO


SELECT TOP 100 * FROM fact_money_spent
GO

