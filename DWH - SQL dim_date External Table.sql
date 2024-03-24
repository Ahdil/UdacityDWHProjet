-- The following SQL code creates the dim_date external table using
-- our parquet file generated and saved with a copy pipeline 
-- We choose to use a pipeline for creating this dimension table 
-- because CETAS was not allowing comples inline SQL statements for data generation	

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

CREATE EXTERNAL TABLE dbo.dim_date (
	[date_id] datetime2(7),
	[date] date,
	[day_of_month] tinyint,
	[month] tinyint,
	[year] smallint,
	[month_name] varchar(25),
	[day_of_week] tinyint,
	[day_name] varchar(25),
	[hour] tinyint,
	[quarter] tinyint
	)
	WITH (
	LOCATION = 'dims/dim_date.parquet',
	DATA_SOURCE = [parquet_synapsedwhstoragedlgen2_dfs_core_windows_net],
	FILE_FORMAT = [SynapseParquetFormat]
	)
GO


SELECT TOP 100 * FROM dbo.dim_date
GO