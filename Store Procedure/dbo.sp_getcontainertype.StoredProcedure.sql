USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_getcontainertype]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_getcontainertype]
(
	@ContainerType nvarchar(50),
	@Value  nvarchar(50)
	
)	
as 
begin
select * from MasterParameter
where   Value = @Value  and [Group] = @ContainerType
end

GO
