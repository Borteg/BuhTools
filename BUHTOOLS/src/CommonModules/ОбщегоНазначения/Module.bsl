// Создает объект ОписаниеТипов, содержащий тип Дата.
//
// Параметры:
//  ЧастиДаты - ЧастиДаты - набор вариантов использования значений типа Дата.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Дата.
Функция ОписаниеТипаДата(ЧастиДаты) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Дата"));

	КвалификаторДаты = Новый КвалификаторыДаты(ЧастиДаты);

	Возврат Новый ОписаниеТипов(Массив, , , КвалификаторДаты);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Строка.
//
// Параметры:
//  ДлинаСтроки - Число - длина строки.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Строка.
//
Функция ОписаниеТипаСтрока(ДлинаСтроки) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Строка"));

	КвалификаторСтроки = Новый КвалификаторыСтроки(ДлинаСтроки, ДопустимаяДлина.Переменная);

	Возврат Новый ОписаниеТипов(Массив, , КвалификаторСтроки);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Число.
//
// Параметры:
//  Разрядность - Число - общее количество разрядов числа (количество разрядов
//                        целой части плюс количество разрядов дробной части).
//  РазрядностьДробнойЧасти - Число - число разрядов дробной части.
//  ЗнакЧисла - ДопустимыйЗнак - допустимый знак числа.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Число.
Функция ОписаниеТипаЧисло(Разрядность, РазрядностьДробнойЧасти = 0, ЗнакЧисла = Неопределено) Экспорт

	Если ЗнакЧисла = Неопределено Тогда
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти);
	Иначе
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти, ЗнакЧисла);
	КонецЕсли;

	Возврат Новый ОписаниеТипов("Число", КвалификаторЧисла);

КонецФункции

//Преобзовывает дату для запроса SQL без часов/секунд/минут
// Возвращаемое значение:
//  Строка - ДатаВФорматеSQL.
Функция ПреобразоватьДатуВДатуSQL(ДатаДляПреобразования) Экспорт
	
	ДатаВФорматеSQL =  Формат(ДатаДляПреобразования,"ДФ=yyyyMMdd");
	
	Возврат ДатаВФорматеSQL;
	
КонецФункции

Функция ЕстьВТаблице(НомерПлатежа,ТипЧека,СуммаПозиции,ТаблицаПоиска) Экспорт
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("НомерПлатежа",НомерПлатежа);
	СтруктураОтбора.Вставить("ТипЧека",ТипЧека);
	СтруктураОтбора.Вставить("СуммаПозиции",СуммаПозиции);

	НайденныеСтроки = ТаблицаПоиска.НайтиСтроки(СтруктураОтбора);
	
	Возврат НайденныеСтроки;
	
КонецФункции

Процедура ПодготовитьДатыВЗапросе(ТекстЗапроса,ДатаНачала,ДатаОкончания) Экспорт
	
	ДатаНачалаSQL = ПреобразоватьДатуВДатуSQL(ДатаНачала);
	ДатаОкончанияДляЗапроса = КонецДня(ДатаОкончания) +1;
	ДатаОкончанияSQL = ПреобразоватьДатуВДатуSQL(ДатаОкончанияДляЗапроса);	
	ТекстЗапросаЗаменаНачала = СтрЗаменить(ТекстЗапроса,"@Дата1сВSQLНачало",ДатаНачалаSQL);
	ТекстЗапросаЗаменаКонец = СтрЗаменить(ТекстЗапросаЗаменаНачала,"@Дата1сВSQLКонец",ДатаОкончанияSQL);
	
	ТекстЗапроса = ТекстЗапросаЗаменаКонец;
	
КонецПроцедуры

