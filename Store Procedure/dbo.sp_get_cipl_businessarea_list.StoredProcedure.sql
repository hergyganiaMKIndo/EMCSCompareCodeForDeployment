USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cipl_businessarea_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_task_cl]
CREATE PROCEDURE [dbo].[sp_get_cipl_businessarea_list] -- [dbo].[sp_get_task_cl] 'CKB1'
(
	@PlantCode nvarchar(50) = ''
)
AS
BEGIN
    select * from fn_get_cipl_businessarea_list('') where PlantName like '%'+ISNULL(@PlantCode, '')+'%' OR PlantCode like '%'+ISNULL(@PlantCode, '')+'%'
END
GO
