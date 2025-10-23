-- Ajustá el nombre del schema si corresponde
DECLARE @schema SYSNAME = N'LOS_DESNORMALIZADOS';
DECLARE @sql NVARCHAR(MAX);

-- 1) DROP FOREIGN KEYS que afectan tablas del schema
SET @sql = N'';
SELECT @sql += N'
IF OBJECT_ID(''' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id)) + ''',''U'') IS NOT NULL
    ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
    + ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';'
FROM sys.foreign_keys fk
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = @schema
   OR OBJECT_SCHEMA_NAME(fk.referenced_object_id) = @schema;

PRINT '-- Sentencias para eliminar FOREIGN KEYS:';
PRINT @sql;
-- Ejecutar (descomentá si estás listo)
EXEC sp_executesql @sql;


-- 2) DROP TABLE para todas las tablas del schema
SET @sql = N'';
SELECT @sql += N'
IF OBJECT_ID(''' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ''',''U'') IS NOT NULL
    DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @schema
-- Opcional: ordenar para ver el orden en que se generan (no necesario luego de eliminar FKs)
ORDER BY t.name;

PRINT ''-- Sentencias para DROP TABLE:'';
PRINT @sql;
-- Ejecutar (descomentá si estás listo)
EXEC sp_executesql @sql;
