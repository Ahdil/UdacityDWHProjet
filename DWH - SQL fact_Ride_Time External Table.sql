
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

CREATE EXTERNAL TABLE dbo.fact_ride_time 
WITH (
	LOCATION = 'facts/fact_ride_time.parquet',
	DATA_SOURCE = [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
AS  
SELECT
 [trip_id]
,t.[rider_id]
,[start_station_id]
,[end_station_id]
-- [date_id] is the hour in which the ride was started 
-- (mins, secs and millisecs are removed in below statement)
,Dateadd(hour, datediff(hour, 0, [start_at]), 0) as [date_id]
,Datediff(minute, [start_at], [ended_at]) as ride_time_in_mins
FROM 
    staging.trip t 
INNER JOIN dim_rider r ON r.rider_id = t.rider_id	
GO


SELECT TOP 100 * FROM fact_ride_time 
GO

