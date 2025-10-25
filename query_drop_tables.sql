USE GD2C2025;
GO

DECLARE @sql NVARCHAR(MAX);

-- 1️⃣ Eliminar FOREIGN KEYS
SET @sql = N'';
SELECT @sql += N'ALTER TABLE [' + OBJECT_SCHEMA_NAME(f.parent_object_id) + '].[' +
               OBJECT_NAME(f.parent_object_id) + '] DROP CONSTRAINT [' + f.name + '];' + CHAR(13)
FROM sys.foreign_keys AS f
WHERE OBJECT_SCHEMA_NAME(f.parent_object_id) = 'LOS_DESNORMALIZADOS';

EXEC sp_executesql @sql;

-- 2️⃣ Eliminar TRIGGERS (de tabla y de base)
SET @sql = N'';
SELECT @sql += N'DROP TRIGGER [' + OBJECT_SCHEMA_NAME(t.object_id) + '].[' + t.name + '];' + CHAR(13)
FROM sys.triggers AS t
WHERE OBJECT_SCHEMA_NAME(t.parent_id) = 'LOS_DESNORMALIZADOS'
   OR OBJECT_SCHEMA_NAME(t.object_id) = 'LOS_DESNORMALIZADOS';

EXEC sp_executesql @sql;

-- 3️⃣ Eliminar VIEWS
SET @sql = N'';
SELECT @sql += N'DROP VIEW [' + OBJECT_SCHEMA_NAME(v.object_id) + '].[' + v.name + '];' + CHAR(13)
FROM sys.views AS v
WHERE OBJECT_SCHEMA_NAME(v.object_id) = 'LOS_DESNORMALIZADOS';

EXEC sp_executesql @sql;

-- 4️⃣ Eliminar PROCEDURES
SET @sql = N'';
SELECT @sql += N'DROP PROCEDURE [' + OBJECT_SCHEMA_NAME(p.object_id) + '].[' + p.name + '];' + CHAR(13)
FROM sys.procedures AS p
WHERE OBJECT_SCHEMA_NAME(p.object_id) = 'LOS_DESNORMALIZADOS';

EXEC sp_executesql @sql;

-- 5️⃣ Eliminar TABLES
SET @sql = N'';
SELECT @sql += N'DROP TABLE [' + OBJECT_SCHEMA_NAME(t.object_id) + '].[' + t.name + '];' + CHAR(13)
FROM sys.tables AS t
WHERE OBJECT_SCHEMA_NAME(t.object_id) = 'LOS_DESNORMALIZADOS';

EXEC sp_executesql @sql;

-- 6️⃣ Finalmente, eliminar el SCHEMA
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LOS_DESNORMALIZADOS')
    EXEC('DROP SCHEMA LOS_DESNORMALIZADOS;');
GO
