USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_SubConCompanyDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_SubConCompanyDelete]
(@Id bigint)
as 
begin
delete from MasterSubConCompany
where Id = @Id 
select @Id as Id
end	

GO
