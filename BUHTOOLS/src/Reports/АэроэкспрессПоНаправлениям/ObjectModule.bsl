
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
		
	СтандартнаяОбработка  = Ложь;
	
	НастройкиПользователяУФС = КомпоновщикНастроек.ПолучитьНастройки();
	
	ПараметрПериодКомпоновки = Новый ПараметрКомпоновкиДанных("Период");
	ПараметрПериод = НастройкиПользователяУФС.ПараметрыДанных.НайтиЗначениеПараметра(ПараметрПериодКомпоновки);
	
	ДатаНачала = ПараметрПериод.Значение.ДатаНачала;
	ДатаОкончания = ПараметрПериод.Значение.ДатаОкончания;
	
	ДатаНачалаСтрока = Формат(ДатаНачала,"ДФ=yyyyMMdd");
	ДатаОкончанияСтрока = Формат(ДатаОкончания,"ДФ=yyyyMMdd");
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_R");
	
	ТекстЗапроса = "set transaction isolation level read uncommitted
	|SET NOCOUNT ON	
	| DECLARE @begDate DATETIME = '"+ДатаНачалаСтрока+"'
	| DECLARE @endDate DATETIME = '" +ДатаОкончанияСтрока+"' 
	|				select sum(case when t.type = 1 Then t.amount/o.nplace  else (-1)*t.amount/o.nplace end) as sum, 
	|				ISNULL(CASE WHEN m.idMember = 46354 THEN 'Физическое лицо' ELSE m.nameMember END,'Физическое лицо') as nameContr,
	|				case when ISNULL(CASE WHEN m.idMember = 46354 THEN 'Физическое лицо' ELSE m.nameMember END,'Физическое лицо') ='Физическое лицо' then mem2.member else 'Не учитывается' end  as TypeBroker,
	|				m.idmember as idmember
	|FROM	Trans t (NOLOCK) JOIN 
	|						orRzhdAE o (NOLOCK) ON t.idtrans = o.idtrans JOIN 
	|				AeroPassenger p (NOLOCK) ON p.TransId = t.idtrans JOIN
	|						members m (NOLOCK) ON t.idPayer = m.idMember LEFT JOIN
	|			pos (NOLOCK) ON pos.idpos = t.idPOS AND pos.idmember NOT IN (m.idMember,46354) LEFT JOIN		
	|				members m2 (NOLOCK) ON m2.idMember = pos.idmember OR (m.idparent_member NOT IN (0, 46354) 
	|				AND m.idparent_member = m2.idMember) left join OrderPayment op (NOLOCK) on op.OrderPaymentId = t.OrderPaymentId left join members mem2 (NOLOCK) on mem2.idMember = op.PayBrokerId 
	|				WHERE --Условия
	|				t.status = 0 --транзакция успешная
	|				AND t.test = 0 --не тестовая
	|			AND t.ConfirmDate>@begDate --Дата подтверждения с 2015-03-01
	|			AND t.ConfirmDate<DATEADD(dd,1,@endDate) --Дата подтверждения до 2015-03-11				
	|group by 
	|m.idmember,ISNULL(CASE WHEN m.idMember = 46354 THEN 'Физическое лицо' ELSE m.nameMember END,'Физическое лицо'),case when ISNULL(CASE WHEN m.idMember = 46354 THEN 'Физическое лицо' ELSE m.nameMember END,'Физическое лицо') ='Физическое лицо' then mem2.member else 'Не учитывается' end
	|ORDER BY 2";
	
	RecordSet = Connection.Execute(ТекстЗапроса);
	
	ТаблицаСДанными = Новый ТаблицаЗначений;
	ТаблицаСДанными.Колонки.Добавить("НаименованиеКонтрагента",ОбщегоНазначения.ОписаниеТипаСтрока(150),"Наименование контрагента");	
	ТаблицаСДанными.Колонки.Добавить("СуммаПродажи",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),"Сумма продажи");
	ТаблицаСДанными.Колонки.Добавить("Группировка",ОбщегоНазначения.ОписаниеТипаСтрока(25),"Группировка");
	ТаблицаСДанными.Колонки.Добавить("Кодагента",ОбщегоНазначения.ОписаниеТипаЧисло(15,0),"Код агента");
	Пока НЕ RecordSet.EOF() Цикл
		
		НоваяСтрока = ТаблицаСДанными.Добавить();
		НоваяСтрока.НаименованиеКонтрагента = RecordSet.Fields("nameContr").Value;  
			НоваяСтрока.Кодагента = RecordSet.Fields("idmember").Value;
		НоваяСтрока.СуммаПродажи = RecordSet.Fields("sum").Value;
		Если  СтрНайти(НоваяСтрока.НаименованиеКонтрагента,"Сбербанк Спасибо") > 0 Тогда
			НоваяСтрока.Группировка = "Сбербанк Спасибо";
		ИначеЕсли СтрНайти(НоваяСтрока.НаименованиеКонтрагента,"Физическое лицо") > 0 Тогда
			Брокер = RecordSet.Fields("TypeBroker").Value;
			НоваяСтрока.Группировка = "Сайт " +Брокер;
		Иначе
			НоваяСтрока.Группировка = "Агенты";
		КонецЕсли;
		
		RecordSet.MoveNext();
		
	КонецЦикла;    
	
	RecordSet.Close();
	Connection.Close();
	
	
	СхемаКомпоновкиДанных = Отчеты.АэроэкспрессПоНаправлениям.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,НастройкиПользователяУФС,,,,,);
	ВнешниеНаборы = Новый Структура("ТаблицаСДанными",ТаблицаСДанными);
	ПроцессорКомпоновки  = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
КонецПроцедуры
