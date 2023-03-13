USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_RejectChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RejectChangeHistory]             
 @Id INT        
 ,@Reason NVARCHAR(MAX)        
 ,@UpdatedBy NVARCHAR(MAX)        
AS            
BEGIN  

DECLARE @FormId INT
 UPDATE RequestForChange            
 SET [Status] = 2 , ReasonIfRejected = @Reason ,  UpdateBy =  @UpdatedBy         
 WHERE             
   Id = @Id     

   

   DELETE FROM CiplItem_Change where IdCipl = (SELECT FormId FROM RequestForChange where Id = @Id)

   EXEC [dbo].[sp_Process_Email_RFC] @Id,'Reject'     


END 
GO
