USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateFileForHistoryBlAwb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_UpdateFileForHistoryBlAwb]    
(    
@IdBlAwb bigint,    
@FileName nvarchar(max) = ''    
)    
as    
begin    
declare @Id  bigint     
insert  into [BlAwbDocumentHistory](IdBlAwb,FileName,CreateDate)    
values (@IdBlAwb,@FileName,GETDATE())    
set @Id = SCOPE_IDENTITY()    
select @Id As Id    
end

GO
