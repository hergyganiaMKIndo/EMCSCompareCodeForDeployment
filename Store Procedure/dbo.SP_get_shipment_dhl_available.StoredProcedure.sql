USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_get_shipment_dhl_available]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_get_shipment_dhl_available]		---- SP_get_cipl_available '', '1', '1' select * from dbo.Cipl
(
	@Search nvarchar(100) = '',
	@CiplList nvarchar(max) = '',
	@AwbId nvarchar(10) = '0',
	@ConsigneePic nvarchar(max) = '',
	@ConsigneeName nvarchar(max) = '',
	@ConsigneeTelephone nvarchar(max) = '',
	@ConsigneeEmail nvarchar(max) = '',
	@ConsigneeAddress nvarchar(max) = '',
	@ConsigneeCountry nvarchar(max) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(max);
	Declare @CiplExisting table (CiplId bigint);
	Declare @tblMaster table (
		id bigint,
		CiplNo varchar(50), 
		ConsigneeName varchar(150), 
		ConsigneeAddress varchar(max), 
		ConsigneeCountry varchar(150), 
		ConsigneeTelephone varchar(150), 
		ConsigneePic varchar(150), 
		ConsigneeEmail varchar(150) 
	);

	Declare @tblMaster2 table (
		id bigint,
		CiplNo varchar(50), 
		ConsigneeName varchar(150), 
		ConsigneeAddress varchar(max), 
		ConsigneeCountry varchar(150), 
		ConsigneeTelephone varchar(150), 
		ConsigneePic varchar(150), 
		ConsigneeEmail varchar(150),
		StatusViewUser varchar(100)
	);

	--SELECT c.Id, 
	--	c.CiplNo, 
	--	c.ConsigneeName, 
	--	c.ConsigneeAddress, 
	--	c.ConsigneeCountry, 
	--	c.ConsigneeTelephone, 
	--	c.ConsigneePic, 
	--	c.ConsigneeEmail 
	--FROM cipl c
	--JOIN requestcipl rc on rc.idcipl = c.id AND rc.isdelete = 0
	--WHERE c.isdelete = 0 AND rc.idstep = 10 and rc.status = 'Approve'

	SET @sql = 'SELECT c.Id, 
		c.CiplNo, 
		c.ConsigneeName, 
		c.ConsigneeAddress, 
		c.ConsigneeCountry, 
		c.ConsigneeTelephone, 
		c.ConsigneePic, 
		c.ConsigneeEmail 
	FROM cipl c
	JOIN requestcipl rc on rc.idcipl = c.id AND rc.isdelete = 0
	WHERE c.isdelete = 0 AND rc.idstep = 10 and rc.status = ''Approve'' ';

	SET @sql =	@sql + CASE WHEN ISNULL(@Search, '') <> '' THEN 'AND c.CiplNo like ''%'+@Search+'%''' ELSE '' END +
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeName like ''%'+@ConsigneeName+'%''' ELSE '' END +
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeAddress like ''%'+@ConsigneeAddress+'%''' ELSE '' END +  
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeCountry like ''%'+@ConsigneeCountry+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeTelephone like ''%'+@ConsigneeTelephone+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneePic like ''%'+@ConsigneePic+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeEmail like ''%'+@ConsigneeEmail+'%''' ELSE '' END 

	----# Get Data Master
	--print @sql
	Insert into @tblMaster
	EXECUTE(@sql);


	----# Get Status Cipl (Only Waiting for Pickup Goods)
	Insert into @tblMaster2
	Select a.*
		 , StatusViewUser = Case when c.NextStatusViewByUser = 'Pickup Goods'
								 Then
									Case When (e.Status='DRAFT') OR (c.Status='APPROVE' AND (e.Status is null OR e.Status = 'Waiting Approval') AND b.Status = 'APPROVE') 
										 Then 'Waiting for Pickup Goods'
									Else '-' End
							Else '-' End
	From @tblMaster a
	Left Join Requestcipl b with(nolock) on a.id = b.IdCipl and b.IsDelete=0
	Left Join [fn_get_cipl_request_list_all]() c on b.id = c.Id
	Left Join GoodsReceiveItem d with(nolock) on a.id = d.IdCipl and d.IsDelete=0
	Left Join [fn_get_gr_request_list_all]() e on d.IdGr = e.IdGr

	
	Insert into @CiplExisting
	Select Distinct CiplID = a.item 
	From(
		SELECT a.DHLShipmentID, x.item
		FROM(
			select DHLShipmentID, Referrence
			from DHLShipment
			where IsDelete = 0
		)a
		CROSS APPLY dbo.FN_SplitStringToRows(a.Referrence, ',') as x
	)a


	Select a.* 
	From @tblMaster2 a
	Left Join @CiplExisting b on a.id=b.CiplId
	Where a.StatusViewUser='Waiting for Pickup Goods' And b.ciplid is NULL
END
GO
