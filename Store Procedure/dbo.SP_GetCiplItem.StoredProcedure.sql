USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetCiplItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetCiplItem]  
(  
@IdCipl nvarchar(100)  
)  
as   
begin   
select count(Id)
 from CiplItem  
where IdCipl = @IdCipl and IsDelete = 0  
end
GO
