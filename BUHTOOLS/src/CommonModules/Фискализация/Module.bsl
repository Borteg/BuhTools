
Функция СозданиеПодключениеUFS() Экспорт
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=elobanov;PWD=!155255!;DATABASE=PGW2_R");
	
	Возврат Connection;

КонецФункции


#Область ЗапросыSQL

Функция ЗапросТаблицыЧековSQL() Экспорт
	
	ТекстЗапроса = "Select rp.*,r.*,r.Sum as SumReceipt, rp.Sum as Sum
	|From receipt r (NOLOCK) 
	|join ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId and r.IsTest = 0 
	|Where r.ReceiptTime >= '@Дата1сВSQLНачало' and r.ReceiptTime < '@Дата1сВSQLКонец' and NOT r.FiscalDocumentAttribute = ''";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ЗапросСуммФискализацииSQL() Экспорт
	
	ТекстЗапроса = "Select 'Сервисный сбор' as Name,sum(case when r.type = 1 then rp.Sum else (-1)*rp.Sum end) as SUM,sum(case when r.type = 1 then rp.TaxSum else (-1)*rp.TaxSum end) AS TAX -- сумма по всем чекам по этому платежу
	|From receipt r (NOLOCK) 
	|join ReceiptPosition rp (NOLOCK)  on rp.ReceiptId = r.ReceiptId and r.IsTest = 0 
	|Where r.ReceiptTime >= '@Дата1сВSQLНачало' and r.ReceiptTime < '@Дата1сВSQLКонец' and rp.Name LIKE '%Сервисный сбор%' and r.FiscalDocumentAttribute <> '' 
	|UNION 
	|Select 'Аэроэкспресс' as Name,sum(case when r.type = 1 then rp.Sum else (-1)*rp.Sum end) as SUM,sum(case when r.type = 1 then rp.TaxSum else (-1)*rp.TaxSum end) AS TAX -- сумма по всем чекам по этому платежу
	|from receipt r (NOLOCK)
	|join ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId and r.IsTest = 0
	|where r.ReceiptTime >= '@Дата1сВSQLНачало' and r.ReceiptTime < '@Дата1сВSQLКонец'  and rp.Name LIKE '%Аэро%' and r.FiscalDocumentAttribute <> ''
	|UNION
	|Select 'Страхование' as Name,sum(case when r.type = 1 then rp.Sum else (-1)*rp.Sum end) as SUM,sum(case when r.type = 1 then rp.TaxSum else (-1)*rp.TaxSum end) AS TAX -- сумма по всем чекам по этому платежу
	|from receipt r (NOLOCK)
	|join ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId and r.IsTest = 0
	|where r.ReceiptTime >= '@Дата1сВSQLНачало' and r.ReceiptTime < '@Дата1сВSQLКонец' and rp.Name LIKE '%Страхование%' and r.FiscalDocumentAttribute <> ''
	|UNION
	|Select 'Остальное' as Name,sum(case when r.type = 1 then rp.Sum else (-1)*rp.Sum end) as SUM,sum(case when r.type = 1 then rp.TaxSum else (-1)*rp.TaxSum end) AS TAX -- сумма по всем чекам по этому платежу
	|from receipt r (NOLOCK)
	|join ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId and r.IsTest = 0
	|where r.ReceiptTime >= '@Дата1сВSQLНачало' and r.ReceiptTime < '@Дата1сВSQLКонец' and NOT (rp.Name LIKE '%Страхование%' or rp.Name LIKE '%Аэро%' or rp.Name LIKE '%Сервисный сбор%') and r.FiscalDocumentAttribute <> ''";	
	
	Возврат ТекстЗапроса;
КонецФункции

Функция ЗапросРасхожденийИфскализации() Экспорт
	
	ТекстЗапроса = "SELECT  op.OrderPaymentId,
	|SUM(CASE WHEN t.type = 14 THEN (-1)*t.amount ELSE t.amount END) + SUM(t.fee)  as SUMTRANS 
	|INTO #FULLFISCAL
	|FROM OrderPayment op (NOLOCK)
	|join PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId and pm.FiscaleReceipt = 1
	|join OrderPaymentTrans optrans (NOLOCK) on op.OrderPaymentId = optrans.OrderPaymentId
	|join Trans t (NOLOCK) on t.idtrans = optrans.TransId and t.test = 0 and t.status = 0
	|WHERE op.ConfirmTime >= '@Дата1сВSQLНачало' and op.ConfirmTime< '@Дата1сВSQLКонец' and op.Status = 0
	|and NOT EXISTS (Select * FROM [dbo].[InnovativeMobilityCompare] IMC (NOLOCK) WHERE imc.IsExternallyLoaded = 1 and IMC.TransactionId = t.idtrans)
	|and NOT EXISTS (Select * FROM [dbo].[SirenaCompare] SC (NOLOCK) WHERE SC.IsRefundThroughRzhd = 1 and SC.RzhdTransactionId = t.idtrans)
	|GROUP BY op.OrderPaymentId
	|SELECT  FF.OrderPaymentId, 
	|SUM(case when r.type = 1 then r.Sum else (-1)*r.Sum end) AS SUMRECEIPT
	|INTO #PAYMENTSRECEIPT
	|FROM #FULLFISCAL FF
	|join OrderPaymentReceipt opmr (NOLOCK) on opmr.OrderPaymentId = FF.OrderPaymentId
	|join Receipt r (NOLOCK) on r.ReceiptId = opmr.ReceiptId  and r.IsTest = 0 and not r.FiscalDocumentAttribute = ''
	|GROUP BY 
	|FF.OrderPaymentId
	|SELECT CASE WHEN FF.OrderPaymentId IS NULL THEN PR.OrderPaymentId ELSE FF.OrderPaymentId END as OrderPayment,
	|FF.SUMTRANS,
	|isNUll(PR.SUMRECEIPT,0) as SumReceipt  
	|FROM #FULLFISCAL FF
	|FULL JOIN #PAYMENTSRECEIPT PR ON PR.OrderPaymentId = FF.OrderPaymentId
	|WHERE (FF.OrderPaymentId IS NULL OR PR.OrderPaymentId IS NULL) or (FF.SUMTRANS <> IsNull(PR.SUMRECEIPT,0))
	|DROP TABLE #PAYMENTSRECEIPT
	|DROP TABLE #FULLFISCAL";
	
	Возврат ТекстЗапроса;	
	
КонецФункции
	
#КонецОбласти

#Область ПустыеТаблицыДляФискализации

Функция ПолучитьПустуюТаблицуФискализацииПоСервисам()
	
	ТаблицаФискализации = Новый ТаблицаЗначений;
	ТаблицаФискализации.Колонки.Добавить("Сервис",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаФискализации.Колонки.Добавить("Сумма",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаФискализации.Колонки.Добавить("СуммаНДС",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	
	Возврат ТаблицаФискализации;
	
КонецФункции

Функция ПолучитьТаблицуОшибокФискализацииUFS()
	
	ТаблицаОшибок  = Новый ТаблицаЗначений;
	ТаблицаОшибок.Колонки.Добавить("OrderPayment",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаОшибок.Колонки.Добавить("SumTrans",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаОшибок.Колонки.Добавить("SumReceipt",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	
	Возврат ТаблицаОшибок;

КонецФункции

Функция ПолучитьПустуюТаблицуЧековUFS()

	ТаблицаЧеков = Новый ТаблицаЗначений;
	ТаблицаЧеков.Колонки.Добавить("Type",ОбщегоНазначения.ОписаниеТипаЧисло(1,0),,);
	ТаблицаЧеков.Колонки.Добавить("ReceiptTime",ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.ДатаВремя),,);
	ТаблицаЧеков.Колонки.Добавить("SumReceipt",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("ShiftNumber",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("ShiftReceiptNumber",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("FiscalDocumentNumber",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("FiscalDocumentAttribute",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("FiscalAcumNumber",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("EcrRegistryNumber",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("Name",ОбщегоНазначения.ОписаниеТипаСтрока(300),,);
	ТаблицаЧеков.Колонки.Добавить("Price",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("Quantity",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("Sum",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("TaxSum",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("PaymentMethod",ОбщегоНазначения.ОписаниеТипаСтрока(20),,);
	ТаблицаЧеков.Колонки.Добавить("ClearingSum",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);
	ТаблицаЧеков.Колонки.Добавить("BonusSum",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),,);

	Возврат ТаблицаЧеков;
	
КонецФункции

#КонецОбласти


#Область ФормированиеДанных

Функция СверитьДанныеПоТаблицамЧеков(Соединение,ДатаНачала,ДатаОкончания)Экспорт
	
	ТаблицаЧеков = ПолучитьПустуюТаблицуЧековUFS();
	ПолучитьТаблицуЧековUFS(Соединение,ТаблицаЧеков,ДатаНачала,ДатаОкончания);


	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ФискальнаяИнформация.Период КАК Период1с,
	               |	ФискальнаяИнформация.ПозицияЧека КАК ПозицияЧека1с,
	               |	ФискальнаяИнформация.Количество КАК Количество1с,
	               |	ФискальнаяИнформация.Цена КАК Цена1с,
	               |	ФискальнаяИнформация.Сумма КАК Сумма1с,
	               |	ФискальнаяИнформация.НДС20 + ФискальнаяИнформация.НДС10 + ФискальнаяИнформация.НДС120 + ФискальнаяИнформация.НДС110 КАК НДС1с,
	               |	ВЫБОР
	               |		КОГДА ФискальнаяИнформация.ОперацияЧека = ""Возврат прихода""
	               |			ТОГДА 2
	               |		ИНАЧЕ 1
	               |	КОНЕЦ КАК ОперацияЧека1с,
	               |	ФискальнаяИнформация.РегистрационныйНомерККТ КАК РегистрационныйНомерККТ1с,
	               |	ФискальнаяИнформация.НомерФН КАК НомерФН1с,
	               |	ФискальнаяИнформация.НомерЧека КАК НомерЧека1с,
	               |	ФискальнаяИнформация.СуммаБезНалЧек КАК СуммаБезНалЧек1с
	               |ПОМЕСТИТЬ ДанныеОФД
	               |ИЗ
	               |	РегистрСведений.ФискальнаяИнформация КАК ФискальнаяИнформация
	               |ГДЕ
	               |	ФискальнаяИнформация.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	UFS.Type КАК ОперацияЧека,
	               |	UFS.ReceiptTime КАК Период,
	               |	UFS.SumReceipt - UFS.ClearingSum - UFS.BonusSum КАК СуммаБезНалЧек,
	               |	UFS.EcrRegistryNumber + ""_"" + UFS.FiscalAcumNumber + ""_"" + UFS.FiscalDocumentNumber КАК ДанныеЧека,
	               |	UFS.FiscalAcumNumber КАК НомерФН,
	               |	UFS.EcrRegistryNumber КАК РегистрационныйНомерККТ,
	               |	UFS.Name КАК ПозицияЧека,
	               |	UFS.Price КАК Цена,
	               |	UFS.Quantity КАК Количество,
	               |	UFS.Sum КАК Сумма,
	               |	UFS.TaxSum КАК НДС
	               |ПОМЕСТИТЬ ДанныеUFS
	               |ИЗ
	               |	&UFS КАК UFS
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДанныеUFS.ОперацияЧека КАК ОперацияЧека,
	               |	ДанныеUFS.Период КАК Период,
	               |	ДанныеUFS.НомерФН КАК НомерФН,
	               |	ДанныеUFS.РегистрационныйНомерККТ КАК РегистрационныйНомерККТ,
	               |	ДанныеUFS.ПозицияЧека КАК ПозицияЧека,
	               |	ДанныеUFS.Цена КАК Цена,
	               |	ДанныеUFS.Количество КАК Количество,
	               |	ДанныеUFS.Сумма КАК Сумма,
	               |	ДанныеUFS.НДС КАК НДС,
	               |	ДанныеОФД.Период1с КАК Период1с,
	               |	ДанныеОФД.ПозицияЧека1с КАК ПозицияЧека1с,
	               |	ДанныеОФД.Количество1с КАК Количество1с,
	               |	ДанныеОФД.Цена1с КАК Цена1с,
	               |	ДанныеОФД.Сумма1с КАК Сумма1с,
	               |	ДанныеОФД.НДС1с КАК НДС1с,
	               |	ДанныеОФД.ОперацияЧека1с КАК ОперацияЧека1с,
	               |	ДанныеОФД.РегистрационныйНомерККТ1с КАК РегистрационныйНомерККТ1с,
	               |	ДанныеОФД.НомерФН1с КАК НомерФН1с,
	               |	ДанныеОФД.НомерЧека1с КАК НомерЧека1с,
	               |	ДанныеОФД.СуммаБезНалЧек1с КАК СуммаБезНалЧек1с,
	               |	ДанныеUFS.СуммаБезНалЧек КАК СуммаБезНалЧек
	               |ИЗ
	               |	ДанныеОФД КАК ДанныеОФД
	               |		ПОЛНОЕ СОЕДИНЕНИЕ ДанныеUFS КАК ДанныеUFS
	               |		ПО ДанныеОФД.Период1с = ДанныеUFS.Период
	               |			И ДанныеОФД.ПозицияЧека1с = ДанныеUFS.ПозицияЧека
	               |			И ДанныеОФД.Сумма1с = ДанныеUFS.Сумма
	               |			И ДанныеОФД.ОперацияЧека1с = ДанныеUFS.ОперацияЧека
	               |			И ДанныеОФД.РегистрационныйНомерККТ1с = ДанныеUFS.РегистрационныйНомерККТ
	               |			И ДанныеОФД.НомерЧека1с = ДанныеUFS.ДанныеЧека
	               |			И ДанныеОФД.СуммаБезНалЧек1с = ДанныеUFS.СуммаБезНалЧек
	               |ГДЕ
	               |	(ДанныеUFS.ПозицияЧека ЕСТЬ NULL
	               |			ИЛИ ДанныеОФД.ПозицияЧека1с ЕСТЬ NULL)";
	
	Запрос.УстановитьПараметр("ДатаНачала",ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(ДатаОкончания));
	Запрос.УстановитьПараметр("UFS",  ТаблицаЧеков);
	
	СтруктураВозврата = Новый Структура;
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 0 Тогда
		СтруктураВозврата.Вставить("Ошибка",Ложь);
	Иначе 
		СтруктураВозврата.Вставить("Ошибка",Истина);
		СтруктураВозврата.Вставить("ТаблицаОшибок",Результат);
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

Функция СверитьДанныеПоСуммамФискализации(Соединение,ДатаНачала,ДатаОкончания) Экспорт
	
	ТаблицаСервисов = ПолучитьПустуюТаблицуФискализацииПоСервисам();
	ТекстЗапроса = ЗапросСуммФискализацииSQL(); 
	ОбщегоНазначения.ПодготовитьДатыВЗапросе(ТекстЗапроса,ДатаНачала,ДатаОкончания);
	
	RecordSet = Соединение.Execute(ТекстЗапроса);
	
	Пока НЕ RecordSet.EOF() Цикл
		
		НоваяСтрока = ТаблицаСервисов.Добавить();
		
		НоваяСтрока.Сервис = RecordSet.Fields("Name").Value;
		НоваяСтрока.Сумма = RecordSet.Fields("SUM").Value;
		НоваяСтрока.СуммаНДС = RecordSet.Fields("TAX").Value;
		
		RecordSet.MoveNext();
		
	КонецЦикла;
	
	RecordSet.Close();
	
	Запрос = Новый Запрос;
	Запрос.Текст ="ВЫБРАТЬ
	              |	СУММА(ВЫБОР
	              |			КОГДА ДанныеПоПозициямЧека.ОперацияЧека = ""Возврат прихода""
	              |				ТОГДА -1 * ДанныеПоПозициямЧека.Сумма
	              |			ИНАЧЕ ДанныеПоПозициямЧека.Сумма
	              |		КОНЕЦ) КАК СуммаОФД,
	              |	""Сервисный сбор"" КАК НаименованиеОФД
	              |ПОМЕСТИТЬ ДанныеОФД
	              |ИЗ
	              |	РегистрСведений.ФискальнаяИнформация КАК ДанныеПоПозициямЧека
	              |ГДЕ
	              |	ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Сервисный сбор%""
	              |	И ДанныеПоПозициямЧека.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	              |
	              |ОБЪЕДИНИТЬ ВСЕ
	              |
	              |ВЫБРАТЬ
	              |	СУММА(ВЫБОР
	              |			КОГДА ДанныеПоПозициямЧека.ОперацияЧека = ""Возврат прихода""
	              |				ТОГДА -1 * ДанныеПоПозициямЧека.Сумма
	              |			ИНАЧЕ ДанныеПоПозициямЧека.Сумма
	              |		КОНЕЦ),
	              |	""Страхование""
	              |ИЗ
	              |	РегистрСведений.ФискальнаяИнформация КАК ДанныеПоПозициямЧека
	              |ГДЕ
	              |	ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Страхование%""
	              |	И ДанныеПоПозициямЧека.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	              |
	              |ОБЪЕДИНИТЬ ВСЕ
	              |
	              |ВЫБРАТЬ
	              |	СУММА(ВЫБОР
	              |			КОГДА ДанныеПоПозициямЧека.ОперацияЧека = ""Возврат прихода""
	              |				ТОГДА -1 * ДанныеПоПозициямЧека.Сумма
	              |			ИНАЧЕ ДанныеПоПозициямЧека.Сумма
	              |		КОНЕЦ),
	              |	""Аэроэкспресс""
	              |ИЗ
	              |	РегистрСведений.ФискальнаяИнформация КАК ДанныеПоПозициямЧека
	              |ГДЕ
	              |	ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Аэро%""
	              |	И ДанныеПоПозициямЧека.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	              |
	              |ОБЪЕДИНИТЬ ВСЕ
	              |
	              |ВЫБРАТЬ
	              |	СУММА(ВЫБОР
	              |			КОГДА ДанныеПоПозициямЧека.ОперацияЧека = ""Возврат прихода""
	              |				ТОГДА -1 * ДанныеПоПозициямЧека.Сумма
	              |			ИНАЧЕ ДанныеПоПозициямЧека.Сумма
	              |		КОНЕЦ),
	              |	""Остальное""
	              |ИЗ
	              |	РегистрСведений.ФискальнаяИнформация КАК ДанныеПоПозициямЧека
	              |ГДЕ
	              |	НЕ(ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Сервисный сбор%""
	              |				ИЛИ ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Страхование%""
	              |				ИЛИ ДанныеПоПозициямЧека.ПозицияЧека ПОДОБНО ""%Аэро%"")
	              |	И ДанныеПоПозициямЧека.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	UFS.Сервис КАК Сервис,
	              |	UFS.Сумма КАК Сумма,
	              |	UFS.СуммаНДС КАК СуммаНДС
	              |ПОМЕСТИТЬ ДанныеUFS
	              |ИЗ
	              |	&UFS КАК UFS
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	ДанныеUFS.Сервис КАК Сервис,
	              |	ДанныеUFS.Сумма КАК Сумма,
	              |	ДанныеUFS.СуммаНДС КАК СуммаНДС,
	              |	ДанныеОФД.СуммаОФД КАК СуммаОФД,
	              |	ДанныеОФД.НаименованиеОФД КАК СервисОФД,
	              |	ВЫБОР
	              |		КОГДА ДанныеUFS.Сервис ЕСТЬ NULL
	              |			ТОГДА ЛОЖЬ
	              |		ИНАЧЕ ИСТИНА
	              |	КОНЕЦ КАК ПризнакUFS
	              |ИЗ
	              |	ДанныеОФД КАК ДанныеОФД
	              |		ПОЛНОЕ СОЕДИНЕНИЕ ДанныеUFS КАК ДанныеUFS
	              |		ПО ДанныеОФД.НаименованиеОФД = ДанныеUFS.Сервис
	              |			И ДанныеОФД.СуммаОФД = ДанныеUFS.Сумма
	              |ГДЕ
	              |	(ДанныеUFS.Сервис ЕСТЬ NULL
	              |			ИЛИ ДанныеОФД.НаименованиеОФД ЕСТЬ NULL)";
	
	Запрос.УстановитьПараметр("ДатаНачала",ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(ДатаОкончания));
	Запрос.УстановитьПараметр("UFS",ТаблицаСервисов);

	СтруктураВозврата = Новый Структура;
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 0 Тогда
		СтруктураВозврата.Вставить("Ошибка",Ложь);
	Иначе 
		СтруктураВозврата.Вставить("Ошибка",Истина);
		СтруктураВозврата.Вставить("ТаблицаОшибок",Результат);
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

Функция ОпределитьРасхожденияПоТаблицамUFS(Соединение,ДатаНачала,ДатаОкончания) Экспорт
	
	ТекстЗапроса = ЗапросРасхожденийИфскализации();
	ОбщегоНазначения.ПодготовитьДатыВЗапросе(ТекстЗапроса,ДатаНачала,ДатаОкончания);
	ТаблицаОшибок = ПолучитьТаблицуОшибокФискализацииUFS();
	
	RecordSet = Соединение.Execute(ТекстЗапроса);
	
	Пока НЕ RecordSet.EOF() Цикл
		
		НоваяСтрока = ТаблицаОшибок.Добавить();
		
		НоваяСтрока.OrderPayment = RecordSet.Fields("OrderPayment").Value;
		НоваяСтрока.SumTrans = RecordSet.Fields("SUMTRANS").Value;
		НоваяСтрока.SumReceipt = RecordSet.Fields("SumReceipt").Value;
		
		RecordSet.MoveNext();
		
	КонецЦикла;
	
	RecordSet.Close();
	
	СтруктураВозврата = Новый Структура;
	
	
	Если ТаблицаОшибок.Количество() = 0 Тогда
		СтруктураВозврата.Вставить("Ошибка",Ложь);
	Иначе 
		СтруктураВозврата.Вставить("Ошибка",Истина);
		СтруктураВозврата.Вставить("ТаблицаОшибок",ТаблицаОшибок);
	КонецЕсли;
	
	Возврат СтруктураВозврата;

	
КонецФункции

Процедура ПолучитьТаблицуЧековUFS(Соединение,ТаблицаЧеков,ДатаНачала,ДатаОкончания) Экспорт
	
	ТекстЗапроса = ЗапросТаблицыЧековSQL();
	ОбщегоНазначения.ПодготовитьДатыВЗапросе(ТекстЗапроса,ДатаНачала,ДатаОкончания);
	
	RecordSet = Соединение.Execute(ТекстЗапроса);
	
	Пока НЕ RecordSet.EOF() Цикл
		
		НоваяСтрока = ТаблицаЧеков.Добавить();
		
		НоваяСтрока.Type = RecordSet.Fields("Type").Value;
		НоваяСтрока.ReceiptTime = RecordSet.Fields("ReceiptTime").Value;
		НоваяСтрока.SumReceipt = RecordSet.Fields("SumReceipt").Value;
		НоваяСтрока.ShiftNumber = RecordSet.Fields("ShiftNumber").Value;
		НоваяСтрока.ShiftReceiptNumber = RecordSet.Fields("ShiftReceiptNumber").Value;
		НоваяСтрока.FiscalDocumentNumber = RecordSet.Fields("FiscalDocumentNumber").Value;
		НоваяСтрока.FiscalDocumentAttribute = RecordSet.Fields("FiscalDocumentAttribute").Value;
		НоваяСтрока.FiscalAcumNumber = RecordSet.Fields("FiscalAcumNumber").Value;
		НоваяСтрока.EcrRegistryNumber = RecordSet.Fields("EcrRegistryNumber").Value;
		НоваяСтрока.Name = RecordSet.Fields("Name").Value;
		НоваяСтрока.Price = RecordSet.Fields("Price").Value;
		НоваяСтрока.Quantity = RecordSet.Fields("Quantity").Value;
		НоваяСтрока.Sum = RecordSet.Fields("Sum").Value;
		НоваяСтрока.TaxSum = RecordSet.Fields("TaxSum").Value;
		НоваяСтрока.PaymentMethod = RecordSet.Fields("PaymentMethod").Value;
		НоваяСтрока.ClearingSum = RecordSet.Fields("ClearingSum").Value;
		НоваяСтрока.BonusSum = RecordSet.Fields("BonusSum").Value;
		
		RecordSet.MoveNext();
		
	КонецЦикла;
	
	RecordSet.Close();	
	
КонецПроцедуры

#КонецОбласти
