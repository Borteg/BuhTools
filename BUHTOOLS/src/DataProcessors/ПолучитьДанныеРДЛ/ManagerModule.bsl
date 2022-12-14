Функция ПолучитьДанныеРДЛТелекомЗаПериод(ДатаНачала = Неопределено, ДатаОкончания = Неопределено) Экспорт
	
	Сервер = "internet.rdl.club";
	
	Попытка
		HTTP =  Новый HTTPСоединение(Сервер,,,,,Истина);
	Исключение
		РДЛТелеком.ОтправитьУведомлениеОбОшибке(ОписаниеОшибки(),ДатаНачала,ДатаОкончания);
		ВызватьИсключение("Невозможно подключиться к серверу");
	КонецПопытки;
	
	Ресурс = "getStatistics?";
	Если ДатаНачала <> Неопределено  Тогда
		СтартоваяДата = Формат(ДатаНачала ,"ДФ='yyyy-MM-dd ЧЧ:мм:сс'");
		СтартоваяДата = СтрЗаменить(СтартоваяДата," ","%20");
		Ресурс = Ресурс + "startTime=" + СтартоваяДата;
	КонецЕсли;
	
	Если ДатаОкончания <> Неопределено Тогда
		КонечнаяДата =  Формат(ДатаОкончания,"ДФ='yyyy-MM-dd ЧЧ:мм:сс'");
		КонечнаяДата = СтрЗаменить(КонечнаяДата," ","%20");
		Ресурс = Ресурс +?(ДатаНачала = Неопределено,"","&") + "endTime=" + КонечнаяДата;
	КонецЕсли;
	
	
	HTTPЗапрос = Новый HTTPЗапрос(Ресурс);
	
	ИмяФайлаОтвета = ПолучитьИмяВременногоФайла();
	Попытка	
		HTTPОтвет = HTTP.Получить(HTTPЗапрос,ИмяФайлаОтвета);
	Исключение
		РДЛТелеком.ОтправитьУведомлениеОбОшибке(ОписаниеОшибки(),ДатаНачала,ДатаОкончания);
		ВызватьИсключение("Невозможно отправить запрос к серверу");
	КонецПопытки;
	Если Не HTTPОтвет.КодСостояния = 200 Тогда
		РДЛТелеком.ОтправитьУведомлениеОбОшибке(HTTPОтвет.КодСостояния,ДатаНачала,ДатаОкончания);
	Конецесли;
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(ИмяФайлаОтвета);       
	Данные = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	Возврат Данные.Statistics;
	
	
КонецФункции

