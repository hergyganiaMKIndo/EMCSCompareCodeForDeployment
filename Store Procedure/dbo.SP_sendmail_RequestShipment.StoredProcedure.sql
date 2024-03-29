USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_sendmail_RequestShipment]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_sendmail_RequestShipment] 
@DHLShipmentID bigint,
@UserId varchar(50)
	
AS
BEGIN
SET NOCOUNT ON
	
	-------#TRACE
	--Declare @DHLShipmentID bigint = 70057
	--	  , @userid varchar(50) = 'tes'

		--select * from DHLShipment order by CreateDate desc
		--select * from DhlPerson
		--select * from DHLPackage where DHLShipmentID=70057

	----#1 Inisiasi var
	Declare @body nvarchar(max), @Subject varchar(200), @StatusError varchar(100)
	Declare @AWBNumber varchar(50), @ConfirmationNumber varchar(50), @UserCreateID varchar(50), @UserCreateName varchar(50), @ShipperName varchar(50), @ShipperEmail varchar(50)
		  , @CiplId varchar(100), @CiplNo varchar(150)
	Declare @RecipientName varchar(100), @RecipientCompany varchar(100), @RecipientPhone varchar(100), @RecipientEmail varchar(100), @RecipientStreetlines varchar(max), @RecipientCity varchar(100)
	Declare @ShipmentLength decimal(18,2), @ShipmentWidth decimal(18,2), @ShipmentHeight decimal(18,2), @ShipmentWeight decimal(18,2), @ShipmentPackagesQty int, @ShipmentUnitPrice decimal(18,2)
		  , @ShipmentPickupDatetime varchar(16), @ShipmentLocation varchar(100)
	Declare @TblCiplNo table (CiplNo varchar(100))
	
	Select @AWBNumber = ISNULL(IdentifyNumber, ''), @ConfirmationNumber = ISNULL(ConfirmationNumber, ''), @UserCreateID = isnull(CreateBy, ''), @CiplId = ISNULL(Referrence, ''), @ShipmentPackagesQty = PackagesCount
		 , @ShipmentUnitPrice = PackagesPrice, @ShipmentLocation = ISNULL(PickupLocation, ''), @ShipmentPickupDatetime = CONVERT(varchar(10), ShipTimestamp, 120) + ' ' + PickupLocTime
	From DHLShipment 
	Where DHLShipmentID = @DHLShipmentID

	Select @ShipmentWidth = SUM([Width]), @ShipmentLength = SUM([Length]), @ShipmentHeight = SUM(Height), @ShipmentWeight = SUM([Weight])
	From DHLPackage
	Where DHLShipmentID = @DHLShipmentID 
		  AND IsDelete = 0

	Select @ShipperName = ISNULL(PersonName, ''), @ShipperEmail = ISNULL(EmailAddress, '')
	From DHLPerson 
	Where DHLShipmentID = @DHLShipmentID 
		  AND PersonType = 'SHIPPER' 
		  AND IsDelete = 0

	Select @RecipientName = ISNULL(PersonName, ''), @RecipientCompany = ISNULL(CompanyName, ''), @RecipientPhone = ISNULL(PhoneNumber, ''), @RecipientEmail = ISNULL(EmailAddress, '')
		 , @RecipientStreetlines = ISNULL(StreetLines, ''), @RecipientCity = ISNULL(City, '') + ', ' + ISNULL(PostalCode, '')
	From DHLPerson
	Where DHLShipmentID = @DHLShipmentID 
		  AND PersonType = 'RECIPIENT' 
		  AND IsDelete = 0	

	----# Get CiplNo
	Insert into @TblCiplNo
	Select CiplNo
	From Cipl 
	Where id in ( Select Item From dbo.FN_SplitStringToRows(@CiplId, ',') )

	Select @CiplNo = ISNULL(CiplNolist, '')
	From
	(
		select distinct  
		stuff
		(
			(
				select ', ' + u.CiplNo
				from @TblCiplNo u
				where u.CiplNo = CiplNo
				order by u.CiplNo
				for xml path('')
			),1,1,''
		) as CiplNolist
		from @TblCiplNo
		group by CiplNo
	)a

	Select @UserCreateName = ISNULL(FullName, '') 
	From [PartsInformationSystem].[dbo].[UserAccess] with(nolock) 
	Where UserID = @UserCreateID

	--select @AWBNumber '@AWBNumber', @ShipperName '@ShipperName', @UserCreateID '@UserCreateID', @UserCreateName '@UserCreateName', @ConfirmationNumber '@ConfirmationNumber', @CiplNo '@CiplNo', @RecipientName '@RecipientName'
	--	 , @RecipientCompany '@RecipientCompany', @RecipientPhone '@RecipientPhone', @RecipientEmail '@RecipientEmail', @RecipientStreetlines '@RecipientStreetlines', @RecipientCity '@RecipientCity'
	--	 , @ShipmentLength '@ShipmentLength', @ShipmentWidth '@ShipmentWidth', @ShipmentHeight '@ShipmentHeight', @ShipmentWeight '@ShipmentWeight', @ShipmentPackagesQty '@ShipmentPackagesQty', @ShipmentUnitPrice '@ShipmentUnitPrice'
	--	 , @ShipmentPickupDatetime '@ShipmentPickupDatetime', @ShipmentLocation '@ShipmentLocation'

	Set @Subject = 'DHL Express Shipment Confirmation ['+ @AWBNumber +']'

	
	 SET @body ='<p>Dear Mr/Mrs ' + @ShipperName + '<br /><br />
					A DHL Express shipment has been created by  ' + @UserCreateName + '. Please print the enclosed shipment paperwork and attach it to your shipment. <br /><br />
					
					<table style="width: 100%; border: none;">
						<tbody>
							<tr>
								<td style="width: 20%;">Pickup Confirmation Number</td>
								<td style="width: 1%;">:</td>
								<td style="width: 79%;">' + @ConfirmationNumber + '</td>
							</tr>
							<tr>
								<td>Refer to CIPL No</td>
								<td>:</td>
								<td>' +@CiplNo+ '</td>
							</tr>
						</tbody>
					</table>
					<br /><br />

					<table style="width: 90%; border: none;">
						<tbody>
							<tr>
								<td style="background-color: #cbcaf4;">&nbsp;&nbsp;<b>Recipient</b></td>
								<td></td>
								<td></td>
								<td style="background-color: #cbcaf4;">&nbsp;&nbsp;<b>Shipment Info</b></td>
								<td></td>
								<td></td>
							</tr>
							<tr>
								<td style="width: 11%;">Name</td>
								<td style="width: 1%;">:</td>
								<td style="width: 30%;">' + @RecipientName + '</td>
								<td style="width: 17%;">AWB No</td>
								<td style="width: 1%;">:</td>
								<td style="width: 40%;">' + @AWBNumber + '</td>
							</tr>
							<tr>
								<td>Company</td>
								<td>:</td>
								<td>' + @RecipientCompany + '</td>
								<td>Length</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentLength) + '</td>
							</tr>
							<tr>
								<td>Phone</td>
								<td>:</td>
								<td>' + @RecipientPhone + '</td>
								<td>Width</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentWidth) + '</td>
							</tr>
							<tr>
								<td>Email</td>
								<td>:</td>
								<td>' + @RecipientEmail + '</td>
								<td>Height</td>
								<td>:</td>
								<td>' + ISNULL(Convert(varchar, @ShipmentHeight), '') + '</td>
							</tr>
							<tr>
								<td>Street Lines</td>
								<td>:</td>
								<td>' + @RecipientStreetlines + '</td>
								<td>Weight</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentWeight) + '</td>
							</tr>
							<tr>
								<td>City</td>
								<td>:</td>
								<td>' + @RecipientCity + '</td>
								<td>Total Package / Collies</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentPackagesQty) + '</td>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Total Unit Price</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentUnitPrice) + '</td>
							</tr>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Date / Time Pickup</td>
								<td>:</td>
								<td>' + @ShipmentPickupDatetime + '</td>
							</tr>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Pickup Location</td>
								<td>:</td>
								<td>' + @ShipmentLocation + '</td>
							</tr>
						</tbody>
					</table>
					
					<br /><br />
					Thank you. <br />
				 </p>'

	--Print (@body);
		
	if isnull(@ShipperName, '') <> ''
	begin
		BEGIN TRY
			BEGIN TRANSACTION;

			EXEC msdb.dbo.sp_send_dbmail	
				@profile_name = 'EMCS',  
				@recipients = 'ict.bpm@trakindo.co.id',	--@ShipperName, 
				@copy_recipients = '',
				@body = @body,  
				@subject = @subject,
				@blind_copy_recipients = 'hidayat@iforce.co.id',
				@body_format = 'HTML';
			
			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			BEGIN
				Set @StatusError = 'Failed'
			END
		END CATCH;

		--Print @StatusError + ' - ' + isnull(@to_string, '')

		----Insert into LogEmail (IdEmail, InnovationId, [From], [To], Cc, [Subject], Body, [Status], IsActive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
		----select IdEmail=NULL, InnovationId=@innovationid, [From]='"Innovation Notification" <noreply@trakindo.co.id>', [To]=@to_string, Cc=@cc_string
		----	, [Subject]=@subject, Body=@body, [Status]=@StatusError, IsActive=1, CreatedBy=@usercreate, CreatedDate=GETDATE(), UpdatedBy=null, UpdatedDate=null
	end
END
GO
