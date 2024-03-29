USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_new]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insert_update_gr_new] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id nvarchar(100),
	@GrNo nvarchar(20),
	@Notes nvarchar(max),
	@Vendor nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate smalldatetime,
	@UpdateBy nvarchar(100) = '',
	@UpdateDate smalldatetime,
	@IsDelete bit = 0,
	@PickupPoint nvarchar(100) = '',
	@PickupPic nvarchar(100) = '',
	@Status nvarchar(100) = 'Draft'

)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[GoodsReceiveNew]
           (
			  [GrNo]
			, [Vendor]
			, [PickupPoint]
			, [PickupPic]
			, [Notes]
			, [CreatedBy]
			, [CreateDate]
			, [UpdatedBy]
			, [UpdateDate])
		VALUES
           (@GrNo
			, @Vendor
			, @PickupPoint
			, @PickupPic
			, @Notes
			, @CreateBy
			, @CreateDate
			,@UpdateBy
			, @UpdateDate)

		SET @Id = SCOPE_IDENTITY()
		EXEC [dbo].[GenerateGoodsReceiveNumber] @Id
		EXEC [dbo].[sp_insert_request_data] @Id, 'GR', '', @Status, 'Create'
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[GoodsReceiveNew]
		SET    [Notes] = @Notes
			  ,[Vendor] = @Vendor		
		      ,[UpdatedBy] = @UpdateBy
		      ,[UpdateDate] = @UpdateDate
		
		
		WHERE Id = @Id

		EXEC [dbo].[sp_update_request_gr] @Id, @UpdateBy, @Status, ''
	END
	SELECT CAST(@Id as bigint) as ID
END

GO
