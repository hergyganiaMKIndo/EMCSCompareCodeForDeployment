USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_CiplItemChangeList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_CiplItemChangeList]
(
@Id nvarchar(50)
)
as 
begin
select * from CiplItem_Change
where IdCipl = @Id
END

GO
