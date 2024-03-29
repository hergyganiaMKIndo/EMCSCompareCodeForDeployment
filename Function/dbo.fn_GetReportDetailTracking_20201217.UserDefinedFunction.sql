USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking_20201217]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_GetReportDetailTracking_20201217] ()
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
			,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS [Type]
			,t0.UpdateDate AS CiplDate
			,CONCAT (
				CONVERT(VARCHAR(9), t0.UpdateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t0.UpdateDate, 8)
				) CiplCreateDate
			,t0.CiplApprovalDate
			,t0.PICName
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
			,t4.Rate
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
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateBy, t0.CreateBy) PICName
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
			JOIN CiplItem t1 ON t0.id = t1.idCipl
			LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id
				AND t4.STATUS = 'Approve'
			LEFT JOIN GoodsReceiveItem t2 ON t2.IdCipl = t0.id
			LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr
			LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr
				AND t5.STATUS = 'Approve'
			LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy
			LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy
			) t0
		LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id
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
					)
				AND t1.STATUS = 'Approve'
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			) t2 ON t2.Id = t1.IdCargo
		LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name AS PEBApproverName
				,t1.UpdateDate AS PEBApprovalDate
			FROM NpePeb t0
			LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo
				AND t1.Step = 'Approve NPE & PEB'
				AND t1.STATUS = 'Approve'
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			) t4 ON t4.IdCl = t2.Id
		LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id
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
				,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0)), '#,0.00') AS Volume
				,c.IdCargo
			FROM CargoItem c
			GROUP BY c.IdCargo
			) t8 ON t8.IdCargo = t2.Id
		LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr
		LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id
		GROUP BY t0.id
			,t0.UpdateDate
			,t0.CiplNo
			,t0.EdoNo
			,t0.ReferenceNo
			,t0.PICName
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
