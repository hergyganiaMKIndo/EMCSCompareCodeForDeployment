USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_armada_document]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_armada_document]
(
	@Id NVARCHAR(10)
)	
AS
BEGIN
	select * from ShippingFleet
	where Id = @Id
	
END

GO
