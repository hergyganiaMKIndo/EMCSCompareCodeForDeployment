USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_request_cl_for_si]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_update_request_cl_for_si] --41727, 'XUPJ21WDN', 'Submit', '', 'NonPJT' 
(      
 @IdCl bigint,      
 @Username nvarchar(100),      
 @NewStatus nvarchar(100),      
 @Notes nvarchar(100) = '',   
 @exportType nvarchar(10)=''      
)      
AS      
BEGIN      
 DECLARE @NewStepId bigint;      
 DECLARE @IdFlow bigint;      
 DECLARE @FlowName nvarchar(100);      
 DECLARE @NextStepName nvarchar(100);      
 DECLARE @Now datetime;      
 DECLARE @GroupId nvarchar(100);      
 DECLARE @UserType nvarchar(100);      
 DECLARE @NextStepIdSystem bigint;      
 DECLARE @LoadingPort nvarchar(100);      
 DECLARE @DestinationPort nvarchar(100);      
 DECLARE @CurrentStepId bigint;      
 DECLARE @CurrentStatus nvarchar(100);      
        
 SET @Now = GETDATE();      
 select @UserType = [Group] From dbo.fn_get_employee_internal_ckb() WHERE AD_User = @Username      
      
 IF @UserType <> 'internal' AND @UserType = 'CKB'      
 BEGIN      
  SET @GroupId = 'CKB';      
 END      
 ELSE       
 BEGIN      
  SELECT @GroupId = hce.Organization_Name       
  FROM employee hce       
  WHERE hce.AD_User = @Username;      
 END      
      
 --select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list(@Username, @GroupId) t0 where t0.IdCl = @IdCl;      
 --select * from dbo.fn_get_cl_request_list_all() where IdCl = 3;      
      
 Select @CurrentStepId = IdStep, @CurrentStatus = [Status] From [dbo].[RequestCl] WHERE IdCl = @IdCl      
          
    IF @NewStatus = 'Approve'      
    BEGIN      
        SELECT @LoadingPort = PortOfLoading , @DestinationPort = PortOfDestination FROM Cargo where Id = @IdCl       
        Update Cipl SET LoadingPort = @LoadingPort ,DestinationPort = @DestinationPort Where id in (Select IdCipl From CargoCipl where IdCargo = @IdCl)      
    END      
      
      
 IF @CurrentStepId = 30069      
    BEGIN      
        IF @NewStatus = 'Approve'      
        BEGIN      
            SET @NewStepId = 30070      
            SET @NextStepName = 'Waiting NPE Document'      
            SET @FlowName = 'CL'      
        END      
        ELSE IF @NewStatus = 'Revise'      
        BEGIN      
            SET @NewStepId = 30070      
            SET @NextStepName = 'Need revision review by imex'      
            SET @FlowName = 'CL'      
            SET @NewStatus = 'Revise'      
        END        
        ELSE IF @NewStatus = 'Reject'      
        BEGIN      
            SET @NewStepId = 30070      
            SET @NextStepName = 'Reject by imex'      
            SET @FlowName = 'CL'      
            SET @NewStatus = 'Reject'      
        END        
      
        UPDATE [dbo].[RequestCl]      
        SET [IdStep] = @NewStepId      
            ,[Status] = @NewStatus      
            --,[Pic] = @Username      
            ,[UpdateBy] = @Username      
            ,[UpdateDate] = GETDATE()      
        WHERE IdCl = @IdCl      
    END      
 ELSE IF @CurrentStepId = 30071      
    BEGIN      
        IF @NewStatus = 'Approve'      
        BEGIN      
            SET @NewStepId = 10020      
            SET @NextStepName = 'Waiting for BL or AWB'      
            SET @FlowName = 'CL'      
        END      
        ELSE IF @NewStatus = 'Revise'      
        BEGIN      
            SET @NewStepId = 30072      
            SET @NextStepName = 'Need revision review by imex'      
            SET @FlowName = 'CL'      
            SET @NewStatus = 'Revise'      
        END      
        ELSE IF @NewStatus = 'Reject'      
        BEGIN      
            SET @NewStepId = 30072      
            SET @NextStepName = 'Need revision review by imex'      
            SET @FlowName = 'CL'      
            SET @NewStatus = 'Reject'      
        END      
      
        UPDATE [dbo].[RequestCl]      
        SET [IdStep] = @NewStepId      
            ,[Status] = @NewStatus      
            --,[Pic] = @Username      
            ,[UpdateBy] = @Username      
            ,[UpdateDate] = GETDATE()      
        WHERE IdCl = @IdCl      
    END   
 ELSE      
    BEGIN      
        select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list_all() t0 where t0.IdCl = @IdCl;      
        --PRINT 'NewStepId ' + CAST(@NewStepId AS VARCHAR(10));      
        --  PRINT 'NewStatus ' + CAST(@NewStatus AS VARCHAR(10));      
        --  PRINT 'CurrentStepId ' + CAST(@CurrentStepId AS VARCHAR(10));      
        --  PRINT 'NextStepName ' + CAST(@NextStepName AS VARCHAR(10));      
            IF @CurrentStepId = 12       
                BEGIN      
                IF @NewStepId = 10017 AND @NewStatus = 'Submit'      
                BEGIN      
                --declare @exportType nvarchar(10)=''      
                --SET @exportType = (select top 1 exporttype from dbo.ShippingInstruction where IdCL =@IdCl)      
                IF (@exportType ='PJT')      
                BEGIN      
					--SET @NewStepId = 10020   
					--SET @NextStepName = 'Waiting for BL or AWB'      
					--SET @FlowName = 'CL'      
					--SET @NewStatus = 'Approve'    
					SET @NewStepId = 10021 
					--SET @NewStepId = 10017 
					SET @NextStepName = 'Waiting for BL or AWB'      
					SET @FlowName = 'CL'      
					SET @NewStatus = 'Create'
                --PRINT 'exporttype ' + CAST(@exporttype AS VARCHAR(10));      
                END   
				--ELSE IF (@exportType = 'NonPJT')
				--BEGIN
				--	SET @NewStepId = 10020   
				--	SET @NextStepName = 'Waiting for BL or AWB'      
				--	SET @FlowName = 'CL'      
				--	SET @NewStatus = 'Approve'
				--END   
                --PRINT 'exporttype ' + CAST(@exporttype AS VARCHAR(10));      
                END       
                END       
        UPDATE [dbo].[RequestCl]      
            SET [IdStep] = @NewStepId      
                ,[Status] = @NewStatus      
                ,[Pic] = @Username      
                ,[UpdateBy] = @Username      
                ,[UpdateDate] = GETDATE()      
        WHERE IdCl = @IdCl      
    END      
       
 -- Hasni Procedure Cancel PEB      
 IF  @NewStatus = 'Request Cancel'      
 BEGIN      
  SET @NewStepId = 30041      
      
  UPDATE [dbo].[RequestCl]      
  SET [IdStep] = @NewStepId      
      ,[Status] = @NewStatus      
      ,[Pic] = @Username      
   ,[UpdateBy] = @Username      
   ,[UpdateDate] = GETDATE()      
 WHERE IdCl = @IdCl      
 END      
      
 IF  @NewStatus = 'Draft NPE'      
 BEGIN      
  SET @NewStepId = 30069      
  SET @NewStatus = 'Submit'      
  SET @NextStepName = 'Waiting approve draft NPE'      
  SET @FlowName = 'CL'      
      
  UPDATE [dbo].[RequestCl]      
  SET [IdStep] = @NewStepId      
      ,[Status] = @NewStatus      
      ,[Pic] = @Username      
   ,[UpdateBy] = @Username      
   ,[UpdateDate] = GETDATE()      
  WHERE IdCl = @IdCl      
 END      
      
 IF  @NewStatus = 'Create NPE'      
 BEGIN      
  SET @NewStepId = 30071      
  SET @NewStatus = 'Submit'      
  SET @NextStepName = 'Waiting approval NPE'      
  SET @FlowName = 'CL'      
      
  UPDATE [dbo].[RequestCl]      
  SET [IdStep] = @NewStepId      
      ,[Status] = @NewStatus      
      ,[Pic] = @Username      
   ,[UpdateBy] = @Username      
   ,[UpdateDate] = GETDATE()      
  WHERE IdCl = @IdCl      
 END      
      
 IF @NewStepId = 30042 AND @NewStatus = 'Approve'      
 BEGIN      
  UPDATE dbo.NpePeb SET IsDelete = 1 WHERE IdCl = @IdCl;      
 END       
      
 --======================================================      
 --- Kondisi jika cl akan melanjutkan proses ke system      
 --======================================================      
 IF @NewStepId = 11 AND @NewStatus = 'Submit'      
 BEGIN      
  select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;      
      
  UPDATE [dbo].[RequestCl]      
  SET [IdStep] = @NextStepIdSystem      
      ,[Status] = @NewStatus      
      ,[Pic] = @Username      
   ,[UpdateBy] = @Username      
   ,[UpdateDate] = GETDATE()      
  WHERE IdCl = @IdCl      
      
  exec sp_set_ss_number @IdCl = @IdCl      
  exec sp_update_cipl_to_revise @IdCl      
 END      
      
 IF @NewStepId = 20033 AND @NewStatus = 'Approve'      
 BEGIN      
  select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;      
      
  UPDATE [dbo].[RequestCl]      
  SET [IdStep] = @NewStepId      
      ,[Status] = @NewStatus      
      ,[Pic] = @Username      
   ,[UpdateBy] = @Username      
   ,[UpdateDate] = GETDATE()      
  WHERE IdCl = @IdCl      
      
  exec sp_update_cipl_to_revise @IdCl      
 END      
 --======================================================      
      
 exec [dbo].[sp_insert_cl_history]@id=@IdCl, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;      
      
 IF((select Status from RequestCl where IdCl = @IdCl) <> 'DRAFT')      
 BEGIN      --EXEC [sp_send_email_notification] @IdCl, 'Cargo'      
  EXEC [sp_proccess_email] @IdCl, 'CL'      
 END      
END
GO
