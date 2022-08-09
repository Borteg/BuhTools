
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	НастройкиКомпоновки = КомпоновщикНастроек.ПолучитьНастройки();
	
	ПараметрПериодКомпоновки = Новый ПараметрКомпоновкиДанных("Период");
	ПараметрПериод = НастройкиКомпоновки.ПараметрыДанных.НайтиЗначениеПараметра(ПараметрПериодКомпоновки);
	
	ПараметрСравниватьКомпоновки = Новый ПараметрКомпоновкиДанных("Сравнивать");
	
	ПараметрСравнивать = НастройкиКомпоновки.ПараметрыДанных.НайтиЗначениеПараметра(ПараметрСравниватьКомпоновки);
	
	ДатаНачала = ПараметрПериод.Значение.ДатаНачала;
	ДатаОкончания = ПараметрПериод.Значение.ДатаОкончания+1;
	
	
	СтруктураТаблицСДаннымиУФС = ПолучитьДанныеУФС(ДатаНачала,ДатаОкончания);
	СтруктураТаблицСДаннымиАвтобусов = ПолучитьДанныеУФСАвтобусы(ДатаНачала,ДатаОкончания);
	
	Если ПараметрСравнивать.Значение = Ложь Тогда
		
		
		КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
		
		МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,НастройкиКомпоновки); 
		
		
		ВнешниеНаборы = Новый Структура("ТаблицаПокупок,ТаблицаВозвратов,ТаблицаПокупокАвтобусы,ТаблицаВозвратовАвтобусы",СтруктураТаблицСДаннымиУФС.ТаблицаПокупок,СтруктураТаблицСДаннымиУФС.ТаблицаВозвратов,СтруктураТаблицСДаннымиАвтобусов.ТаблицаПокупок,СтруктураТаблицСДаннымиАвтобусов.ТаблицаВозвратов);
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
		ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
		ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
		ПроцессорВывода.Вывести(ПроцессорКомпоновки);
		
	Иначе
		
		Если ЭтоАдресВременногоХранилища(АдресТЗ) Тогда
			ДанныеТЗ = ПолучитьИзВременногоХранилища(АдресТЗ);
			Если ДанныеТЗ<>Неопределено Тогда
				КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
				
				МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,НастройкиКомпоновки,,,Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений")); 
				
				
				ВнешниеНаборы = Новый Структура("ТаблицаПокупок,ТаблицаВозвратов,ТаблицаПокупокАвтобусы,ТаблицаВозвратовАвтобусы",СтруктураТаблицСДаннымиУФС.ТаблицаПокупок,СтруктураТаблицСДаннымиУФС.ТаблицаВозвратов,СтруктураТаблицСДаннымиАвтобусов.ТаблицаПокупок,СтруктураТаблицСДаннымиАвтобусов.ТаблицаВозвратов);
				ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
				ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
				ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
				ТаблицаСДанными = ПроцессорВывода.Вывести(ПроцессорКомпоновки);
				ТаблицаСДанными.Удалить(ТаблицаСДанными.Количество() -1);
				
				ТаблицаСДаннымИм = ТаблицаСДанными.Скопировать();
				
				ТаблицаСДаннымИм.Очистить();
				
				ОбработатьФайлИм(АдресТЗ,ТаблицаСДаннымИм);
				
				Запрос  = Новый Запрос;
				Запрос.Текст =  "ВЫБРАТЬ
				|	ДанныеУФС.День КАК День,
				|	ДанныеУФС.КолвоМест КАК КолвоМест,
				|	ДанныеУФС.Сумма КАК Сумма,
				|	ДанныеУФС.Итого КАК Итого,
				|	ДанныеУФС.СборИМ КАК СборИМ,
				|	ДанныеУФС.КолвоМестВозвратов КАК КолвоМестВозвратов,
				|	ДанныеУФС.СуммаВозвратов КАК СуммаВозвратов
				|ПОМЕСТИТЬ ДанныеУФС
				|ИЗ
				|	&ДанныеУФС КАК ДанныеУФС
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ
				|	ДанныеИм.День КАК ДеньИМ,
				|	ДанныеИм.КолвоМест КАК КолвоМестИМ,
				|	ДанныеИм.КолвоМестВозвратов КАК КолвоМестВозвратовИМ,
				|	ДанныеИм.Сумма КАК СуммаИМ,
				|	ДанныеИм.СуммаВозвратов КАК СуммаВозвратовИМ,
				|	ДанныеИм.Итого КАК ИтогоИМ,
				|	ДанныеИм.СборИм КАК СборИмИМ
				|ПОМЕСТИТЬ ДанныеИм
				|ИЗ
				|	&ДанныеИм КАК ДанныеИм
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ
				|	ДанныеИм.ДеньИМ КАК ДеньИМ,
				|	ЕстьNULL(ДанныеИм.КолвоМестИМ,0) КАК КолвоМестИМ,
				|	ЕстьNULL(ДанныеИм.КолвоМестВозвратовИМ,0) КАК КолвоМестВозвратовИМ,
				|	ЕстьNULL(ДанныеИм.СуммаИМ,0) КАК СуммаИМ,
				|	ЕстьNULL(ДанныеИм.СуммаВозвратовИМ,0) КАК СуммаВозвратовИМ,
				|	ЕстьNULL(ДанныеИм.ИтогоИМ,0) КАК ИтогоИМ,
				|	ЕстьNULL(ДанныеИм.СборИмИМ,0) КАК СборИмИМ,
				|	ДанныеУФС.День КАК День,
				|	ЕстьNULL(ДанныеУФС.КолвоМест,0) КАК КолвоМест,
				|	ЕстьNULL(ДанныеУФС.Сумма,0) КАК Сумма,
				|	ЕстьNULL(ДанныеУФС.Итого,0) КАК Итого,
				|	ЕстьNULL(ДанныеУФС.СборИМ,0) КАК СборИМ,
				|	ЕстьNULL(ДанныеУФС.КолвоМестВозвратов,0) КАК КолвоМестВозвратов,
				|	ЕстьNULL(ДанныеУФС.СуммаВозвратов,0) КАК СуммаВозвратов
				|ИЗ
				|	ДанныеУФС КАК ДанныеУФС
				|		ПОЛНОЕ СОЕДИНЕНИЕ ДанныеИм КАК ДанныеИм
				|		ПО ДанныеУФС.День = ДанныеИм.ДеньИМ";
				
				Запрос.УстановитьПараметр("ДанныеИм",ТаблицаСДаннымИм);
				Запрос.УстановитьПараметр("ДанныеУФС",ТаблицаСДанными);
				ТЗ = Запрос.Выполнить().Выгрузить();
				
				КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
				
				СКДСравнения = ПолучитьМакет("МакетСравнения");
				
				МакетКомпоновки = КомпоновщикМакета.Выполнить(СКДСравнения,	СКДСравнения.НастройкиПоУмолчанию); 
				
				
				ВнешниеНаборы = Новый Структура("ДанныеСравнения",ТЗ);
				ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
				ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборы);
				ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
				ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
				ПроцессорВывода.Вывести(ПроцессорКомпоновки);
				
			КонецЕсли;
		КонецЕсли;
		
		
		
	КонецЕсли;
	
	
	
КонецПроцедуры

Функция ОбработатьФайлИм(АдресВХранилище,ТаблицаСДанными) Экспорт
	
	ПомещенныеФайлы = ПолучитьИзВременногоХранилища(АдресВХранилище);
	
	АдресФайлаИМ = ПомещенныеФайлы[0].Хранение;
	ИмяФайлаИМ  = ПомещенныеФайлы[0].Имя;
	
	РасширениеФайла = ПолучитьРасширениеИмениФайла(ИмяФайлаИМ);
	ДвоичныеДанныеИМ = ПолучитьИзВременногоХранилища(АдресФайлаИМ);	
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	ДвоичныеДанныеИМ.Записать(ИмяВременногоФайла);
	
	//СonnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source= "  + СокрЛП(ИмяВременногоФайла) + ";Extended Properties=""Excel 8.0;HDR=YES;IMEX=1;""";
	        СonnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source= " + СокрЛП(ИмяВременногоФайла) + ";Extended Properties=""Excel 12.0;HDR=YES;IMEX=1;""";
	ADODBConnection = Новый COMОбъект("ADODB.Connection");
	ADODBConnection.ConnectionString =  СonnectionString;
	ADODBConnection.Open();
	ADODBConnection.CursorLocation = 3;
	
	ТекстЗапроса = "SELECT * FROM [" + "Report" + "$]";
	
	ADODBRecordset = Новый COMОбъект("ADODB.Recordset");
	ADODBRecordset.Open(ТекстЗапроса, ADODBConnection);
	
	
	НомерСтрокиНачало = 6;
	
	НомерКолонкиДень = 0;
	НомерКолонкиПродажаМест = 2;
	НомерКолонкиСуммаПродажа = 3;
	
	НомерКолонкиВозвратМест = 5;
	НомерКолонкиВозвратСумма = 6;
	НомерКолонкиИтого = 7;
	НомерКолонкиСборИм = 8;
	
	НомерСтроки = 0;
	
	Пока НЕ ADODBRecordset.EOF() Цикл
		
		//Если НомерСтроки < НомерСтрокиНачало Тогда
		//	НомерСтроки = НомерСтроки +1;
		//	ADODBRecordset.MoveNext();
		//	Продолжить;
		//КонецЕсли;
		ЗначениеДень = ADODBRecordset.Fields.Item(НомерКолонкиДень).Value;
		Попытка
			МассивДень  = СтрРазделить(ЗначениеДень,".");
			
			ДатаДень = Дата(МассивДень[2],МассивДень[1],МассивДень[0]);
		Исключение
			ADODBRecordset.MoveNext();
			Продолжить;
			
		КонецПопытки;
		НоваяСтрокаИм = ТаблицаСДанными.Добавить();
		НоваяСтрокаИм.День = ДатаДень;
		НоваяСтрокаИм.КолВоМест =  ADODBRecordset.Fields.Item(НомерКолонкиПродажаМест).Value;
		НоваяСтрокаИм.Сумма =  ADODBRecordset.Fields.Item(НомерКолонкиСуммаПродажа).Value;
		НоваяСтрокаИм.КолВоМестВозвратов  =  ADODBRecordset.Fields.Item(НомерКолонкиВозвратМест).Value;
		НоваяСтрокаИм.СуммаВозвратов =  ADODBRecordset.Fields.Item(НомерКолонкиВозвратСумма).Value;
		НоваяСтрокаИм.Итого =  ADODBRecordset.Fields.Item(НомерКолонкиИтого).Value;
		НоваяСтрокаИм.СборИм  =  ADODBRecordset.Fields.Item(НомерКолонкиСборИм).Value;
		ADODBRecordset.MoveNext();
		
	КонецЦикла;
	ADODBRecordset.Close();
	
	ADODBConnection.Close();

	МассивДляУдаления = Новый Массив;
	
	Для Каждого Строка Из ТаблицаСДанными Цикл
		Если ТипЗнч(Строка["День"]) <> Тип("Дата") Тогда
			МассивДляУдаления.Добавить(Строка);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого СтрокаУдаления Из МассивДляУдаления Цикл
		ТаблицаСДанными.Удалить(СтрокаУдаления);
	КонецЦикла;
	
КонецФункции


Функция ПодготовитьПустуюТаблицу()
	
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("День",ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата),"День");
	ТЗ.Колонки.Добавить("ТипОперации",ОбщегоНазначения.ОписаниеТипаСтрока(50),"Тип операции");
	ТЗ.Колонки.Добавить("КолВоМест",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),"Кол-во мест");
	ТЗ.Колонки.Добавить("Сумма",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),"Сумма");
	ТЗ.Колонки.Добавить("СуммаСбораИм",ОбщегоНазначения.ОписаниеТипаЧисло(15,2),"Сумма сбора ИМ");
	
	ТЗ.Колонки.Добавить("Направление",Новый ОписаниеТипов("ПеречислениеСсылка.Направления"),"Направление");

	Возврат ТЗ;
	
КонецФункции

Функция ПолучитьДанныеУФС(ДатаНачала,ДатаОкончания)
	
	СтруктураДанных = Новый Структура;
	
	
	ДатаНачалаСтрока = Формат(ДатаНачала,"ДФ=yyyyMMdd");
	ДатаОкончанияСтрока = Формат(ДатаОкончания,"ДФ=yyyyMMdd");
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_R");
	
	ТекстЗапроса = "set transaction isolation level read uncommitted
	|SET NOCOUNT ON
	|declare @begdate datetime, @enddate datetime, @test bit
	|
	|set @begdate = '"+ДатаНачалаСтрока+"'
	|set @enddate = '"+ДатаОкончанияСтрока+"'
	|	set @test = 0
	|	select 
	|	convert(date, t.ConfirmDate) as 'День',
	|	case
	|	when t.type = 1 then 'Покупка' 
	|else 'Возврат'
	|	end as 'Тип операции',
	|	sum(a.qtyfee) as 'Кол-во мест',
	|	sum(a.sumsrv) as 'Сумма',
	|	sum(a.sumfee) as 'Сумма сбора ИМ'
	|	from Trans t
	|	inner join ufs_Accountings a on t.idtrans = a.idtrans
	|	where t.idServ = 103 and t.status = 0 and t.test = @test and a.phase = 2 and a.tpstatus = 5
	|	and t.ConfirmDate >= @begdate and t.ConfirmDate < @enddate  and t.idtaker=53951
	|	group by convert(date, t.ConfirmDate), t.type
	|	order by 1,2 desc";
	
	RecordSet = Connection.Execute(ТекстЗапроса);
	
	ТаблицаСДаннымиПокупок = ПодготовитьПустуюТаблицу();
	ТаблицаСДаннымиВозвратов = ПодготовитьПустуюТаблицу();
	Пока НЕ RecordSet.EOF() Цикл
		
		Если RecordSet.Fields("Тип операции").Value = "Покупка" Тогда	
			НоваяСтрока = ТаблицаСДаннымиПокупок.Добавить();			
			НоваяСтрока.Сумма = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Сумма").Value);
		Иначе
			НоваяСтрока = ТаблицаСДаннымиВозвратов.Добавить();
			НоваяСтрока.Сумма = ПреобзоватьДанныеКЧислуИзЗапроса((-1)*RecordSet.Fields("Сумма").Value);
		КонецЕсли;
		
		ДатаДляПреобразования = RecordSet.Fields("День").Value;
		ДатаДляПреобразования = СтрЗаменить(ДатаДляПреобразования,"-","");
		ДатаВТЗ = Дата(ДатаДляПреобразования);
		НоваяСтрока.День = ДатаВТЗ;
		
		НоваяСтрока.ТипОперации = RecordSet.Fields("Тип операции").Value;
		НоваяСтрока.КолВоМест = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Кол-во мест").Value);
		
		НоваяСтрока.СуммаСбораИм = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Сумма сбора ИМ").Value);
	     НоваяСтрока.Направление = Перечисления.Направления.ЖД;

		RecordSet.MoveNext();
		
	КонецЦикла;
	
	RecordSet.Close();
	
	Connection.Close();
	
	СтруктураДанных.Вставить("ТаблицаПокупок",ТаблицаСДаннымиПокупок);
	СтруктураДанных.Вставить("ТаблицаВозвратов",ТаблицаСДаннымиВозвратов);
	
	Возврат СтруктураДанных;
	
КонецФункции


Функция ПреобзоватьДанныеКЧислуИзЗапроса(Значение)
	
	ПреобразованиеЧисло = 0;
	
	Попытка
		ПреобразованиеЧисло = Число(Значение);
	Исключение
		ПреобразованиеЧисло = 0;
	КонецПопытки;
	
	Возврат ПреобразованиеЧисло;
КонецФункции


Функция ПолучитьДанныеУФСАвтобусы(ДатаНачала,ДатаОкончания)
	
	СтруктураДанных = Новый Структура;
	
	
	ДатаНачалаСтрока = Формат(ДатаНачала,"ДФ=yyyyMMdd");
	ДатаОкончанияСтрока = Формат(ДатаОкончания,"ДФ=yyyyMMdd");
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_R");
	
	ТекстЗапроса = "set transaction isolation level read uncommitted
	|SET NOCOUNT ON
	|declare @begdate datetime, @enddate datetime, @test bit
	|
	|set @begdate = '"+ДатаНачалаСтрока+"'
	|set @enddate = '"+ДатаОкончанияСтрока+"'
	|	set @test = 0
	|	select 
	|	convert(date, t.ConfirmDate) as 'День',
	|	case
	|	when t.type = 1 then 'Покупка' 
	|else 'Возврат'
	|	end as 'Тип операции',
	|	sum(a.qtyfee) as 'Кол-во мест',
	|	sum(a.sumsrv) as 'Сумма',
	|	sum(a.sumfee) as 'Сумма сбора ИМ'
	|	from Trans t
	|	inner join ufs_Accountings a on t.idtrans = a.idtrans
	|	where t.idServ = 1127 and t.status = 0 and t.test = @test and a.phase = 2 and a.tpstatus = 5
	|	and t.ConfirmDate >= @begdate and t.ConfirmDate < @enddate  and t.idtaker=53951
	|	group by convert(date, t.ConfirmDate), t.type
	|	order by 1,2 desc";
	
	RecordSet = Connection.Execute(ТекстЗапроса);
	
	ТаблицаСДаннымиПокупок = ПодготовитьПустуюТаблицу();
	ТаблицаСДаннымиВозвратов = ПодготовитьПустуюТаблицу();
	Пока НЕ RecordSet.EOF() Цикл
		
		Если RecordSet.Fields("Тип операции").Value = "Покупка" Тогда	
			НоваяСтрока = ТаблицаСДаннымиПокупок.Добавить();
			НоваяСтрока.Сумма = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Сумма").Value);
		Иначе
			НоваяСтрока = ТаблицаСДаннымиВозвратов.Добавить();
			НоваяСтрока.Сумма = ПреобзоватьДанныеКЧислуИзЗапроса((-1)*RecordSet.Fields("Сумма").Value);
		КонецЕсли;
		
		ДатаДляПреобразования = RecordSet.Fields("День").Value;
		ДатаДляПреобразования = СтрЗаменить(ДатаДляПреобразования,"-","");
		ДатаВТЗ = Дата(ДатаДляПреобразования);
		НоваяСтрока.День = ДатаВТЗ;
		
		НоваяСтрока.ТипОперации = RecordSet.Fields("Тип операции").Value;
		НоваяСтрока.КолВоМест = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Кол-во мест").Value);
		
		НоваяСтрока.СуммаСбораИм = ПреобзоватьДанныеКЧислуИзЗапроса(RecordSet.Fields("Сумма сбора ИМ").Value);
	     НоваяСтрока.Направление = Перечисления.Направления.Автобусы;

		RecordSet.MoveNext();
		
	КонецЦикла;
	
	RecordSet.Close();
	
	Connection.Close();
	
	СтруктураДанных.Вставить("ТаблицаПокупок",ТаблицаСДаннымиПокупок);
	СтруктураДанных.Вставить("ТаблицаВозвратов",ТаблицаСДаннымиВозвратов);
	
	Возврат СтруктураДанных;
	
КонецФункции

Функция ПолучитьРасширениеИмениФайла(Знач ИмяФайла) Экспорт
	
	Расширение = "";
	
	ПозицияСимвола = СтрДлина(ИмяФайла);
	Пока ПозицияСимвола >= 1 Цикл
		
		Если Сред(ИмяФайла, ПозицияСимвола, 1) = "." Тогда
			
			Расширение = Сред(ИмяФайла, ПозицияСимвола + 1);
			Прервать;
		КонецЕсли;
		
		ПозицияСимвола = ПозицияСимвола - 1;
	КонецЦикла;

	Возврат Расширение;
	
КонецФункции

