USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[get_status]    Script Date: 10/03/2023 12:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_status] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export') 
(	
	-- Add the parameters for the function here
	@idcipl int
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
					 Select Distinct RC.IdCipl,  CASE					
									WHEN fnreq.NextStatusViewByUser ='Pickup Goods'
									 THEN
										  CASE WHEN 
										  (fnReqGr.Status='DRAFT') OR (fnReq.Status='APPROVE' AND (fnReqGr.Status is null OR fnReqGr.Status = 'Waiting Approval') AND RC.Status ='APPROVE') 
												THEN 'Waiting for Pickup Goods'
											WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status ='Submit' OR fnReqGr.Status ='APPROVE' ) AND (fnReqCl.Status is Null OR (fnReqCl.Status='Submit' AND fnReqCl.IdStep != 10017)))
												THEN 'On process Pickup Goods'
											WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep not in (10022))
												THEN 'Preparing for export'
											WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 10022)
												THEN 'Finish'	
											END			
											WHEN fnReq.Status ='Reject'
											THEN 'Reject'
									WHEN fnReq.NextStatusViewByUser = 'Waiting for superior approval'
										THEN fnReq.NextStatusViewByUser +' ('+ emp.Employee_Name +')'
									WHEN fnReq.Status ='Reject'
									THEN 'Reject'
									ELSE fnReq.NextStatusViewByUser 
									 END AS [StatusViewByUser]
									FROM dbo.Cipl C		
						INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id 
						--INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
						INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.IdCipl = C.id 
						LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id AND GR.isdelete = 0
						LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id AND CC.Isdelete = 0
						LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = GR.IdGr
						LEFT JOIN dbo.[fn_get_cl_request_list_all]() as fnReqCl on fnReqCl.IdCl = CC.IdCargo
						left join employee emp on emp.AD_User = fnReq.NextAssignTo 
		
	
	) as tab0 
	WHERE (tab0.IdCipl = @idcipl)
)



GO
