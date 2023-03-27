BEGIN TRANSACTION [INSERT_SHIPPING_FLEET_DOCHISTORY]
BEGIN TRY
	--DELETE FROM ShippingFleetDocumentHistory

	INSERT INTO ShippingFleetDocumentHistory ([IdShippingFleet], [FileName], [CreateDate])
	SELECT	sf.Id, grDocument.[Filename], grDocument.[CreateDate]
	FROM	GoodsReceive gr
			JOIN GoodsReceiveItem grItem ON gr.Id = grItem.IdGr
			JOIN ShippingFleet sf ON gr.Id = sf.IdGr
			JOIN GoodsReceiveHistory grHistory ON gr.Id = grHistory.IdGr
			JOIN GoodsReceiveDocument grDocument ON gr.Id = grDocument.IdGr
	/*Where condition depend on insert data on shipping fleet*/
	--WHERE	grHistory.[Status] NOT IN ('Submit', 'Approve', 'Draft')
			--AND sf.Id BETWEEN 10066 AND 10903

	COMMIT TRANSACTION [INSERT_SHIPPING_FLEET_DOCHISTORY]
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [INSERT_SHIPPING_FLEET_DOCHISTORY]
END CATCH