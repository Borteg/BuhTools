
&НаКлиенте
Процедура ПрочитатьЧек(Команда)
	
	ОбработкаОкончанияПомещения = Новый ОписаниеОповещения
	("ОбработчикОкончанияПомещения", ЭтотОбъект);
	
	НачатьПомещениеФайлаНаСервер(ОбработкаОкончанияПомещения, , , , ,ЭтотОбъект.УникальныйИдентификатор);
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОкончанияПомещения(ОписаниеПомещенногоФайла, ДополнительныеПараметры) Экспорт
	
	Если НЕ ОписаниеПомещенногоФайла.ПомещениеФайлаОтменено Тогда
		ИмяФайлаЧека = ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя;
		СсылкаНаФайлВоВременномХранилище = ОписаниеПомещенногоФайла.Адрес;	
		Модифицированность = Истина; 
		РазобратьФайл(ОписаниеПомещенногоФайла.Адрес);
	Иначе
		Сообщить("Файл не был помещен.");
	КонецЕсли 
	
КонецПроцедуры

&НаСервере
Процедура РазобратьФайл(АдресВХранилище)
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВХранилище);
	
	ИмяФайла = ПолучитьИмяВременногоФайла();
	
	ДвоичныеДанные.Записать(ИмяФайла);
	
	Текст  = Новый ЧтениеТекста(ИмяФайла,КодировкаТекста.UTF8);
	
	СтрокаТекста = Текст.ПрочитатьСтроку();
	
	Если СтрокаТекста <> Неопределено Тогда
		ВидОперации = СтрокаТекста;
		Если СокрЛП(ВидОперации) = "Отчёт о регистрации" Тогда
			Объект.ВидЧека = Перечисления.ВидыЧеков.ОтчётРегистрации;
		ИначеЕсли СокрЛП(ВидОперации) = "Отчёт о перерегистрации" Тогда
			Объект.ВидЧека = Перечисления.ВидыЧеков.ОтчетПеререгистрации;	
		Иначе
			Объект.ВидЧека = Перечисления.ВидыЧеков.ОтчётЗакрытиеАрхива;		
		КонецЕсли;
		
	КонецЕсли;
	
	ДанныеЧека = СтруктураДанныхЧека();
	
	СоответствиеДанныхЧекаАТОЛ = ПолучитьСоответствиеДанныхЧекаАТОЛА();
	
	Пока  СтрокаТекста <> Неопределено Цикл
		
		ДанныеВСтроке = РазбитьСтроку(СтрокаТекста);
		
		Если ДанныеВСтроке.Количество() > 1 Тогда
			ТипДанных = СокрЛП(ДанныеВСтроке[0]);
			ПараметрЧека =  СоответствиеДанныхЧекаАТОЛ.Получить(ТипДанных);
			Если ПараметрЧека <> Неопределено Тогда
				ДанныеВСтроке.Удалить(0);
				ДанныеДляЧека = СокрЛП(СтрСоединить(ДанныеВСтроке,":"));
				ДанныеЧека[ПараметрЧека] = ДанныеДляЧека;			
			КонецЕсли;
		Иначе	
		КонецЕсли;
		
		СтрокаТекста = Текст.ПрочитатьСтроку();
		
	КонецЦикла;
	ДатаПреобразования = ДанныеЧека.Дата;
	ДатаВФормате = СтрЗаменить(ДатаПреобразования,"-","");
	ДатаВФормате = СтрЗаменить(ДатаВФормате,":","");
	ДатаВФормате = СтрЗаменить(ДатаВФормате," ","");
	Объект.Дата = Дата(ДатаВФормате);

	ЗаполнитьЗначенияСвойств(Объект,ДанныеЧека);
	Объект.Дата = Дата(ДатаВФормате);
	
	ЗаполнитьДанныеПоКассеИФН();
	
КонецПроцедуры

&НаСервере
Процедура  ЗаполнитьДанныеПоКассеИФН()
	// Вставить содержимое обработчика.
	Если Не ЗначениеЗаполнено(Объект.Касса) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =  "ВЫБРАТЬ
		|	Кассы.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Кассы КАК Кассы
		|ГДЕ
		|	Кассы.ЗаводскойНомер = &ЗаводскойНомер";
		Запрос.УстановитьПараметр("ЗаводскойНомер",Объект.завНомер);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда	
			Объект.Касса = Выборка.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.ФН) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ФН.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ФН КАК ФН
		|ГДЕ
		|	ФН.ЗаводскойНомер = &Номер";
		Запрос.УстановитьПараметр("Номер",Объект.ЗавНомерФН);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Объект.ФН = Выборка.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере 
Функция РазбитьСтроку(Строка)
	
	МассивДанных = 	СтрРазделить(Строка,":",Ложь);
	
	Возврат МассивДанных;	
	
КонецФункции

&НаСервере
Функция СтруктураДанныхЧека()
	
	ДанныеЧека = Новый Структура;
	
	//ДанныеЧека.Вставить("ВидЧека",);
	ДанныеЧека.Вставить("НаименованиеПользователя","");
	ДанныеЧека.Вставить("Адрес","");
	ДанныеЧека.Вставить("РНМ","");
	ДанныеЧека.Вставить("ЗавНомер","");
	ДанныеЧека.Вставить("СистемаНалогообложения","");
	ДанныеЧека.Вставить("АвтономныйРежим","");
	ДанныеЧека.Вставить("ПризнакУслуг","");
	ДанныеЧека.Вставить("ПризнакШифрования","");
	ДанныеЧека.Вставить("ПризнакРасчетовВИнтернете","");
	ДанныеЧека.Вставить("АвтоматическийРежим","");
	ДанныеЧека.Вставить("НомерАвтомата","");
	ДанныеЧека.Вставить("ИННОФД","");
	ДанныеЧека.Вставить("ПризнакПлатежногоАгента","");
	ДанныеЧека.Вставить("ПризнакУстановкиПринтераВАвтомате","");
	ДанныеЧека.Вставить("МестоРасчетов","");
	//ДанныеЧека.Вставить("АдресСайта","");
	ДанныеЧека.Вставить("АдресЭлектроннойПочты","");
	ДанныеЧека.Вставить("АдресСайтаФНС","");
	ДанныеЧека.Вставить("НаименованиеОФД","");
	ДанныеЧека.Вставить("ВерсияККТ","");
	ДанныеЧека.Вставить("ВерсияФФДККТ","");
	ДанныеЧека.Вставить("ВерсияФФД","");
	ДанныеЧека.Вставить("ЗавНомерФН","");
	ДанныеЧека.Вставить("ПорядковыйНомерФД","");
	ДанныеЧека.Вставить("ФП","");
	ДанныеЧека.Вставить("Дата",'0001-01-01');
	
	
	Возврат ДанныеЧека;
	
	
	
КонецФункции

&НаСервере
Функция ПолучитьСоответствиеДанныхЧекаАТОЛА()
	
	АтолДанные = Новый Соответствие;
	АтолДанные.Вставить("наименование пользователя","НаименованиеПользователя");
	АтолДанные.Вставить("адрес","Адрес");
	//АтолДанные.Добавить("ИНН пользователя","");
	АтолДанные.Вставить("рег. номер ККТ","РНМ");	
	АтолДанные.Вставить("зав. номер ККТ","ЗавНомер");	
	АтолДанные.Вставить("системы налогообложения","СистемаНалогообложения");	
	АтолДанные.Вставить("автономный режим","АвтономныйРежим");	
	АтолДанные.Вставить("признак услуги","ПризнакУслуг");
	АтолДанные.Вставить("признак шифрования","ПризнакШифрования");
	АтолДанные.Вставить("признак расчетов в интернете","ПризнакРасчетовВИнтернете");
	АтолДанные.Вставить("автоматический режим","АвтоматическийРежим");
	АтолДанные.Вставить("номер автомата","НомерАвтомата");
	АтолДанные.Вставить("ИНН ОФД","ИННОФД");
	АтолДанные.Вставить("признак платежного агента","ПризнакПлатежногоАгента");
	АтолДанные.Вставить("признак установки принтера в автомате","ПризнакУстановкиПринтераВАвтомате");
	АтолДанные.Вставить("место расчетов","МестоРасчетов");
	АтолДанные.Вставить("адрес сайта ФНС","АдресСайтаФНС");
	АтолДанные.Вставить("адрес электронной почты отправителя чека","АдресЭлектроннойПочты");
	АтолДанные.Вставить("наименование ОФД","НаименованиеОФД");
	АтолДанные.Вставить("версия ККТ","ВерсияККТ");
	АтолДанные.Вставить("версия ФФД ККТ","ВерсияФФДККТ");
	АтолДанные.Вставить("версия ФФД","ВерсияФФД");
	АтолДанные.Вставить("зав. номер ФН","ЗавНомерФН");
	АтолДанные.Вставить("дата, время","Дата");
	АтолДанные.Вставить("порядковый номер ФД","ПорядковыйНомерФД");
	АтолДанные.Вставить("ФП документа","ФП");
	
	Возврат АтолДанные;
	
КонецФункции


&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// Вставить содержимое обработчика.
	Если Не ЗначениеЗаполнено(ТекущийОбъект.Касса) Тогда
		Запрос = Новый Запрос;
		запрос.Текст =  "ВЫБРАТЬ
		|	Кассы.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Кассы КАК Кассы
		|ГДЕ
		|	Кассы.ЗаводскойНомер = &ЗаводскойНомер";
		Запрос.УстановитьПараметр("ЗаводскойНомер",ТекущийОбъект.завНомер);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда	
			ТекущийОбъект.Касса = Выборка.Ссылка;
		КонецЕсли;
		
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ТекущийОбъект.ФН) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ФН.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ФН КАК ФН
		|ГДЕ
		|	ФН.ЗаводскойНомер = &Номер";
		Запрос.УстановитьПараметр("Номер",ТекущийОбъект.ЗавНомерФН);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ТекущийОбъект.ФН = Выборка.Ссылка;
		Иначе 
			СсылкаНаФН = СоздатьФН(ТекущийОбъект.ЗавНомерФН);
			ТекущийОбъект.ФН = СсылкаНаФН;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Получить файл из хранилища и поместить его в объект.
	
	Если ЭтоАдресВременногоХранилища(СсылкаНаФайлВоВременномХранилище) Тогда
		
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(СсылкаНаФайлВоВременномХранилище);
		
		ТекущийОбъект.ФайлЧека = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных(9));
		
		ТекущийОбъект.ИмяФайлаЧека = ИмяФайлаЧека;
		
		
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СоздатьФН(НомерФН)
	
	НовыйЭлемент = Справочники.ФН.СоздатьЭлемент();
	НовыйЭлемент.Наименование = НомерФН;
	НовыйЭлемент.ЗаводскойНомер = НомерФН;
	НовыйЭлемент.Записать();
	
	Возврат НовыйЭлемент.Ссылка;
	
КонецФункции

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	// Удалить файл из временного хранилища
	
	Если ЭтоАдресВременногоХранилища(СсылкаНаФайлВоВременномХранилище) Тогда	
		УдалитьИзВременногоХранилища(СсылкаНаФайлВоВременномХранилище);			
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПросмотретьФайлЧека(Команда)
	
	Если Объект.ИмяФайлаЧека = "" Тогда
		ПоказатьПредупреждение(, "Нет чека");
	Иначе
		СсылкаНаФайлВИБ = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "ФайлЧека");
		НачатьПолучениеФайлаССервера(СсылкаНаФайлВИБ, Объект.ИмяФайлаЧека);		
	КонецЕсли;
	
КонецПроцедуры


