USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_MasterVendorDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SP_MasterVendorDelete]  
(@Id bigint)  
as   
begin  
delete from MasterVendor  
where Id = @Id   
select @Id as Id  
end 
GO
