Функция АвторизацияОФД() Экспорт
	
	//{"login":"1329252155","password":"QWEasd/123","rememberme":true}
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Ошибка",Ложь);
	СтруктураВозврата.Вставить("Токен","");
	СтруктураВозврата.Вставить("Cookie","");
	СтруктураЗапроса = Новый Структура;
   // Комментарий убрать в коде пароли	
	СтруктураЗапроса.Вставить("login", "elobanov@ufs-online.ru");
	СтруктураЗапроса.Вставить("password", "crjhjlbgkjv312");
	СтруктураЗапроса.Вставить("rememberme", Истина);
	
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON,СтруктураЗапроса);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type","application/json;charset=utf-8");
	//POST /api/user/login
	//https://www.1-ofd.ru/api/user/login
	Попытка
		Соединение  = Новый HTTPСоединение("org.1-ofd.ru",,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	Исключение
		Сообщить("Не удалось установить соединение с сервером онлайн-проверки:" 
		+ Символы.ПС + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
		СтруктураВозврата.Ошибка = Истина;
		Возврат СтруктураВозврата;	
	КонецПопытки;
	
	
	Попытка
		HTTPЗапрос = Новый HTTPЗапрос("/api/user/login",Заголовки);
		HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаJSON);
		ФайлОтвета = ПолучитьИмяВременногоФайла();
		
		Результат = Соединение.ОтправитьДляОбработки(HTTPЗапрос,ФайлОтвета);
		Соединение = Неопределено;
		Если Результат.КодСостояния > 299 Тогда
			Сообщить("Код состояния " + Результат.КодСостояния + ". Токен не получен");
			СтруктураВозврата.Ошибка = Истина;
			Возврат СтруктураВозврата;	
		ИначеЕсли Результат.КодСостояния = 200 Тогда
			ЧтениеJson = Новый ЧтениеJSON;
			ЧтениеJson.ОткрытьФайл(ФайлОтвета);
			ДанныеОтОФД = ПрочитатьJSON(ЧтениеJson);
			Cookie = Результат.Заголовки["Set-Cookie"];
			СтруктураВозврата.Cookie = Cookie;
			СтруктураВозврата.Токен = ДанныеОтОФД.authToken;
			Возврат СтруктураВозврата;
		КонецЕсли;
	Исключение
		Сообщить(ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
		СтруктураВозврата.Ошибка = Истина;
		Возврат СтруктураВозврата;	
	КонецПопытки
	
КонецФункции

Функция ПолучитьДействующиеККТ(ДанынеАвторизации) Экспорт
	//GET /api/kkms/fiscal-kkms	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Ошибка",Ложь);
	СтруктураВозврата.Вставить("СписокККТ",Новый Массив);

	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type","application/json;charset=utf-8");
	//Заголовки.Вставить("Content-Length","application/json;charset=utf-8");
	Заголовки.Вставить("Cookie",ДанынеАвторизации.Cookie);
	Заголовки.Вставить("X-XSRF-TOKEN","PLAY_SESSION="+ДанынеАвторизации.Токен);


	Попытка
		Соединение  = Новый HTTPСоединение("org.1-ofd.ru",,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	Исключение
		Сообщить("Не удалось установить соединение с сервером онлайн-проверки:" 
		+ Символы.ПС + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
		СтруктураВозврата.Ошибка = Истина;
		Возврат СтруктураВозврата;	
	КонецПопытки;
	
	
	Попытка
		HTTPЗапрос = Новый HTTPЗапрос("/api/kkms/retail-places",Заголовки);
		ФайлОтвета = ПолучитьИмяВременногоФайла();
		
		Результат = Соединение.Получить(HTTPЗапрос,ФайлОтвета);
	
		Если Результат.КодСостояния > 299 Тогда
			Сообщить("Код состояния " + Результат.КодСостояния + ". Токен не получен");
			СтруктураВозврата.Ошибка = Истина;
			ЧтениеJson = Новый ЧтениеJSON;
			ЧтениеJson.ОткрытьФайл(ФайлОтвета);
			ДанныеОтОФД = ПрочитатьJSON(ЧтениеJson);

			Возврат СтруктураВозврата;	
		ИначеЕсли Результат.КодСостояния = 200 Тогда
			ЧтениеJson = Новый ЧтениеJSON;
			ЧтениеJson.ОткрытьФайл(ФайлОтвета);
			ДанныеОтОФД = ПрочитатьJSON(ЧтениеJson);
			//СтруктураВозврата.СписокККТ = ДанныеОтОФД.authToken;
			Возврат СтруктураВозврата;
		КонецЕсли;
	Исключение
		Сообщить(ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
		СтруктураВозврата.Ошибка = Истина;
		Возврат СтруктураВозврата;	
	КонецПопытки
	
КонецФункции

