BEGIN TRANSACTION [INSERT_SHIPPING_FLEET_CHANGE]
BEGIN TRY
	--DELETE FROM ShippingFleet_Change

	INSERT INTO ShippingFleet_Change ([IdShippingFleet], [IdGr], [IdCipl], [DoNo], [DaNo], [PicName], [PhoneNumber], [KtpNumber], [SimNumber], [SimExpiryDate], [StnkNumber], [KirNumber], [KirExpire], [NopolNumber], [EstimationTimePickup], [Apar], [Apd], [FileName], [Bast], [Status])
	SELECT	sf.Id, grHistory.IdGr, sf.IdCipl, sf.DoNo, sf.DaNo, sf.PicName, sf.PhoneNumber, sf.KtpNumber, sf.SimNumber, sf.SimExpiryDate, sf.StnkNumber, sf.KirNumber, sf.KirExpire, sf.NopolNumber, sf.EstimationTimePickup, sf.Apar, sf.Apd, sf.[FileName], sf.[Bast], 'Updated' [Status]
	FROM	GoodsReceive gr
			JOIN GoodsReceiveItem grItem ON gr.Id = grItem.IdGr
			JOIN ShippingFleet sf ON gr.Id = sf.IdGr
			JOIN GoodsReceiveHistory grHistory ON gr.Id = grHistory.IdGr
	/*Where condition depend on insert data on shipping fleet*/
	WHERE	grHistory.[Status] NOT IN ('Submit', 'Approve', 'Draft')
			--AND sf.Id BETWEEN 10066 AND 10903

	COMMIT TRANSACTION [INSERT_SHIPPING_FLEET_CHANGE]
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [INSERT_SHIPPING_FLEET_CHANGE]
END CATCH