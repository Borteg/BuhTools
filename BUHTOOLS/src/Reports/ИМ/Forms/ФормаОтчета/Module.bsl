
&НаКлиенте
Процедура СравнитьСОтчетомИМ(Команда)
	// Вставить содержимое обработчика.
	
	ОповещениеПоместилиФайлИМ = Новый ОписаниеОповещения("ПомещениеФайлаИМОкончание",ЭтотОбъект);
	
	Режим = РежимДиалогаВыбораФайла.Открытие;
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим);
	ДиалогОткрытияФайла.ПолноеИмяФайла = ""; 
	Фильтр = НСтр("ru = 'Файлы Excel (*.xls;*.xlsx)|*.xls;*.xlsx");
	ДиалогОткрытияФайла.Фильтр = Фильтр;
	ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
    ДиалогОткрытияФайла.Заголовок = "Выберите файл отчета ИМ для сверки";

	НачатьПомещениеФайлов(ОповещениеПоместилиФайлИМ,,ДиалогОткрытияФайла,Истина, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПомещениеФайлаИМОкончание(ПомещенныеФайлы, ОбработчикЗавершения)  Экспорт
	
	Если ПомещенныеФайлы  = Неопределено Тогда
		Сообщить("Файл не был выбран");
	Иначе
		ОбработатьФайлИМ(ПомещенныеФайлы);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьФайлИМ(ПомещенныеФайлы)
	
	АдресВХранилище = ПоместитьВоВременноеХранилище(ПомещенныеФайлы,УникальныйИдентификатор);
	
	Отчет.АдресТЗ = АдресВХранилище;
	
	
КонецПроцедуры

