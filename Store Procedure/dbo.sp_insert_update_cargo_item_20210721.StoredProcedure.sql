USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_container
CREATE PROCEDURE [dbo].[sp_insert_update_cargo_item_20210721] 
(
	@Id nvarchar(100),
	@ItemId nvarchar(100),
	@IdCargo nvarchar(100),
	@ContainerNumber nvarchar(100),
	@ContainerType nvarchar(100),
	@ContainerSealNumber nvarchar(100),
	@ActionBy nvarchar(100),
	@Length nvarchar(100) = '0',
	@Width nvarchar(100) = '0',
	@Height nvarchar(100) = '0',
	@GrossWeight nvarchar(100) = '0',
	@NetWeight nvarchar(100) = '0',
	@isDelete bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[CargoItem]
		       ([ContainerNumber]
		       ,[ContainerType]
		       ,[ContainerSealNumber]
		       ,[IdCipl]
		       ,[IdCargo]
			   ,[IdCiplItem]
		       ,[InBoundDa]
		       ,[Length]
		       ,[Width]
		       ,[Height]
		       ,[Net]
		       ,[Gross]
		       ,[CreateBy]
		       ,[CreateDate]
		       ,[UpdateBy]
		       ,[UpdateDate]
		       ,[isDelete])
		 select 
			@ContainerNumber
			, @ContainerType
			, @ContainerSealNumber
			, t0.IdCipl
			, @IdCargo
			, t0.Id
			, t2.DaNo
			, t0.[Length]
			, t0.Width
			, t0.Height
			, t0.NetWeight
			, t0.GrossWeight
			, @ActionBy CreateBy
			, GETDATE()
			, @ActionBy UpdateBy
			, GETDATE(), 0
		 from dbo.ciplItem t0 
		 join dbo.Cipl t1 on t1.id = t0.IdCipl 
		 join dbo.GoodsReceiveItem t2 on t2.DoNo = t1.EdoNo
		 where t0.id = @ItemId;
	END 
	ELSE 
	BEGIN
		UPDATE [dbo].[CargoItem]
		SET [Length] = @Length
			,[ContainerNumber] = @ContainerNumber
			,[ContainerType] = @ContainerType
			,[ContainerSealNumber] = @ContainerSealNumber
		    ,[Height] = @Height
		    ,[Width] = @Width
		    ,[Net] = @NetWeight
		    ,[Gross] = @GrossWeight
			,[UpdateBy] = @ActionBy
			,[UpdateDate] = GETDATE()
		WHERE Id = @Id
	END

	SELECT CAST(@Id as bigint) as ID
END

GO
