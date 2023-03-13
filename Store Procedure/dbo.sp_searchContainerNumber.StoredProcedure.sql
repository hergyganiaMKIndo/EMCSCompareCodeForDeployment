USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_searchContainerNumber]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_searchContainerNumber]
(
	@IdCargo bigint,
	@ContainerNumber  nvarchaR(100)
	
)	
as 
begin
select * from CargoItem
where IdCargo = @IdCargo and ContainerNumber = @ContainerNumber
end

GO
