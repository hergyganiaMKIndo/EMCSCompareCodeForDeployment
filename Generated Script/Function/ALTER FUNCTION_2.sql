/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_cl_request_list] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export','xupj21wdn') 
( 
	-- Add the parameters for the function here
	@Username nvarchar(100),
	@GroupId nvarchar(100),
	@Pic nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]  
			,t0.IdCl 
			,t0.[IdFlow] 
			,t0.[IdStep] 
			,t0.[Status] 
			,t0.[Pic]  
			,t0.[CreateBy] 
			,t0.[CreateDate] 
			,t0.[UpdateBy]  
			,t0.[UpdateDate] 
			,t0.[IsDelete]  
			,t12.IsCancelled  
			,CASE WHEN t12.Id Is null Then 0 else t12.Id end AS IdNpePeb
			,t3.Name FlowName
			,t3.Type SubFlowType
			, CASE 
				WHEN t0.[IdStep] = 30074 THEN 30075  
				WHEN t0.[IdStep] = 30075 THEN 30076  
				WHEN t0.[IdStep] = 30076 THEN Null  
				WHEN t0.[IdStep] = 30070 THEN 30071 ELSE [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) END as IdNextStep 
			, CASE WHEN t0.[IdStep] = 30069 THEN 'Approve draft NPE & PEB' 
				WHEN t0.[IdStep] = 30070 THEN 'Create NPE'  
				WHEN t0.[IdStep] = 30074 THEN 'waiting for beacukai approval'  
				WHEN t0.[IdStep] = 30075 THEN 'Cancelled'  
				WHEN t0.[IdStep] = 30076 THEN ''  
    WHEN t0.[IdStep] = 30071 THEN 'Approve NPE' ELSE [dbo].[fn_get_step_name](
	    [dbo].[fn_get_next_step_id](
	     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
	    )
	    ) END as NextStepName
	  , [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
	  , CASE WHEN t0.[IdStep] = 30069 THEN 'Waiting approval draft PEB' 
	   WHEN (t0.[IdStep] = 30070 AND t0.[Status] = 'Approve') THEN 'Waiting NPE document' 
	   WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = 'Revise') THEN 'Need revision review by imex' 
	   when t12.IsCancelled = 0 then 'Request Cancel Only PebNpe'  
    when t12.IsCancelled = 1 then 'waiting for beacukai approval'  
    when t12.IsCancelled = 2 then 'Cancelled'  
    WHEN t0.[IdStep] = 30071 THEN 'Waiting approval NPE'  
    WHEN t0.[IdStep] = 30074 THEN 'Request Cancel'  
    WHEN t0.[IdStep] = 30075 THEN 'waiting for beacukai approval'  
    WHEN t0.[IdStep] = 30076 THEN 'Cancelled'  
    ELSE CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, t5.AD_User
			, t4.FullName
			, t5.Employee_Name
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, CASE   
  --WHEN (t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 )   
   -- THEN 'XUPJ21WDN'   
    --WHEN (t0.[IdStep] = 30074)  
    --then 'IMEX'  
    WHEN (t0.[IdStep] = 30070)   
     THEN t6.PicBlAwb  
    when (((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 8 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076  or t12.IsCancelled = 0 or t12.IsCancelled =
 1 or t12.IsCancelled = 2) or  
    ((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 24 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076 or t12.IsCancelled = 0 or t12.IsCancelled = 1 or 
t12.IsCancelled = 2))  
    then @Username  
    ELSE   
     [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id)   
     END AS NextAssignTo  
			, t6.SpecialInstruction
			, t6.SlNo
			, t6.Description
			, t6.DocumentRequired
			, t2.ShippingMethod
			, t12.AjuNumber as PebNumber
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t6.PicBlAwb
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl AND t6.isdelete = 0
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
		left join dbo.NpePeb t12 on t12.IdCl = t2.Id
		WHERE t0.CreateBy <> 'System' and t0.IsDelete = 0  and t2.CreateBy <> 'System'
	) as tab0 
	WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId OR tab0.PicBlAwb = @Pic)
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list_all]    Script Date: 10/03/2023 15:51:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_gr_request_list_all] -- select * from [fn_get_gr_request_list_all]('xupj21jpd', 'IMEX')     
(     
 -- Add the parameters for the function here    
 --@Username nvarchar(100),    
 --@GroupId nvarchar(100)    
)    
RETURNS TABLE     
AS    
RETURN     
(    
 -- Add the SELECT statement with parameter references here    
 select * from (    
   select     
   t0.[Id]      
   ,t0.IdGr     
   ,t0.[IdFlow]     
   ,t0.[IdStep]     
   ,CASE         
     WHEN t0.[Status] = 'Submit'    
     --THEN t0.[Status]  
  THEN 'Waiting Approval'    
     ELSE t0.[Status]     
   END AS [Status]    
   --,t0.[Status]     
   ,t0.[Pic]      
   ,t0.[CreateBy]     
   ,t0.[CreateDate]     
   ,t0.[UpdateBy]      
   ,t0.[UpdateDate]     
   ,t0.[IsDelete]      
   , t3.Name FlowName    
   , t3.Type SubFlowType    
   , [dbo].[fn_get_next_step_id](    
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,     
    [dbo].fn_get_status_id(    
     t0.IdStep, t0.Status    
    ), t0.Id    
   ) as IdNextStep     
   , [dbo].[fn_get_step_name](    
    [dbo].[fn_get_next_step_id](    
     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,     
     [dbo].fn_get_status_id(    
      t0.IdStep, t0.Status    
     ), t0.Id    
    )    
   ) as NextStepName    
   , [dbo].[fn_get_next_assignment_type](    
    t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
   ) NextAssignType    
   , t1.ViewByUser NextStatusViewByUser    
   , t2.GrNo    
   , (select top 1 s.PicName from Shippingfleet s where  s.IdGr =  t0.IdGr)as PicName  
   , (select top 1 s.PhoneNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as PhoneNumber    
   , (select top 1 s.SimNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as SimNumber    
   , (select top 1 s.StnkNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as StnkNumber    
   , (select top 1 s.NopolNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as NopolNumber    
   , (select top 1 s.EstimationTimePickup from Shippingfleet s where  s.IdGr =  t0.IdGr)as EstimationTimePickup    
   , [dbo].[fn_get_next_assignment_type](    
    t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
   ) as AssignmentType    
   , [dbo].[fn_get_next_approval] (    
    [dbo].[fn_get_next_assignment_type](    
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
    ), t0.Pic, t1.NextAssignTo, t0.CreateBy, t0.Id) as NextAssignTo    
  from dbo.RequestGr t0    
  left join (    
   select     
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,     
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,     
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,    
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName    
   from dbo.FlowNext nx    
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus    
   join dbo.FlowStep np on np.Id = ns.IdStep    
   join dbo.Flow nf on nf.Id = np.IdFlow    
   join dbo.FlowStep nt on nt.Id = nx.IdStep    
  ) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status    
  inner join dbo.GoodsReceive t2 on t2.id = t0.IdGr    
  inner join dbo.Flow t3 on t3.id = t0.IdFlow    
 ) as tab0     
 --WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)    
) 
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_gr_request_list] -- select * from [fn_get_gr_request_list]('xupj21jpd', 'IMEX')   
(   
 -- Add the parameters for the function here  
 @Username nvarchar(100),  
 @GroupId nvarchar(100)  
)  
RETURNS TABLE   
AS  
RETURN   
(  
 -- Add the SELECT statement with parameter references here  
 select * from (  
   select   
   t0.[Id]    
   ,t0.IdGr
   ,t0.[IdFlow]   
   ,t0.[IdStep]   
   ,CASE       
     WHEN t0.[Status] = 'Submit'  
     THEN 'Waiting Approval'  
     ELSE t0.[Status]   
   END AS [Status]   
   ,t0.[Pic]    
   ,t0.[CreateBy]   
   ,t0.[CreateDate]   
   ,t0.[UpdateBy]    
   ,t0.[UpdateDate]   
   ,t0.[IsDelete]    
   , t3.Name FlowName  
   , t3.Type SubFlowType  
   , [dbo].[fn_get_next_step_id](  
     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,   
     [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id  
     ) as IdNextStep   
   , [dbo].[fn_get_step_name](  
     [dbo].[fn_get_next_step_id](  
      t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,   
      [dbo].fn_get_status_id(  
       t0.IdStep, t0.Status  
      ), t0.Id  
     )  
     ) as NextStepName  
   , [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
     ) NextAssignType  
   , t1.ViewByUser NextStatusViewByUser  
   , t2.GrNo  
   , (select top 1 s.PicName from Shippingfleet s where  s.IdGr =  t0.IdGr )as PicName
   , (select top 1 s.PhoneNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as PhoneNumber  
   , (select top 1 s.SimNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as SimNumber  
   , (select top 1 s.StnkNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as StnkNumber  
   , (select top 1 s.NopolNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as NopolNumber  
   , (select top 1 s.EstimationTimePickup from Shippingfleet s where  s.IdGr =  t0.IdGr )as EstimationTimePickup     
   , [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
     ) as AssignmentType  
   , [dbo].[fn_get_next_approval] (  
    [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
    ), t0.Pic, t1.NextAssignTo, t0.CreateBy, t0.Id  
    ) as NextAssignTo  
  from dbo.RequestGr t0  
  left join (  
   select   
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,   
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,   
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,  
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName  
   from dbo.FlowNext nx  
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus  
   join dbo.FlowStep np on np.Id = ns.IdStep  
   join dbo.Flow nf on nf.Id = np.IdFlow  
   join dbo.FlowStep nt on nt.Id = nx.IdStep  
  ) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status  
  inner join dbo.GoodsReceive t2 on t2.id = t0.IdGr  
  inner join dbo.Flow t3 on t3.id = t0.IdFlow  
 ) as tab0   
 WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)  
)    
  

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_approval]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_next_approval]  
(    
 -- Add the parameters for the function here    
 @Type nvarchar(100),    
 @LastUser nvarchar(100),    
 @GroupID nvarchar(100),    
 @Creator nvarchar(100),    
 @IdRequest nvarchar(100) = '0'    
)    
RETURNS nvarchar(100)    
AS    
BEGIN    
 -- Declare the return variable here    
 DECLARE @Result nvarchar(100);    
 DECLARE @BArea nvarchar(100);    
 DECLARE @SuperiorUsername nvarchar(500);    
 SELECT @BArea = Business_Area FROM employee WHERE AD_User = @LastUser;    
    
 -- Add the T-SQL statements to compute the return value here    
 IF @Type = 'Superior'     
 BEGIN    
  SELECT @SuperiorUsername = SuperiorUsername FROM mastersuperior WHERE IsDeleted = 0 AND employeeUsername = @Creator;    
  IF ISNULL(@SuperiorUsername, '') = ''    
  BEGIN    
   SELECT @Result = t1.AD_User from employee as t0    
   inner join employee as t1 on t1.Employee_Id = t0.Superior_ID    
   WHERE t0.AD_User = @Creator    
  END    
  ELSE    
  BEGIN    
   SET @Result = @SuperiorUsername;    
  END    
      
 END     
     
 IF @Type = 'Group'     
 BEGIN    
	SELECT @SuperiorUsername = SuperiorUsername FROM mastersuperior WHERE IsDeleted = 0 AND employeeUsername = @Creator;    
	IF ISNULL(@SuperiorUsername, '') = ''   
	BEGIN
		IF EXISTS	(SELECT	TOP	1 *
					FROM	employee
					WHERE	Organization_Name LIKE '%' + @GroupID +'%'
							AND Employee_Name LIKE '%Asmat%')
			BEGIN
				SELECT	@Result = AD_User 
				FROM	employee
				WHERE	Organization_Name LIKE '%Import Export%'
						AND Employee_Name LIKE '%Asmat%' 
			END
		ELSE
			BEGIN
			SET @Result = @GroupID 
			END
	END  
 END    
    
 IF @Type = 'Requestor'     
 BEGIN    
  SET @Result = @Creator    
 END    
    
 IF @Type IN ('Region Manager', 'Area Manager')    
 BEGIN    
  SET @Result = @BArea;    
 END    
    
 IF @Type = 'PPJK'    
 BEGIN    
  DECLARE @UserName nvarchar(100);    
  SELECT TOP 1 @UserName = Username FROM dbo.MasterAreaUserCKB where BAreaCode = @BArea AND IsActive = 1;    
  SELECT @Result = @UserName FROM PartsInformationSystem.dbo.UserAccess where UserID =  @UserName;    
 END     
    
 IF @Type = 'AreaCipl'    
 BEGIN    
  DECLARE @RequestorName nvarchar(50);    
  DECLARE @DataId bigint;    
  select @DataId = IdGr from dbo.RequestGr where Id = @IdRequest    
  select @Result = PickupPic FROM dbo.GoodsReceive where Id = @DataId;    
 END     
    
 RETURN @Result;    
    
END 

GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking]    Script Date: 10/03/2023 12:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetReportDetailTracking] ()
RETURNS TABLE
AS
RETURN (
		SELECT CONCAT (
				LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
				,'-'
				,DATEPART(YEAR, t0.UpdateDate)
				) PebMonth
			,CAST(ROW_NUMBER() OVER (
					PARTITION BY CONCAT (
						LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
						,'-'
						,DATEPART(YEAR, t0.UpdateDate)
						) ORDER BY t0.UpdateDate
					) AS VARCHAR(5)) RowNumber
			,IIF(t0.ReferenceNo = '', '-', t0.ReferenceNo) ReferenceNo
			, CCRNumber = STUFF((
			 SELECT ',' + tt.Ccr
				From ciplitem tt where tt.IdCipl = t0.id AND tt.IsDelete ='0' and tt.Ccr <> ''
				FOR XML PATH('')
			 ), 1, 1, '')
			,t0.CiplNo
			,t0.EdoNo AS EDINo
			,IIF(t0.PermanentTemporary = 'Repair Return (Temporary)', 'Temporary', IIF(t0.PermanentTemporary = 'Return (Permanent)', 'Permanent', IIF(t0.PermanentTemporary = 'Personal Effect (Permanent)', 'Permanent', 'Permanent'))) AS PermanentTemporary
			,IIF(t0.SalesNonSales <> 'Non Sales', IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, ' ', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))), t0.SalesNonSales) AS SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyName ELSE '' END AS NotifyName
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyAddress ELSE '' END AS NotifyAddress
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyCountry ELSE '' END AS NotifyCountry
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyTelephone ELSE '' END AS NotifyTelephone
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyFax ELSE '' END AS NotifyFax
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyPic ELSE '' END AS NotifyPic
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyEmail ELSE '' END AS NotifyEmail
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToName ELSE '' END AS SoldToName
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToAddress ELSE '' END AS SoldToAddress
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToCountry ELSE '' END AS SoldToCountry
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToTelephone ELSE '' END AS SoldToTelephone
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToFax ELSE '' END AS SoldToFax
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToPic ELSE '' END AS SoldToPic
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToEmail ELSE '' END AS SoldToEmail
			,t2.ShippingMethod
			,t2.Incoterms AS IncoTerms
			,IIF(t0.Category = 'MISCELLANEOUS', t0.CategoriItem, t0.Category) AS DescGoods
			,IIF(t0.Category = 'MISCELLANEOUS', t0.Category, IIF(t0.Category = 'CATERPILLAR SPAREPARTS', 'SPAREPARTS', t0.CategoriItem)) AS Category
			,IIF(t0.Category = 'MISCELLANEOUS'
				OR t0.Category = 'CATERPILLAR USED EQUIPMENT'
				OR t0.Category = 'CATERPILLAR UNIT', '-', t0.CategoriItem) AS SubCategory
			,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS
 [Type]
			,t0.UpdateDate AS CiplDate
			,CONCAT (
				CONVERT(VARCHAR(9), t0.UpdateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t0.UpdateDate, 8)
				) CiplCreateDate
			,t0.CiplApprovalDate
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PICApproverName
			,t0.GrNo AS RGNo
			,t0.RGDate
			,t0.RGApprovalDate
			,t0.RGApproverName
			,t0.CategoriItem
			,CONCAT (
				CONVERT(VARCHAR(18), t2.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(20), t2.CreateDate, 8)
				) ClDate
			,t2.ClNo
			,CONVERT(VARCHAR(11), t2.SailingSchedule, 106) AS ETD
			,CONVERT(VARCHAR(11), t2.ArrivalDestination, 106) AS ETA
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.CargoType
			,ContainerNumber = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,Seal = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerSealNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,'-' AS ContainerType
			,t7.TotalCaseNumber AS TotalColly
			,t2.Liner
			,IIF(t2.ShippingMethod = 'Sea', t2.VesselFlight, '') VesselName
			,IIF(t2.ShippingMethod = 'Air', t2.VesselFlight, '') FlightName
			,IIF(t2.ShippingMethod = 'Sea', t2.VoyageVesselFlight, '') VesselVoyNo
			,IIF(t2.ShippingMethod = 'Air', t2.VoyageVesselFlight, '') FlightVoyNo
			,t2.SsNo AS SSNo
			,t2.ClApprovalDate AS CLApprovalDate
			,t2.ClApproverName
			,t3.SlNo AS SINo
			,CONCAT (
				CONVERT(VARCHAR(9), t3.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t3.CreateDate, 8)
				) AS SIDate
			,CONCAT (
				CONVERT(VARCHAR(9), t4.AjuDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.AjuDate, 8)
				) AS AjuDate
			,t4.AjuNumber
			,CONCAT (
				CONVERT(VARCHAR(9), t4.NpeDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.NpeDate, 8)
				) AS NpeDate
			,t4.NpeNumber
			,t4.RegistrationNumber AS NOPEN
			,FORMAT(t4.PebFob, '#,0.00') PebFob
			,FORMAT(t4.FreightPayment, '#,0.00') FreightPyment
			,FORMAT(t4.InsuranceAmount, '#,0.00') InsuranceAmount
			,CONCAT (
				CONVERT(VARCHAR(9), t4.PEBApprovalDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.PEBApprovalDate, 8)
				) AS PEBApprovalDate
			,t4.PEBApproverName
			,t5.Number AS MasterBlAwbNumber
			,CONVERT(VARCHAR(10), t5.MasterBlDate, 120) AS MasterBlAwbDate
			,t5.HouseBlNumber HouseBlAwbNumber
			,CONVERT(VARCHAR(10), t5.HouseBlDate, 120) AS HouseBlAwbDate
			,FORMAT(t4.PebFob + t4.FreightPayment + t4.InsuranceAmount, '#,0.00') AS TotalPEB
			,'-' AS InvoiceNoServiceCharges
			,'-' AS CurrencyServiceCharges
			,'-' AS TotalServiceCharges
			,'-' AS InvoiceNoConsignee
			,'-' AS CurrencyValueConsignee
			,'-' AS TotalValueConsignee
			,'-' AS ValueBalanceConsignee
			,'-' AS [Status1]
			,Uom = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.Uom
						FROM CiplItem CI
						WHERE CI.IdCipl = t0.Id
							AND CI.Uom <> ''
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,t7.Quantity TotalUom
			,t7.TotalExtendedValue TotalExtendedValue
			,FORMAT(sum(ISNULL(t4.Rate, 0)), '#,0.00') Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,CASE 
				WHEN fnReqCl.StatusViewByUser IS NOT NULL
					AND fnReqCl.StatusViewByUser != 'Draft'
					THEN fnReqCl.StatusViewByUser
				WHEN fnReqGr.NextStatusViewByUser IS NOT NULL
					AND fnReqGr.NextStatusViewByUser != 'Draft'
					THEN fnReqGr.NextStatusViewByUser
				ELSE fnReq.NextStatusViewByUser
				END AS [Status]
		FROM (
			SELECT DISTINCT t0.CiplNo
				,t0.ReferenceNo
				,t0.Category
				,t0.CategoriItem
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateDate, t0.CreateDate) UpdateDate
				,t8.Employee_name PICName
				,t8.Dept_Name Department
				,t8.Division_Name Branch
				,t0.id
				,t0.EdoNo
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', t0.ExportType) > 0, 'Permanent', '-'), --'-',
					LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) AS PermanentTemporary
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) AS SalesNonSales
				,t0.ExportType
				,t0.Remarks
				,t0.ConsigneeName
				,t0.ConsigneeAddress
				,t0.ConsigneeCountry
				,t0.ConsigneeTelephone
				,t0.ConsigneeFax
				,t0.ConsigneePic
				,t0.ConsigneeEmail
				,t0.NotifyName
				,t0.NotifyAddress
				,t0.NotifyCountry
				,t0.NotifyTelephone
				,t0.NotifyFax
				,t0.NotifyPic
				,t0.NotifyEmail
				,t0.SoldToName
				,t0.SoldToAddress
				,t0.SoldToCountry
				,t0.SoldToTelephone
				,t0.SoldToFax
				,t0.SoldToPic
				,t0.SoldToEmail
				,t0.ShippingMethod
				,
				--t0.IncoTerm,
				CONCAT (
					CONVERT(VARCHAR(9), t4.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t4.UpdateDate, 8)
					) AS CiplApprovalDate
				,t6.Employee_Name AS PICApproverName
				,t3.GrNo
				,CONCAT (
					CONVERT(VARCHAR(9), t3.CreateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t3.CreateDate, 8)
					) AS RGDate
				,CONCAT (
					CONVERT(VARCHAR(9), t5.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t5.UpdateDate, 8)
					) AS RGApprovalDate
				,t7.Employee_Name AS RGApproverName
				,t3.Id IdGr
				,t0.ShipDelivery
			FROM Cipl t0
			JOIN CiplItem t1 ON t0.id = t1.idCipl AND t1.isdelete = 0
			LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id
				AND t4.STATUS = 'Approve' and t4.isdelete = 0
			LEFT JOIN GoodsReceiveItem t2 ON t2.IdCipl = t0.id AND t2.isdelete = 0
			LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr AND t3.isdelete = 0
			LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr
				AND t5.STATUS = 'Approve' AND t5.isdelete = 0
			LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy
			LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy	
			LEFT JOIN Employee t8 ON t8.AD_User = t0.UpdateBy
			WHERE t0.isdelete = 0
			) t0
		LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id AND t1.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name ClApproverName
				,
				--t1.UpdateBy ClApproverName, 
				CONCAT (
					CONVERT(VARCHAR(9), t1.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t1.UpdateDate, 8)
					) ClApprovalDate
			FROM Cargo t0
			--left join RequestCl t1 on t0.Id = t1.IdCl and t1.Status = 'Approve' and t1.IdStep = 12
			LEFT JOIN CargoHistory t1 ON t0.Id = t1.IdCargo
				AND t1.Step NOT IN (
					'Approve NPE & PEB'
					,'Approve BL or AWB'
					,'Create NPE & PEB'
					)
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t2 ON t2.Id = t1.IdCargo
		LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id AND t3.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name AS PEBApproverName
				,t1.UpdateDate AS PEBApprovalDate
			FROM NpePeb t0
			LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo
				AND t1.Step = 'Approve NPE & PEB'
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t4 ON t4.IdCl = t2.Id
		LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id AND t5.isdelete = 0
		LEFT JOIN (
			SELECT c.id
				,MAX(ISNULL(ci.Currency, '-')) AS Currency
				,CASE 
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'SIB'
						THEN CAST(count(DISTINCT ISNULL(ci.Id, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'PRA'
						THEN CAST(count(DISTINCT ISNULL(ci.ASNNumber, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'Old Core'
						THEN CAST(count(DISTINCT ISNULL(ci.CaseNumber, '-')) AS VARCHAR(5))
					ELSE CAST(count(DISTINCT ci.Sn) AS VARCHAR(5))
					END AS TotalCaseNumber
				,FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00') AS TotalExtendedValue
				,FORMAT(sum(ISNULL(ci.Quantity, 0)), '#,0.00') AS Quantity
			FROM Cipl c
			INNER JOIN CiplItem ci ON c.id = ci.IdCipl
			INNER JOIN CargoItem cai ON cai.IdCiplItem = ci.Id
			GROUP BY c.id
				,c.Category
				,c.CategoriItem
			) t7 ON t7.id = t0.id
		LEFT JOIN (
			SELECT FORMAT(sum(ISNULL(c.Gross, 0)), '#,0.00') Gross
				,FORMAT(sum(ISNULL(c.Net, 0)), '#,0.00') Net
				--,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0))/100, '#,0.00') AS Volume
				,FORMAT((SUM(ISNULL(c.Height,0))/100) * (SUM(ISNULL(c.Width,0))/100) * (SUM(ISNULL(c.Length,0))/100), '#,0.00') AS Volume
				,c.IdCargo
			FROM CargoItem c
			GROUP BY c.IdCargo
			) t8 ON t8.IdCargo = t1.IdCargo 
		LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr
		LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id
		GROUP BY t0.id
			,t0.UpdateDate
			,t0.CiplNo
			,t0.EdoNo
			,t0.ReferenceNo
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PermanentTemporary
			,t0.SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,t0.NotifyName
			,t0.NotifyAddress
			,t0.NotifyCountry
			,t0.NotifyTelephone
			,t0.NotifyFax
			,t0.NotifyPic
			,t0.NotifyEmail
			,t0.SoldToName
			,t0.SoldToAddress
			,t0.SoldToCountry
			,t0.SoldToTelephone
			,t0.SoldToFax
			,t0.SoldToPic
			,t0.SoldToEmail
			,t0.PICApproverName
			,t0.GrNo
			,t2.ClNo
			,t2.SsNo
			,t3.SlNo
			,t4.AjuDate
			,t4.AjuNumber
			,t4.NpeDate
			,t4.NpeNumber
			,t5.Number
			,t5.MasterBlDate
			,t5.HouseBlNumber
			,t5.HouseBlDate
			,t2.SailingSchedule
			,t2.ArrivalDestination
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.ShippingMethod
			,t2.CargoType
			,t2.Incoterms
			,t4.PebFob
			,t4.FreightPayment
			,t4.InsuranceAmount
			,t0.Category
			,t0.CategoriItem
			,t0.CiplApprovalDate
			,t0.RGApprovalDate
			,t0.RGDate
			,t2.CreateDate
			,t0.ExportType
			,t2.ClApprovalDate
			,t2.ClApproverName
			,t0.RGApproverName
			,t3.CreateDate
			,t4.RegistrationNumber
			,t4.PEBApproverName
			,t4.PEBApprovalDate
			,t2.VesselFlight
			,t2.VoyageVesselFlight
			,t2.Liner
			,t2.Id
			,t7.Quantity
			,t7.TotalCaseNumber
			,TotalExtendedValue
			,t4.Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,fnReq.NextStatusViewByUser
			,fnReqGr.NextStatusViewByUser
			,fnReqCl.StatusViewByUser
			,t0.ShipDelivery
		)



GO

/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                      
-- Author:                            Ali Mutasal                      
-- ALTER date: 09 Des 2019                      
-- Description:    Function untuk melakukan proses email                      
-- =============================================                      
CREATE FUNCTION [dbo].[fn_proccess_email_template]                      
(                      
    -- Add the parameters for the function here                      
    @requestType nvarchar(100) = '',                      
    @requestId nvarchar(100) = '',                      
    @template nvarchar(max) = '',                      
    @typeDoc nvarchar(max) = '',                      
    @lastPIC nvarchar(max) = ''                      
)                      
RETURNS nvarchar(max)                      
AS                      
BEGIN                      
    ------------------------------------------------------------------                      
    -- 1. Melakukan Declare semua variable yang dibutuhkan                      
    ------------------------------------------------------------------                      
    BEGIN                     
    -- ini hanya sample silahkan comment jika akan digunakan                      
    --SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';                      
    DECLARE @variable_table TABLE (                      
        key_data VARCHAR(MAX) NULL,                      
        val_data VARCHAR(MAX) NULL                      
    );                      
                      
    DECLARE                       
  @key NVARCHAR(MAX),                       
  @flow NVARCHAR(MAX),                       
  @val NVARCHAR(MAX),                      
  @requestor_name NVARCHAR(MAX),                      
  @requestor_id NVARCHAR(MAX),                      
  @requestor_username NVARCHAR(MAX),                      
  @last_pic_name NVARCHAR(MAX),                      
  @last_pic_id NVARCHAR(MAX),                      
  @last_pic_username NVARCHAR(MAX),                      
  @next_pic_name NVARCHAR(MAX),                      
  @next_pic_id NVARCHAR(MAX),                      
  @next_pic_username NVARCHAR(MAX),                      
  @si_number NVARCHAR(MAX) = '',                      
  @ss_number NVARCHAR(MAX) = '',                      
  @req_number NVARCHAR(MAX) = '',                      
  @CiplNo NVARCHAR(MAX) = '',                      
  @DO NVARCHAR(MAX) = '',                      
  @DA NVARCHAR(MAX) = '',                      
  @NoReference NVARCHAR(MAX) = '',                      
  @CIPLBranchName NVARCHAR(MAX) = '',                      
  @PICPickupPoints NVARCHAR(MAX) = '',                      
  @PickupPointsArea NVARCHAR(MAX) = '',                      
  @npe_number NVARCHAR(MAX) = '',      
  @npe_date NVARCHAR(MAX) = '',                  
  @peb_number NVARCHAR(MAX) = '',                      
  @bl_awb_number NVARCHAR(MAX) = '',                      
  @req_date NVARCHAR(MAX) = '',                      
  @superior_req_name nvarchar(max) = '',             
  @superior_req_id nvarchar(max) = '',                
  @Note nvarchar(max) = '',                
  @employee_name nvarchar(max) = '',  
  @AJU_Number NVARCHAR(MAX) = ''                      
                                  
    IF (@lastPIC <> '')                   
    BEGIN                      
        SELECT @employee_name = employee_name                       
        FROM dbo.fn_get_employee_internal_ckb()                       
        WHERE AD_User = @lastPIC;                      
    END                      
END                      
                                      
------------------------------------------------------------------                      
-- 2. Query untuk mengisi data ke variable variable yang dibutuhkan                      
------------------------------------------------------------------              
BEGIN                      
    -- Mengambil data dari fn request per flow                      
    BEGIN                      
  IF (@requestType = 'CIPL')                      
   BEGIN                      
   SET @flow = 'CIPL';                      
   SELECT                       
    @requestor_id = t1.Employee_ID,                      
    @requestor_name = t1.Employee_Name,                      
    @superior_req_name = t1.Superior_Name,                      
    @superior_req_id = t1.Superior_ID,                      
    @requestor_username = t1.AD_User,                      
    @last_pic_id = t2.Employee_ID,                      
    @last_pic_name = t2.Employee_Name,                      
    @last_pic_username = t2.AD_User,                      
    @next_pic_id = t3.Employee_ID,                      
    @DO = t4.EdoNo,              
    @CiplNo = t4.CiplNo,                      
    @DA = t4.Da ,                
    @Note = ISNULL((select TOP 1 notes from CiplHistory where IdCipl = t0.IdCipl order by id desc),''),            
    @NoReference = t4.ReferenceNo,                      
    @CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id=t0.IdCipl ),                      
    @PICPickupPoints = t6.Employee_Name,                      
    @PickupPointsArea = t4.PickUpArea+'-'+(SELECT MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id=t0.IdCipl ),                      
    @next_pic_name = CASE WHEN t0.Status = 'Revise' OR t0.Status = 'Reject' OR (t0.Status = 'Approve' AND t0.NextAssignType IS NULL) THEN t5.Employee_Name     
    WHEN t0.NextAssignType = 'Group' THEN t0.NextAssignTo  ELSE t3.Employee_Name END,                      
                @next_pic_username = t3.AD_User,                      
    @req_number = IIF(@typeDoc = 'CKB', ISNULL(t4.EdoNo,''), t4.CiplNo),                      
                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)                      
            FROM                       
    dbo.fn_get_cipl_request_list_all() t0                       
    INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl                      
    LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.UpdateBy                
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t4.PickUpPic                
            WHERE                       
                t0.IdCipl = @requestId;                      
   END                      
                      
        --IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))                      
  IF (@requestType = 'CL') OR (@requestType = 'BLAWB') OR (@requestType = 'PEB_NPE')                       
   BEGIN                      
   SET @flow = @requestType;                      
   SELECT                       
        @requestor_id = t5.Employee_ID,                      
        @requestor_name = t5.Employee_Name,                      
        @superior_req_name = t5.Superior_Name,                      
        @superior_req_id = t5.Superior_ID,                      
        @requestor_username = t5.AD_User,                      
        @last_pic_id = t6.Employee_ID,                      
        @last_pic_name = t6.Employee_Name,                      
  @last_pic_username = t6.AD_User,                      
  @next_pic_id = t7.Employee_ID,                      
  @next_pic_name = t7.Employee_Name,                      
  @next_pic_username = t7.AD_User,                      
  @req_number = t1.ClNo,                      
        @ss_number = t1.SsNo,                      
        @si_number = t2.SlNo,                      
        @npe_number = t3.NpeNumber,                      
        @peb_number = t3.PebNumber,       
        @NoReference = (SELECT        
    STUFF((        
    SELECT DISTINCT ', ' + ReferenceNo        
    FROM Cipl WHERE id                       
     in (SELECT IdCipl FROM CargoCipl                       
     where IdCargo = t0.IdCl)        
    FOR XML PATH('')), 1, 1, '')),      
    --          @DO = (SELECT        
    --STUFF((        
    --SELECT ', ' + EdoNumber        
    --FROM CargoCipl WHERE IdCargo = t0.IdCl        
    --FOR XML PATH('')), 1, 1, '')),        
  @DO = (SELECT              
     STUFF((              
     SELECT ', ' + DoNo           
     FROM ShippingFleetRefrence WHERE IdCipl                               
   in (SELECT IdCipl FROM CargoCipl                             
   where IdCargo = t0.IdCl)              
     FOR XML PATH('')), 1, 1, '')),                     
        @CIPLBranchName = (SELECT STUFF((        
    SELECT DISTINCT', ' + C.Branch+' - '+MA.BAreaName FROM MasterArea MA       
    inner join Cipl C ON C.Branch = MA.BAreaCode       
    WHERE C.id in (SELECT IdCipl FROM CargoCipl                       
    where IdCargo = t0.IdCl)        
    FOR XML PATH('')), 1, 1, '')),                      
    --DA = (SELECT        
    --STUFF((        
    --SELECT ', ' + Da        
    --FROM Cipl WHERE id                       
    -- in (SELECT IdCipl FROM CargoCipl                       
    -- where IdCargo = t0.IdCl)        
    --FOR XML PATH('')), 1, 1, '')),       
  @DA = (SELECT              
   STUFF((SELECT ', ' + sf.DaNo from shippingfleet sf      
   Inner join ShippingFleetRefrence sfr on sfr.IdShippingFleet = sf.Id      
   inner join CargoCipl cc on cc.IdCipl = sfr.IdCipl      
   where cc.IdCargo = t0.IdCl      
   FOR XML PATH('')), 1, 1, '')),                  
        @CiplNo = (SELECT        
    STUFF((        
      SELECT ', ' + CiplNo        
      FROM Cipl WHERE id                       
    in (SELECT IdCipl FROM CargoCipl                       
    where IdCargo = t0.IdCl)        
      FOR XML PATH('')), 1, 1, '')),                      
  @bl_awb_number = t4.Number,                      
        @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate),  
  @AJU_Number = t3.AjuNumber,  
  @npe_date = t3.NpeDate  
    FROM                       
        dbo.fn_get_cl_request_list_all() t0                       
        INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl                
        LEFT JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl                      
        LEFT JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl                      
        LEFT JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl                
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy                      
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic                      
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo                      
   WHERE                       
                t0.IdCl = @requestId;                                                                                           
            END                      
                      
        IF (@requestType = 'RG')                      
   BEGIN                      
            SET @flow = 'Receive Goods';                      
            SELECT                    
   --@DO = (SELECT        
   --  STUFF((        
   --  SELECT ', ' + EdoNo        
   --  FROM Cipl WHERE id= gt.IdCipl        
   --  FOR XML PATH('')), 1, 1, '')),       
   @DO = (SELECT        
     STUFF((        
     SELECT ', ' + DoNo     
     FROM ShippingFleet WHERE IdGr = t0.IdGr        
     FOR XML PATH('')), 1, 1, '')),                 
   --@CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id = gt.IdCipl),      
   @CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName     
    FROM MasterArea MA     
    inner join Cipl C ON C.Branch = MA.BAreaCode     
    WHERE EdoNo IN (    
    SELECT DoNo    
    FROM ShippingFleet    
    WHERE IdGr = sf.IdGr)),                    
   @DA = (SELECT        
     STUFF((        
     SELECT ', ' + DaNo     
     FROM ShippingFleet WHERE IdGr = t0.IdGr     
     FOR XML PATH('')), 1, 1, '')),    
   --@DA = (SELECT        
   --  STUFF((        
   --  SELECT ', ' + Da        
   --  FROM Cipl     
   --  WHERE id = gt.IdCipl        
   --  FOR XML PATH('')), 1, 1, '')),                      
   @CiplNo = (SELECT        
      STUFF((        
      SELECT DISTINCT ', ' + CiplNo        
      FROM Cipl WHERE EdoNo IN (    
      SELECT DoNo    
      FROM ShippingFleet    
      WHERE IdGr = sf.IdGr)    
      FOR XML PATH('')), 1, 1, '')),       
   @NoReference = (SELECT        
    STUFF((        
    SELECT DISTINCT ', ' + ReferenceNo        
    FROM Cipl WHERE EdoNo IN (    
    SELECT DoNo    
    FROM ShippingFleet    
    WHERE IdGr = sf.IdGr)    
    FOR XML PATH('')), 1, 1, '')),    
   @requestor_id = t1.Employee_ID,                      
   @requestor_name = t1.Employee_Name,                      
   @superior_req_name = t1.Superior_Name,                      
   @superior_req_id = t1.Superior_ID,                      
   @requestor_username = t1.AD_User,                      
   @last_pic_id = t2.Employee_ID,                      
   @last_pic_name = t2.Employee_Name,                      
   @last_pic_username = t2.AD_User,                      
   @next_pic_id = t3.Employee_ID,                      
   @next_pic_name = t3.Employee_Name,                      
   @next_pic_username = t3.AD_User,                      
   @req_number = t4.GrNo,                      
   @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)                      
  FROM                       
            dbo.fn_get_gr_request_list_all() t0                       
   INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr           
   --LEFT JOIN GoodsReceiveItem gt on gt.IdGr = t0.IdGr       
   LEFT JOIN ShippingFleet sf on sf.IdGr = t0.IdGr       
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy                      
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic                      
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo                   
  WHERE                
   t0.IdGr = @requestId;                      
        END                      
                      
        IF (@requestType = 'DELEGATION')                      
  BEGIN                      
    SET @flow = 'Delegation';                                                                  --SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;                      
  END                      
                      
            INSERT INTO  @variable_table                       
            VALUES                       
            ('@RequestorName', ISNULL(@requestor_name, '-'))                      
            ,('@RequestNo', ISNULL(@req_number, '-'))                      
            ,('@CreatedDate', ISNULL(@req_date, '-'))                      
            ,('@CiplNo', ISNULL(@CiplNo, '-'))                      
            ,('@CIPLBranchName', ISNULL(@CIPLBranchName, '-'))                      
            ,('@PICPickupPoints', ISNULL(@PICPickupPoints, '-'))                      
            ,('@DO', ISNULL(@DO, '-'))                      
            ,('@DA', ISNULL(@DA, '-'))                      
            ,('@PickupPointsArea', ISNULL(@PickupPointsArea, '-'))                      
   ,('@SuperiorEmpID', ISNULL(@superior_req_id, '-'))                      
   ,('@SuperiorName', ISNULL(@superior_req_name, '-'))                      
   ,('@MobileLink', 'http://pis.trakindo.co.id')                    
   ,('@DesktopLink', 'http://pis.trakindo.co.id')                      
   ,('@ApproverPosition', ISNULL(@flow, '-'))                      
   ,('@ApproverName', ISNULL(@next_pic_name, ISNULL(@employee_name,'-')))        
   ,('@RequestorEmpID', ISNULL(@requestor_id, '-'))                      
   ,('@flow', ISNULL(@flow, '-'))                      
            ,('@NoReference', ISNULL(@NoReference, '-'))                      
   ,('@requestor_name', ISNULL(@requestor_name, '-'))                      
            ,('@requestor_id', ISNULL(@requestor_id, '-'))                      
            ,('@last_pic_name', ISNULL(@last_pic_name, '-'))                      
            ,('@last_pic_id', ISNULL(@last_pic_id, '-'))                      
            ,('@next_pic_name', ISNULL(@next_pic_name, '-'))                      
            ,('@next_pic_id', ISNULL(@next_pic_id, '-'))                      
            ,('@si_number', ISNULL(@si_number, '-'))                      
   ,('@ss_number', ISNULL(@ss_number, '-'))                      
            ,('@req_number', ISNULL(@req_number, '-'))                      
            ,('@npe_number', ISNULL(@npe_number, '-'))    
   ,('@npe_date', ISNULL(@npe_date, '-'))                    
            ,('@peb_number', ISNULL(@peb_number, '-'))                      
            ,('@bl_awb_number', ISNULL(@bl_awb_number, '-'))                      
            ,('@req_date', ISNULL(@req_date, '-'))                      
            ,('@superior_req_name', ISNULL(@superior_req_name, '-'))                      
            ,('@superior_req_id', ISNULL(@superior_req_id, '-'))            
            ,('@Note', ISNULL(@Note, '-'))  
   ,('@AJU_Number', ISNULL(@AJU_Number, '-'))   
 END                      
END                      
                                      
------------------------------------------------------------------                      
-- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan                      
------------------------------------------------------------------                      
BEGIN                      
    DECLARE cursor_variable CURSOR                      
    FOR                       
    SELECT                       
        key_data,              
        val_data                       
    FROM                       
        @variable_table;                      
                                                                                                                      
    OPEN cursor_variable;                       
    FETCH NEXT FROM cursor_variable INTO @key, @val;                       
    WHILE @@FETCH_STATUS = 0                      
        BEGIN                      
        -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.                      
        IF ISNULL(@key, '') <> ''                      
        BEGIN                      
  SET @template = REPLACE(@template, @key, @val);                      
        END                      
                      
    FETCH NEXT FROM cursor_variable INTO                       
                @key,                       
                @val;                      
        END;                      
                                                      
    CLOSE cursor_variable;                       
    DEALLOCATE cursor_variable;                      
END                      
                                      
------------------------------------------------------------------                      
-- 4. Menampilkan hasil dari proses replace                      
------------------------------------------------------------------                      
BEGIN                      
    RETURN @template;                      
END                      
END 
GO
