USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplDelete_20200612]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CiplDelete_20200612] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@Status NVARCHAR(50)
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE R
	SET R.AvailableQuantity = R.AvailableQuantity + CI.Quantity
	FROM Reference R
	INNER JOIN (
		SELECT CI.IdReference
			,SUM(CI.Quantity) Quantity
		FROM CiplItem CI
		WHERE CI.IdCipl = @id
			AND CI.IsDelete = 0
		GROUP BY CI.IdReference
		) CI ON CI.IdReference = R.Id

	IF (@Status = 'ALL')
	BEGIN
		UPDATE dbo.Cipl
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE id = @id;

		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id
	END
	ELSE IF (@Status = 'CIPLITEM')
	BEGIN
		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id
	END
	ELSE IF (@Status = 'CIPLITEMID')
	BEGIN
		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id

		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdParent = @id
	END
END
GO
