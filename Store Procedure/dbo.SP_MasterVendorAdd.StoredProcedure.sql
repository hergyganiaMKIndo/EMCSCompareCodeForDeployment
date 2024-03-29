USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_MasterVendorAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_MasterVendorAdd]  
(  
@Id nvarchar(100),  
@Name nvarchar(max),  
@Code nvarchar(max),
@Address nvarchar(max), 
@City nvarchar(max), 
@Telephone nvarchar(max), 
@CreateBy nvarchar(Max),  
@UpdatedBy nvarchar(Max),
@IsManualEntry bit
)  
as  
begin  
If (@Id = 0)  
begin  
insert into [MasterVendor]([Name],[Code],[Address],City,Telephone,CreateBy,CreateDate,UpdateBy,UpdateDate,IsManualEntry)  
VALUES(@Name,@Code,@Address,@City,@Telephone,@CreateBy,GetDate(),null,null,@IsManualEntry)  
SET @Id = SCOPE_IDENTITY()
update MasterVendor
set Code = @Code+@Id
where Id= @Id
end  
else  
begin  
update [MasterVendor]  
set [Name] = @Name,  
[Address] = @Address,
City = @City,
Telephone= @Telephone, 
UpdateBy = @UpdatedBy,   
UpdateDate = GETDATE()  
where Id = @Id  
end  
select CAST(@Id as bigint) as Id
end


GO
