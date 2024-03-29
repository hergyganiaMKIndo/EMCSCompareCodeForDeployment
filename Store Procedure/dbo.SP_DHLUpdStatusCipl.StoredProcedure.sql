USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLUpdStatusCipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_DHLUpdStatusCipl]
@DHLShipmentID bigint
, @Type varchar(50)
, @UserId varchar(50)

As
Set Nocount On

------# TRACE
----Declare @DHLShipmentID bigint = 70057
----, @Type varchar(50)
----, @UserId varchar(50)


Declare @CiplExisting table (pkid bigint, CiplId bigint, DoNo varchar(100));
Declare @IdStepUpd bigint;

IF @Type = 'ONPROGRESS'
BEGIN
	Set @IdStepUpd = 30073;
END
ELSE IF @Type = 'FINISH'
BEGIN
	Set @IdStepUpd = 30074;
END
ELSE
BEGIN
	Set @IdStepUpd = 0;
END


----#1 Get CiplId
Insert into @CiplExisting
Select pkid = ROW_NUMBER()Over(Partition by CiplID Order by CiplID), CiplID, b.EdoNo
From
(
	Select Distinct CiplID = a.item 
	From(
		SELECT a.DHLShipmentID, x.item
		FROM(
			select DHLShipmentID, Referrence
			from DHLShipment
			where IsDelete = 0 and DHLShipmentID = @DHLShipmentID
		)a
		CROSS APPLY dbo.FN_SplitStringToRows(a.Referrence, ',') as x
	)a
)a
Left Join Cipl b on a.CiplID = b.id and b.IsDelete = 0

----select * from @CiplExisting

IF Exists (Select Top 1 * From @CiplExisting)
BEGIN
	IF @Type = 'ONPROGRESS'
	BEGIN
		Update A
			Set IdStep = @IdStepUpd
		From RequestCipl A
		Where A.IdCipl IN ( Select CiplId From @CiplExisting )
		And IsDelete = 0
	END
	ELSE IF @Type = 'FINISH'
	BEGIN
		Update A
			Set IdStep = @IdStepUpd
		From RequestCipl A
		Where A.IdCipl IN ( Select CiplId From @CiplExisting )
		And IsDelete = 0
		And IdStep = 30073
	END	
END


/*
	Declare @IDGR bigint, @TrxDate date
	Select @TrxDate = CONVERT(date, GETDATE())

	EXEC @IDGR = [dbo].[sp_insert_update_gr]
		@Id = 0,
		@PicName = @UserId,
		@KtpName = '-',
		@PhoneNumber = '',
		@SimNumber = '',
		@StnkNumber = '',
		@NopolNumber = '',
		@EstimationTimePickup = '',
		@Notes = '',
		@Vendor = '',
		@KirNumber = '',
		@KirExpire = '',
		@Apar = '',
		@Apd = '',
		@VehicleType = '',
		@VehicleMerk = '',
		@CreateBy = 'SYSTEM',
		@CreateDate = @TrxDate,
		@UpdateBy = NULL,
		@UpdateDate = NULL,
		@IsDelete = 0,
		@SimExpiryDate = NULL,
		@ActualTimePickup = NULL,
		@Status = 'Submit',
		@PickupPoint = NULL,
		@PickupPic = NULL


	Declare @Min int, @Max int
	Select @Min = MIN(PKID), @Max = MAX(pkid) From @CiplExisting
	While @Min <= @Max
	Begin
		Declare @CiplIDCurrent bigint, @DoNoCurrent varchar(100)
		Select @CiplIDCurrent = CiplId, @DoNoCurrent = DoNo From @CiplExisting Where pkid = @Min
	
		EXEC [dbo].[sp_insert_update_gr_item]
			@Id = 0,
			@IdCipl = @CiplIDCurrent,
			@IdGr = @IDGR,
			@DoNo = @DoNoCurrent,
			@DaNo = '',
			@FileName = '',
			@CreateBy = 'SYSTEM',
			@CreateDate = @TrxDate,
			@UpdateBy = NULL,
			@UpdateDate = NULL,
			@IsDelete = 0

		Set @Min = @Min + 1
	End
*/
GO
