
// При компоновке результата.
// 
// Параметры:
//  ДокументРезультат - ТабличныйДокумент - Документ результат
//  ДанныеРасшифровки Данные расшифровки
//  СтандартнаяОбработка - Булево - Стандартная обработка
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка  = Ложь;
	
	НастройкиПользователяУФС = КомпоновщикНастроек.ПолучитьНастройки();
	
	ПараметрПериодКомпоновки = Новый ПараметрКомпоновкиДанных("Период");
	ПараметрПериод = НастройкиПользователяУФС.ПараметрыДанных.НайтиЗначениеПараметра(ПараметрПериодКомпоновки);
	
	
	ДатаНачала = ПараметрПериод.Значение.ДатаНачала;
	ДатаОкончания = ПараметрПериод.Значение.ДатаОкончания;
	НастройкиПользователяУФС.ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияДляОтбора",ДатаОкончания); 
	
	ГлобальнаяОперация = Новый УникальныйИдентификатор;
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ДанныеПоВсемПлатежам",ГлобальнаяОперация);
	ДанныеПоВсемПлатежам = ПолучитьДанныеПоВсемПлатежам(ДатаНачала,ДатаОкончания);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ЧерезКассыРЖД",ГлобальнаяОперация);
	ВозвратыЧерезКассы = ПолучитьДанныеПоВсемВозвратамЧерезКассы(ДатаНачала,ДатаОкончания);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);

	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ФискальнаяИнформацияПоПлатежам",ГлобальнаяОперация);
	ФискИнфо = ФискальнаяИнформацияПоПлатежам(ДатаНачала,ДатаОкончания);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("СворачиваниеФискальнойИнформации",ГлобальнаяОперация);
    ФискИнфоСводно = ПодготовитьФискальнуюИнформациюСводно(ФискИнфо);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("РасхожденияВФискальнойИнформации",ГлобальнаяОперация);
	РасхожденияБезНеФиск = ПодготовитьРасхождения(ФискИнфо);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("НефискализированныеДанные",ГлобальнаяОперация);
	НеФиск = ОбработатьВторичнуюТаблицуПоТаблицеЗагрузки(ДанныеПоВсемПлатежам,ФискИнфо);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ФискализированныеПоКассам",ГлобальнаяОперация);
	ФискКассы = ФискальнаяИнформацияПоКассам(ДатаНачала,ДатаОкончания);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ФискализированныеИзДругихПериодов",ГлобальнаяОперация);
	ФискИзДругихПериодов = ОбработатьВторичнуюТаблицуПоТаблицеЗагрузки(ФискКассы,ФискИнфо); 
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("Сворачивание",ГлобальнаяОперация);
    ФискКассы.Свернуть("Банк,СпособОплаты","СервисныйСбор,ОстальныеУслуги");
	ДанныеПоВсемПлатежам.Свернуть("Банк,СпособОплаты","СервисныйСбор,ОстальныеУслуги");
	ВозвратыЧерезКассы.Свернуть("Банк,СпособОплаты","СервисныйСбор,ОстальныеУслуги");

    ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);
	
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("Индексировать",ГлобальнаяОперация);
    ФискИнфо.Индексы.Добавить("ДатаВремя");
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);

	СхемаКомпоновкиДанных = Отчеты.ФискальнаяДисциплина.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,НастройкиПользователяУФС,,,,,);

	//	ПодготовитьТзСЧекамиПолнаяИнформация()
	ВнешниеНаборы = Новый Структура("ТаблицаСДанными,ФискИнфо,НеФиск,ФискКассы,ФискДругиеПериоды,ФискИнфоСводно,Расхождения,ВозвратыЧерезКассы",ДанныеПоВсемПлатежам,ФискИнфо,НеФиск,ФискКассы,ФискИзДругихПериодов,ФискИнфоСводно,РасхожденияБезНеФиск,ВозвратыЧерезКассы);
	//ВнешниеНаборы = Новый Структура("ТаблицаСДанными,ФискИнфо,НеФиск,ФискКассы,ФискДругиеПериоды",ДанныеПоВсемПлатежам,ФискИнфо,НеФиск,ПодготовитьТзСЧекамиПолнаяИнформация(),ФискИзДругихПериодов);

	ПроцессорКомпоновки  = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
	ОписаниеЗамера = ЗамерВремени.НачатьЗамерДлительнойОперации("ВыводСКД",ГлобальнаяОперация);	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ДокументРезультат.АвтоМасштаб = Истина;
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	ЗамерВремени.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера);

КонецПроцедуры

Функция ПодготовитьРасхождения(Знач ФискальнаяИнформация)
	
	ТаблицаЗначенийДляВывода = Новый ТаблицаЗначений;
	СхемаКомпоновкиДанных = Отчеты.ФискальнаяДисциплина.ПолучитьМакет("РасхожденияФискДанных");
	НастройкиПоУмолчанию = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,НастройкиПоУмолчанию,,,Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"),,);
	ВнешниеНаборы = Новый Структура("ФискИнфо",ФискальнаяИнформация);
	ПроцессорКомпоновки  = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ТаблицаЗначенийДляВывода);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	Возврат ТаблицаЗначенийДляВывода;
	
КонецФункции

Функция ПодготовитьФискальнуюИнформациюСводно(Знач ФискальнаяИнформация)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ФискальнаяИнформаиця.СпособОплаты КАК СпособОплаты,
	|   ФискальнаяИнформаиця.Банк КАК Банк,
	|	ФискальнаяИнформаиця.СервисныйСбор КАК СервисныйСбор,
	|	ФискальнаяИнформаиця.ОстальныеУслуги КАК ОстальныеУслуги
	|ПОМЕСТИТЬ ФискИнфо
	|ИЗ
	|	&ФискальнаяИнформаиця КАК ФискальнаяИнформаиця
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ФискИнфо.СпособОплаты КАК СпособОплаты,
	|	ФискИнфо.Банк КАК Банк,
	|	СУММА(ФискИнфо.СервисныйСбор) КАК СервисныйСбор,
	|	СУММА(ФискИнфо.ОстальныеУслуги) КАК ОстальныеУслуги
	|ИЗ
	|	ФискИнфо КАК ФискИнфо
	|
	|СГРУППИРОВАТЬ ПО
	|	ФискИнфо.СпособОплаты,
	|	ФискИнфо.Банк";
	
	Запрос.УстановитьПараметр("ФискальнаяИнформаиця",ФискальнаяИнформация);
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	Возврат ТЗ;
	
КонецФункции


//устарело
Функция НефискализированныеДанные(Знач ВсеПлатежи,Знач Фискализированные)
	
	ПлатежиФискализированные = Фискализированные.ВыгрузитьКолонку("Платеж");
	
	МассивКопирования = Новый Массив;
	
	Для Каждого СтрокаДанных Из ВсеПлатежи Цикл
		
		Если ПлатежиФискализированные.Найти(СтрокаДанных.Платеж) = Неопределено Тогда
			МассивКопирования.Добавить(СтрокаДанных);
		КонецЕсли;
		
	КонецЦикла;
	
	НеФиск = ВсеПлатежи.Скопировать(МассивКопирования);
	
	Возврат НеФиск;
		
КонецФункции

#Область ВспомогательныеФункции
Функция СоединениеСБазой()
	
	Connection = Новый COMОбъект("ADODB.Connection");
	
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_R");
	//Connection.Open ("DRIVER={SQL Server};SERVER=rdb0;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_test");
	
	Возврат	Connection;
	
КонецФункции

Функция ОбъявитьДаты(Знач ДатаНачала,Знач ДатаОкончания)
	
	ДатаОкончания = ДатаОкончания + 1;
	ДатаНачалаСтрока = Формат(ДатаНачала,"ДФ=yyyyMMdd");
	ДатаОкончанияСтрока = Формат(ДатаОкончания,"ДФ=yyyyMMdd");

	ТекстОбъявления = "	
	| DECLARE @BEGDate date;  --дата начала 
	| DECLARE @ENDDate date;  --дата окончания(на секунду больше) 
	| SET @BEGDate = '"+ДатаНачалаСтрока+"'
	| SET @ENDDate = '" +ДатаОкончанияСтрока+"'";
	
	Возврат ТекстОбъявления;
	
КонецФункции

Функция ОбъявитьНачалоЗапроса()
	
	ТекстОбъявления = "	
	| SET transaction isolation level read uncommitted
	| SET NOCOUNT ON";
	
	Возврат ТекстОбъявления;
	
КонецФункции
#КонецОбласти

#Область ДанныеПоПлатежам
Функция ПолучитьДанныеПоВсемПлатежам(ДатаНачала,ДатаОкончания)
	
	ТекстЗапросаНачало = ОбъявитьНачалоЗапроса();
	ТекстЗапросаДаты = ОбъявитьДаты(ДатаНачала,ДатаОкончания);
	ТелоЗапрос = ЗапросДанныеПоВсемПлатежам();
	Запрос = ТекстЗапросаНачало +  " "  + Символы.ПС + " " + ТекстЗапросаДаты +  " "  + Символы.ПС + " " + ТелоЗапрос;

    Соединение = СоединениеСБазой();
	РезультатЗапроса = Соединение.Execute(Запрос);

	Данные = ПодготовитьТзСПлатежами();
	
	Пока НЕ РезультатЗапроса.EOF() Цикл
		
		НоваяСтрока = Данные.Добавить();
		
		НоваяСтрока.СпособОплаты = РезультатЗапроса.Fields("PaymentMethod").Value;
		
		НоваяСтрока.Платеж = Число(РезультатЗапроса.Fields("OrderNumber").Value);	
		
		НоваяСтрока.СервисныйСбор = Число(РезультатЗапроса.Fields("UFSFEE").Value);
		
		НоваяСтрока.ОстальныеУслуги = Число(РезультатЗапроса.Fields("SRV").Value);
		
		НоваяСтрока.Банк = РезультатЗапроса.Fields("BANK").Value;
		
		РезультатЗапроса.MoveNext();
		
	КонецЦикла; 
	
	РезультатЗапроса.Close();
	Соединение.Close();
	
	Возврат Данные;
	
	
КонецФункции

Функция ЗапросДанныеПоВсемПлатежам()
	
	ТекстЗапрос = "SELECT acc.idtrans
	|,acc.directfee
	|,t.OrderPaymentId
	|,sum(acc.sumfee) as accfee
	|,sum(acc.sumsrv) as accsrv
	|,sum(acc.sum) as accsum 
	|,max(case when t.type = 14 then (-1)*t.amount else t.amount end) as transamount
	|,max(t.fee) as transfee 
	|INTO #ACC 
	|FROM ufs_Accountings acc (NOLOCK) 
	|JOIN Trans t (NOLOCK) on t.idtrans = acc.idtrans and t.status = 0  and t.test = 0
	|WHERE acc.phase = 1  and acc.tpstatus = 5 and 
	|acc.datereg >= @BEGDate and acc.datereg < @ENDDate 
	|and acc.idpayer = 47072 
	|Group BY t.OrderPaymentId,acc.idtrans,acc.directfee
	|	
	|SELECT pm.Name as PaymentMethod
	|,acc.OrderPaymentId as OrderNumber
	|,sum(acc.transfee) as UFSFEE
	|,sum(acc.transamount) as SRV
	|INTO #NOBROKER
	|FROM #ACC acc (NOLOCK)
	|JOIN OrderPayment op (NOLOCK) on acc.OrderPaymentId = op.OrderPaymentId and op.Status = 0
	|JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId and pm.FiscaleReceipt = 1
	|WHERE acc.directfee = 1	
	|and NOT EXISTS (Select top 1 1 FROM [dbo].[InnovativeMobilityCompare] IMC (NOLOCK) WHERE imc.IsExternallyLoaded = 1 and IMC.TransactionId = acc.idtrans)
	|and NOT EXISTS (Select top 1 1 FROM [dbo].[SirenaCompare] SC (NOLOCK) WHERE SC.IsRefundThroughRzhd = 1 and SC.RzhdTransactionId = acc.idtrans and SC.IsSentReceiptBySupplier = 1)
	|GROUP BY pm.Name,acc.OrderPaymentId
	|
	|Select NB.PaymentMethod as PaymentMethod
	|,NB.OrderNumber as OrderNumber
	|,NB.UFSFEE as UFSFEE  
	|,NB.SRV as SRV
	|,max(case when mem.nameMember is NUll then NB.PaymentMethod else mem.nameMember end) as BANK
	|From #NOBROKER NB (NOLOCK)
	|left JOIN OrderBrokerPayment opm (NOLOCK) on opm.OrderPaymentId = NB.orderNumber
	|left JOIN members mem (NOLOCK) on mem.idMember = opm.BrokerId and paytool = 6
	|Group BY NB.PaymentMethod,NB.OrderNumber,NB.UFSFEE,NB.SRV
	|
	|DROP TABLE #ACC
	|DROP TABLE #NOBROKER";
	
	Возврат ТекстЗапрос;
	
КонецФункции

Функция ЗапросДанныеПоВозвратамЧерезКассыРЖД()
	
	ТекстЗапрос = "SELECT acc.idtrans
	|,acc.directfee
	|,t.OrderPaymentId
	|,sum(acc.sumfee) as accfee
	|,sum(acc.sumsrv) as accsrv
	|,sum(acc.sum) as accsum 
	|,max(case when t.type = 14 then (-1)*t.amount else t.amount end) as transamount
	|,max(t.fee) as transfee 
	|INTO #ACC 
	|FROM ufs_Accountings acc (NOLOCK) 
	|JOIN Trans t (NOLOCK) on t.idtrans = acc.idtrans and t.status = 0  and t.test = 0
	|WHERE acc.phase = 1  and acc.tpstatus = 5 and 
	|acc.datereg >= @BEGDate and acc.datereg < @ENDDate 
	|and acc.idpayer = 47072 
	|Group BY t.OrderPaymentId,acc.idtrans,acc.directfee
	|	
	|SELECT pm.Name as PaymentMethod
	|,acc.OrderPaymentId as OrderNumber
	|,sum(acc.transfee) as UFSFEE
	|,sum(acc.transamount) as SRV
	|INTO #NOBROKER
	|FROM #ACC acc (NOLOCK)
	|JOIN OrderPayment op (NOLOCK) on acc.OrderPaymentId = op.OrderPaymentId and op.Status = 0
	|JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId and pm.FiscaleReceipt = 1
	|WHERE acc.directfee = 1	
	|and (EXISTS (Select top 1 1 FROM [dbo].[InnovativeMobilityCompare] IMC (NOLOCK) WHERE imc.IsExternallyLoaded = 1 and IMC.TransactionId = acc.idtrans)
	|or EXISTS (Select top 1 1 FROM [dbo].[SirenaCompare] SC (NOLOCK) WHERE SC.IsRefundThroughRzhd = 1 and SC.RzhdTransactionId = acc.idtrans and  SC.IsSentReceiptBySupplier = 1))
	|GROUP BY pm.Name,acc.OrderPaymentId
	|
	|Select NB.PaymentMethod as PaymentMethod
	|,NB.OrderNumber as OrderNumber
	|,NB.UFSFEE as UFSFEE  
	|,NB.SRV as SRV
	|,max(case when mem.nameMember is NUll then NB.PaymentMethod else mem.nameMember end) as BANK
	|From #NOBROKER NB (NOLOCK)
	|left JOIN OrderBrokerPayment opm (NOLOCK) on opm.OrderPaymentId = NB.orderNumber
	|left JOIN members mem (NOLOCK) on mem.idMember = opm.BrokerId and paytool = 6
	|Group BY NB.PaymentMethod,NB.OrderNumber,NB.UFSFEE,NB.SRV
	|
	|DROP TABLE #ACC
	|DROP TABLE #NOBROKER";
	
	Возврат ТекстЗапрос;
	
КонецФункции

Функция ПолучитьДанныеПоВсемВозвратамЧерезКассы(ДатаНачала,ДатаОкончания)
	
	ТекстЗапросаНачало = ОбъявитьНачалоЗапроса();
	ТекстЗапросаДаты = ОбъявитьДаты(ДатаНачала,ДатаОкончания);
	ТелоЗапрос = ЗапросДанныеПоВозвратамЧерезКассыРЖД();
	Запрос = ТекстЗапросаНачало +  " "  + Символы.ПС + " " + ТекстЗапросаДаты +  " "  + Символы.ПС + " " + ТелоЗапрос;

    Соединение = СоединениеСБазой();
	РезультатЗапроса = Соединение.Execute(Запрос);

	Данные = ПодготовитьТзСПлатежами();
	
	Пока НЕ РезультатЗапроса.EOF() Цикл
		
		НоваяСтрока = Данные.Добавить();
		
		НоваяСтрока.СпособОплаты = РезультатЗапроса.Fields("PaymentMethod").Value;
		
		НоваяСтрока.Платеж = Число(РезультатЗапроса.Fields("OrderNumber").Value);	
		
		НоваяСтрока.СервисныйСбор = Число(РезультатЗапроса.Fields("UFSFEE").Value);
		
		НоваяСтрока.ОстальныеУслуги = Число(РезультатЗапроса.Fields("SRV").Value);
		
		НоваяСтрока.Банк = РезультатЗапроса.Fields("BANK").Value;
		
		РезультатЗапроса.MoveNext();
		
	КонецЦикла; 
	
	РезультатЗапроса.Close();
	Соединение.Close();
	
	Возврат Данные;
	
	
КонецФункции


Функция ПодготовитьТзСПлатежами()
		
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("СпособОплаты",ОбщегоНазначения.ОписаниеТипаСтрока(150),"СпособОплаты");
	ТЗ.Колонки.Добавить("Платеж",ОбщегоНазначения.ОписаниеТипаЧисло(15,0,ДопустимыйЗнак.Неотрицательный),"Платеж");
	ТЗ.Колонки.Добавить("СервисныйСбор",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"СервисныйСбор");
	ТЗ.Колонки.Добавить("ОстальныеУслуги",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"ОстальныеУслуги");
	ТЗ.Колонки.Добавить("Банк",ОбщегоНазначения.ОписаниеТипаСтрока(150),"Банк");

	Возврат ТЗ;
	
КонецФункции
#КонецОбласти

#Область ФискальнаяИнформацияПоПлатежам
Функция ФискальнаяИнформацияПоПлатежам(ДатаНачала,ДатаОкончания)
	
	ТекстЗапросаНачало = ОбъявитьНачалоЗапроса();
	ТекстЗапросаДаты = ОбъявитьДаты(ДатаНачала,ДатаОкончания);
	ТелоЗапрос = ЗапросФискальнаяИнформацияПолнаяНовая();
	//ТелоЗапрос = ЗапросФискальнаяИнформация(МассивПлатежей);
	Запрос = ТекстЗапросаНачало +  " " + Символы.ПС + " " + ТекстЗапросаДаты + " " + Символы.ПС +  " " + ТелоЗапрос;

	Соединение = СоединениеСБазой();
	РезультатЗапроса = Соединение.Execute(Запрос);
	
	Данные = ПодготовитьТзСЧекамиПолнаяИнформация();

	Пока НЕ РезультатЗапроса.EOF() Цикл
		
		НоваяСтрока = Данные.Добавить();
		
		НоваяСтрока.СпособОплаты = РезультатЗапроса.Fields("PaymentMethod").Value;
		
		НоваяСтрока.СервисныйСбор = Число(РезультатЗапроса.Fields("UFSFEERECEIPT").Value);

		НоваяСтрока.ОстальныеУслуги = Число(РезультатЗапроса.Fields("SRVRECEIPT").Value);
			
		НоваяСтрока.НаименованиеПозиции = РезультатЗапроса.Fields("ReceiptPositionName").Value;
		
		НоваяСтрока.Платеж = Число(РезультатЗапроса.Fields("OrderNumber").Value);	

	    НоваяСтрока.Сумма = Число(РезультатЗапроса.Fields("SumPosition").Value);
		
	    НоваяСтрока.ДатаВремя = РезультатЗапроса.Fields("ReceiptTime").Value;
			
		НоваяСтрока.ТипЧека = Число(РезультатЗапроса.Fields("Type").Value);
			
		НоваяСтрока.ФПД = РезультатЗапроса.Fields("FPD").Value;
		
		НоваяСтрока.ФН = РезультатЗапроса.Fields("AcumNumber").Value;
		
		НоваяСтрока.ФД = РезультатЗапроса.Fields("FD").Value;
		
		НоваяСтрока.СервисныйСборПроводки = РезультатЗапроса.Fields("UFSFEE").Value;

		НоваяСтрока.ОстальныеУслугиПроводки = РезультатЗапроса.Fields("SRV").Value;
		
		НоваяСтрока.Банк = РезультатЗапроса.Fields("Bank").Value;

		РезультатЗапроса.MoveNext();
		
	КонецЦикла; 
	
	РезультатЗапроса.Close();
	Соединение.Close();
	
	Возврат Данные;
	
КонецФункции

Функция ЗапросФискальнаяИнформацияПолнаяНовая()
	
	ТекстЗапроса = "SELECT acc.idtrans
	|,acc.directfee
	|,t.OrderPaymentId
	|,sum(acc.sumfee) as accfee
	|,sum(acc.sumsrv) as accsrv
	|,sum(acc.sum) as accsum 
	|,max(case when t.type = 14 then (-1)*t.amount else t.amount end) as transamount,max(t.fee) as transfee
	|INTO #ACC 
	|from  ufs_Accountings acc (NOLOCK)
	|JOIN Trans t (NOLOCK) on t.idtrans = acc.idtrans and t.status = 0  and t.test = 0
	|WHERE acc.phase = 1  and acc.tpstatus = 5 
	|and acc.datereg >= @BEGDate and acc.datereg < @ENDDate 
	|and acc.idpayer = 47072
	|Group BY t.OrderPaymentId,acc.idtrans,acc.directfee
	|
	|SELECT pm.Name as PaymentMethod
	|,acc.OrderPaymentId as OrderNumber
	|,sum(acc.transfee) as UFSFEE
	|,sum(acc.transamount) as SRV
	|INTO #FF
	|FROM #ACC acc (NOLOCK)
	|JOIN OrderPayment op (NOLOCK) on acc.OrderPaymentId = op.OrderPaymentId and op.Status = 0
	|JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId and pm.FiscaleReceipt = 1
	|WHERE
	|acc.directfee = 1
	|AND NOT EXISTS (Select top 1 1 FROM [dbo].[InnovativeMobilityCompare] IMC (NOLOCK) WHERE imc.IsExternallyLoaded = 1 and IMC.TransactionId = acc.idtrans)
	|AND NOT EXISTS (Select top 1 1 FROM [dbo].[SirenaCompare] SC (NOLOCK) WHERE SC.IsRefundThroughRzhd = 1 and SC.RzhdTransactionId = acc.idtrans and SC.IsSentReceiptBySupplier = 1)
	|GROUP BY pm.Name,acc.OrderPaymentId
	|   
	|SELECT  rp.name as ReceiptPositionName
	|,rp.Sum as SumPosition
	|,r.ReceiptTime as ReceiptTime
	|,r.Type as Type
	|,r.FiscalDocumentAttribute as FPD
	|,r.FiscalAcumNumber as AcumNumber
	|,r.FiscalDocumentNumber as FD
	|,case when rp.Name LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as UFSFEERECEIPT
	|,case when rp.Name NOT LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as SRVRECEIPT 
	|,FF.PaymentMethod as PaymentMethod  
	|,FF.OrderNumber as OrderNumber
	|,FF.UFSFEE as UFSFEE
	|,FF.SRV as SRV
	|INTO #NOBROKER
	|FROM #FF as FF LEFT JOIN OrderPaymentReceipt opmr (NOLOCK) on opmr.OrderPaymentId = FF.OrderNumber
	|JOIN Receipt r (NOLOCK) on r.ReceiptId = opmr.ReceiptId  and r.IsTest = 0 and not r.FiscalDocumentAttribute = '' --если есть фискальный номер, значит он в налоговой
	|LEFT JOIN ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId 
	|
	|Select NB.FPD as FPD
	|,NB.ReceiptTime as ReceiptTime
	|,NB.Type as Type
	|,NB.FD as FD
	|,NB.AcumNumber as AcumNumber
	|,NB.UFSFEERECEIPT as UFSFEERECEIPT
	|,NB.SRVRECEIPT as SRVRECEIPT 
	|,NB.ReceiptPositionName as ReceiptPositionName
	|,NB.SumPosition as SumPosition 
	|,NB.orderNumber as orderNumber
	|,NB.PaymentMethod as PaymentMethod
	|,NB.UFSFEE as UFSFEE
	|,NB.SRV as SRV 
	|,max(case when mem.nameMember is NUll then NB.PaymentMethod else mem.nameMember end) as BANK
	|From #NOBROKER NB (NOLOCK)
	|LEFT JOIN OrderBrokerPayment opm (NOLOCK) on opm.OrderPaymentId = NB.orderNumber
	|LEFT JOIN members mem (NOLOCK) on mem.idMember = opm.BrokerId and paytool = 6
	|Group BY NB.FPD,NB.ReceiptTime,NB.Type,NB.FD,NB.AcumNumber,NB.UFSFEERECEIPT,NB.SRVRECEIPT,NB.ReceiptPositionName,NB.SumPosition,NB.orderNumber,NB.PaymentMethod,NB.UFSFEE,NB.SRV  
	| 
	|DROP TABLE #ACC
	|DROP TABLE #FF
	|DROP TABLE #NOBROKER";
	
	Возврат ТекстЗапроса;
	
КонецФункции

//Устарело?
Функция ЗапросФискальнаяИнформацияПолнаяНовая2()
	
	ТекстЗапроса = "	  
   |  SELECT acc.idtrans, acc.directfee, sum(acc.sumfee) as accfee, sum(acc.sumsrv) as accsrv,sum(acc.sum) as accsum ,max(case when t.type = 14 then (-1)*t.amount else t.amount end) as transamount,max(t.fee) as transfee into #ACC  from  ufs_Accountings acc (NOLOCK) JOIN Trans t on t.idtrans = acc.idtrans WHERE acc.phase = 1  and acc.tpstatus = 5 and  acc.datereg >= @BEGDate and acc.datereg < @ENDDate and acc.idpayer = 47072  Group BY acc.idtrans,acc.directfee
   |  SELECT pm.Name as PaymentMethod
   | ,op.OrderPaymentId as OrderNumber
   | ,mem.nameMember as BANK
   | ,sum(acc.transfee) as UFSFEE
   | ,sum(acc.transamount) as SRV
   | INTO #FF
   | FROM #ACC acc (NOLOCK)
   | JOIN Trans t (NOLOCK) on acc.idtrans = t.idtrans and t.status = 0  and t.test = 0
   | JOIN OrderPayment op (NOLOCK) on t.OrderPaymentId = op.OrderPaymentId and op.Status = 0
   | JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId and pm.FiscaleReceipt = 1
   //| JOIN OrderBrokerPayment opm on opm.OrderPaymentId = t.OrderPaymentId 
   |JOIN members mem (NOLOCK) on mem.idMember = op.PayBrokerId
   | WHERE
   | acc.directfee = 1
   | AND NOT EXISTS (Select top 1 1 FROM [dbo].[InnovativeMobilityCompare] IMC (NOLOCK) WHERE imc.IsExternallyLoaded = 1 and IMC.TransactionId = t.idtrans)
   | AND NOT EXISTS (Select top 1 1 FROM [dbo].[SirenaCompare] SC (NOLOCK) WHERE SC.IsRefundThroughRzhd = 1 and SC.RzhdTransactionId = t.idtrans and SC.IsSentReceiptBySupplier = 1)
   | GROUP BY pm.Name,op.OrderPaymentId,mem.nameMember
   | SELECT  rp.name as ReceiptPositionName
   | ,rp.Sum as SumPosition
   | ,r.ReceiptTime as ReceiptTime
   | ,r.Type as Type
   | ,r.FiscalDocumentAttribute as FPD
   | ,r.FiscalAcumNumber as AcumNumber
   | ,r.FiscalDocumentNumber as FD
   | ,case when rp.Name LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as UFSFEERECEIPT
   | ,case when rp.Name NOT LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as SRVRECEIPT 
   | ,FF.PaymentMethod as PaymentMethod  
   | ,FF.OrderNumber as OrderNumber
   | ,FF.UFSFEE as UFSFEE
   | ,FF.SRV as SRV
   | ,FF.Bank as Bank
   | FROM #FF as FF LEFT JOIN OrderPaymentReceipt opmr (NOLOCK) on opmr.OrderPaymentId = FF.OrderNumber
   | JOIN Receipt r (NOLOCK) on r.ReceiptId = opmr.ReceiptId  and r.IsTest = 0 and not r.FiscalDocumentAttribute = '' --если есть фискальный номер, значит он в налоговой
   | LEFT JOIN ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId   
   | DROP TABLE #ACC
   | DROP TABLE #FF";
	
	Возврат ТекстЗапроса;
		
КонецФункции

Функция ПодготовитьТзСЧекамиПолнаяИнформация()
		
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("НаименованиеПозиции",ОбщегоНазначения.ОписаниеТипаСтрока(150),"Наименование");
	ТЗ.Колонки.Добавить("Сумма",ОбщегоНазначения.ОписаниеТипаЧисло(15,,ДопустимыйЗнак.Неотрицательный),"Сумма");
	ТЗ.Колонки.Добавить("ДатаВремя",ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.ДатаВремя),"ДатаВремя");
	ТЗ.Колонки.Добавить("ТипЧека",ОбщегоНазначения.ОписаниеТипаЧисло(15,0,ДопустимыйЗнак.Неотрицательный),"ТипЧека");
	ТЗ.Колонки.Добавить("ФПД",ОбщегоНазначения.ОписаниеТипаСтрока(150),"ФПД");
	ТЗ.Колонки.Добавить("ФН",ОбщегоНазначения.ОписаниеТипаСтрока(150),"ФН");
	ТЗ.Колонки.Добавить("ФД",ОбщегоНазначения.ОписаниеТипаСтрока(150),"ФД");
	
	ТЗ.Колонки.Добавить("СпособОплаты",ОбщегоНазначения.ОписаниеТипаСтрока(150),"СпособОплаты");
	ТЗ.Колонки.Добавить("Платеж",ОбщегоНазначения.ОписаниеТипаЧисло(15,,ДопустимыйЗнак.Неотрицательный),"Платеж");
	ТЗ.Колонки.Добавить("СервисныйСбор",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"СервисныйСбор");
	ТЗ.Колонки.Добавить("ОстальныеУслуги",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"ОстальныеУслуги");
	ТЗ.Колонки.Добавить("СервисныйСборПроводки",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"СервисныйСборПроводки");
	ТЗ.Колонки.Добавить("ОстальныеУслугиПроводки",ОбщегоНазначения.ОписаниеТипаЧисло(15,2,ДопустимыйЗнак.Любой),"ОстальныеУслугиПроводки");
	ТЗ.Колонки.Добавить("Банк",ОбщегоНазначения.ОписаниеТипаСтрока(150),"Банк");

	Возврат ТЗ;
	
КонецФункции
#КонецОбласти

#Область ДанныеПоКассам
//устарело
Функция ЗапросДанныеПоКассам2()
	
	ТекстЗапроса = "Select r.ReceiptId
	|,r.FiscalDocumentAttribute
	|,r.ReceiptTime
	|,r.FiscalDocumentNumber
	|,r.FiscalAcumNumber
	|,r.Type 
	|INTO #RECEIPTS  
	|FROM Receipt r (NOLOCK) 
	|Where R.ReceiptTime >= @BEGDate and R.ReceiptTime < @ENDDate and r.IsTest = 0 and NOT r.FiscalDocumentAttribute = '' 
	|
	|Select r.FiscalDocumentAttribute as FPD
	|,r.ReceiptTime as ReceiptTime
	|,r.Type as Type
	|,r.FiscalDocumentNumber as FD
	|,r.FiscalAcumNumber as AcumNumber
	|,case when rp.Name LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as UFSFEERECEIPT
	|,case when rp.Name NOT LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as SRVRECEIPT 
	|,rp.Name as ReceiptPositionName
	|,case when r.Type = 1 then rp.sum else rp.sum*(-1) end as SumPosition
	|,op.OrderPaymentId as orderNumber
	|,pm.Name as PaymentMethod 
	|,mem.nameMember as BANK
	|From #RECEIPTS r (NOLOCK) 
	|JOIN ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId
	|JOIN OrderPaymentReceipt opmr (NOLOCK) on opmr.ReceiptId = r.ReceiptId
	|JOIN OrderPayment op (NOLOCK) on op.OrderPaymentId = opmr.OrderPaymentId
	|JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId
	|JOIN OrderBrokerPayment opm (NOLOCK) on opm.OrderPaymentId = op.OrderPaymentId 
	|JOIN members mem (NOLOCK) on mem.idMember = opm.BrokerId
	|DROP TABLE #RECEIPTS";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ЗапросДанныеПоКассам()
	
	ТекстЗапроса = "Select r.ReceiptId
	|,r.FiscalDocumentAttribute
	|,r.ReceiptTime
	|,r.FiscalDocumentNumber
	|,r.FiscalAcumNumber
	|,r.Type 
	|INTO #RECEIPTS  
	|FROM Receipt r (NOLOCK) 
	|Where R.ReceiptTime >= @BEGDate and R.ReceiptTime < @ENDDate and r.IsTest = 0 and NOT r.FiscalDocumentAttribute = '' 
	|
	|Select r.FiscalDocumentAttribute as FPD
	|,r.ReceiptTime as ReceiptTime
	|,r.Type as Type
	|,r.FiscalDocumentNumber as FD
	|,r.FiscalAcumNumber as AcumNumber
	|,case when rp.Name LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as UFSFEERECEIPT
	|,case when rp.Name NOT LIKE '%Сервисный сбор%' then case when r.Type = 1 then rp.sum else rp.sum*(-1) end else 0 end as SRVRECEIPT 
	|,rp.Name as ReceiptPositionName
	|,case when r.Type = 1 then rp.sum else rp.sum*(-1) end as SumPosition
	|,op.OrderPaymentId as orderNumber
	|,pm.Name as PaymentMethod 
	|INTO #NOBROKER
	|From #RECEIPTS r (NOLOCK) 
	|JOIN ReceiptPosition rp (NOLOCK) on rp.ReceiptId = r.ReceiptId
	|JOIN OrderPaymentReceipt opmr (NOLOCK) on opmr.ReceiptId = r.ReceiptId
	|JOIN OrderPayment op (NOLOCK) on op.OrderPaymentId = opmr.OrderPaymentId
	|JOIN PaymentMethod pm (NOLOCK) on pm.PaymentMethodId = op.PaymentMethodId
	|
	|Select NB.FPD as FPD
	|,NB.ReceiptTime as ReceiptTime
	|,NB.Type as Type
	|,NB.FD as FD
	|,NB.AcumNumber as AcumNumber
	|,NB.UFSFEERECEIPT as UFSFEERECEIPT
	|,NB.SRVRECEIPT as SRVRECEIPT 
	|,NB.ReceiptPositionName as ReceiptPositionName
	|,NB.SumPosition as SumPosition 
	|,NB.orderNumber as orderNumber
	|,NB.PaymentMethod as PaymentMethod 
	|,max(case when mem.nameMember is NUll then NB.PaymentMethod else mem.nameMember end) as BANK
	|From #NOBROKER NB (NOLOCK)
	|LEFT JOIN OrderBrokerPayment opm (NOLOCK) on opm.OrderPaymentId = NB.orderNumber
	|LEFT JOIN members mem (NOLOCK) on mem.idMember = opm.BrokerId and paytool = 6
	|Group BY NB.FPD,NB.ReceiptTime,NB.Type,NB.FD,NB.AcumNumber,NB.UFSFEERECEIPT,NB.SRVRECEIPT,NB.ReceiptPositionName,NB.SumPosition,NB.orderNumber,NB.PaymentMethod
	|
	|DROP TABLE #RECEIPTS
	|DROP TABLE #NOBROKER ";
	
	Возврат ТекстЗапроса;
	
КонецФункции


Функция ФискальнаяИнформацияПоКассам(ДатаНачала,ДатаОкончания)
	
	ТекстЗапросаНачало = ОбъявитьНачалоЗапроса();
	ТекстЗапросаДаты = ОбъявитьДаты(ДатаНачала,ДатаОкончания);
	ТелоЗапрос = ЗапросДанныеПоКассам();
	Запрос = ТекстЗапросаНачало +  " " + Символы.ПС + " " + ТекстЗапросаДаты + " " + Символы.ПС +  " " + ТелоЗапрос;

	Соединение = СоединениеСБазой();
	РезультатЗапроса = Соединение.Execute(Запрос);
	
	Данные = ПодготовитьТзСЧекамиПолнаяИнформация();

	Пока НЕ РезультатЗапроса.EOF() Цикл
		
		НоваяСтрока = Данные.Добавить();
		
		НоваяСтрока.СпособОплаты = РезультатЗапроса.Fields("PaymentMethod").Value;
		
		Попытка
			НоваяСтрока.СервисныйСбор = Число(РезультатЗапроса.Fields("UFSFEERECEIPT").Value);
		Исключение
			НоваяСтрока.СервисныйСбор = 0;
		КонецПопытки;
		
		Попытка
			НоваяСтрока.ОстальныеУслуги = Число(РезультатЗапроса.Fields("SRVRECEIPT").Value);
		Исключение
			НоваяСтрока.ОстальныеУслуги = 0;	
		КонецПопытки;

		
		НоваяСтрока.НаименованиеПозиции = РезультатЗапроса.Fields("ReceiptPositionName").Value;
		
		НоваяСтрока.Платеж = Формат(Число(РезультатЗапроса.Fields("OrderNumber").Value),"ЧЦ=15; ЧДЦ=0; ЧН=0; ЧГ=0");	
		
			
		    НоваяСтрока.ДатаВремя = РезультатЗапроса.Fields("ReceiptTime").Value;
			
		Попытка
			НоваяСтрока.ТипЧека = Число(РезультатЗапроса.Fields("Type").Value);
		Исключение
			НоваяСтрока.ТипЧека = 0;
		КонецПопытки;
		
		Попытка
			
			НоваяСтрока.Сумма = Число(РезультатЗапроса.Fields("SumPosition").Value);
		Исключение
			НоваяСтрока.Сумма = 0;
		КонецПопытки;
		
		
		НоваяСтрока.ФПД = РезультатЗапроса.Fields("FPD").Value;
		
		НоваяСтрока.ФН = РезультатЗапроса.Fields("AcumNumber").Value;
		
		НоваяСтрока.ФД = РезультатЗапроса.Fields("FD").Value;
		
		НоваяСтрока.Банк = РезультатЗапроса.Fields("BANK").Value;
		
		
		РезультатЗапроса.MoveNext();
		
	КонецЦикла; 
	
	РезультатЗапроса.Close();
	Соединение.Close();
	
	Возврат Данные;
	
КонецФункции
#КонецОбласти
	
//Обработка таблицы вторичных данных по Платеж основной
Функция ОбработатьВторичнуюТаблицуПоТаблицеЗагрузки(ВсеПлатежи,ПлатежиФиск) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	Платежи.Платеж
	               |ПОМЕСТИТЬ ФискализированныеПлатежи
	               |ИЗ
	               |	&Платежи КАК Платежи
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	*
				   |ПОМЕСТИТЬ ВсеПлатежи
	               |ИЗ
	               |	&ВсеПлатежи КАК ВсеПлатежи
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	*
	               |ИЗ
	               |	ВсеПлатежи КАК ВсеПлатежи
	               |		Левое СОЕДИНЕНИЕ ФискализированныеПлатежи КАК ФискализированныеПлатежи
	               |		ПО ВсеПлатежи.Платеж = ФискализированныеПлатежи.Платеж
				   | ГДЕ ФискализированныеПлатежи.Платеж Есть NULL";
	
	Запрос.УстановитьПараметр("Платежи",ПлатежиФиск);	
	Запрос.УстановитьПараметр("ВсеПлатежи",ВсеПлатежи);
	НеФиск = Запрос.Выполнить().Выгрузить();
	
	Возврат НеФиск;
	
КонецФункции

