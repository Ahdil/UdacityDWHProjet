
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

CREATE EXTERNAL TABLE dbo.dim_station
WITH (
	LOCATION = 'dims/dim_station.parquet',
	DATA_SOURCE = [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
AS  
SELECT 
     [station_id] 
    ,[name]
FROM 
    staging.station
GO

SELECT TOP 100 * FROM dim_station	
GO

SELECT count(*) FROM dim_station