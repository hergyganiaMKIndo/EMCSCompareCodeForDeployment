USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_ArmadaDocumentUpdateFileForRFC]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFileForRFC]      
(      
 @Id BIGINT,      
 @Filename NVARCHAR(MAX) = '' ,  
 @buttonRFC bit  
)      
AS      
BEGIN      
    if @buttonRFC = 0  
    begin  
    UPDATE dbo.ShippingFleet_Change      
    SET [FileName] = @Filename       
    WHERE IdShippingFleet = @Id;      
    end  
 else  
 begin  
 update ShippingFleet_Change  
 set FileName = @Filename  
 where Id = @Id  
 end  
END 

GO
