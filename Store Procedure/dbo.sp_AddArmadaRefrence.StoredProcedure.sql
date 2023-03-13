USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddArmadaRefrence]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_AddArmadaRefrence](  
 @Id bigint = 0,  
 @IdShippingFleet bigint ,  
 @IdGr bigint,  
 @IdCipl bigint = 0,  
 @DoNo nvarchar(max)  
 )  
 AS  
 begin  
 Set @IdCipl = (Select Id from Cipl where EdoNo = @DoNo)  
 insert into ShippingFleetRefrence(IdShippingFleet,IdGr,IdCipl,DoNo,CreateDate)  
 values (@IdShippingFleet,@IdGr,@IdCipl,@DoNo,GETDATE())  
 SET @Id = SCOPE_IDENTITY()     
 SELECT CAST(@Id as bigint) as Id    
 end

GO
