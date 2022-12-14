Функция НачатьЗамерДлительнойОперации(КлючеваяОперация,ГлобальнаяОперация) Экспорт
	
	ОписаниеЗамера = Новый Соответствие;
	
	ВремяНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ОписаниеЗамера.Вставить("КлючеваяОперация", КлючеваяОперация);
	ОписаниеЗамера.Вставить("ВремяНачала", ВремяНачала);
	ОписаниеЗамера.Вставить("ГлобальнаяОперация",ГлобальнаяОперация);
	Возврат ОписаниеЗамера;
	
КонецФункции

Процедура ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ОписаниеЗамера) Тогда
		Возврат;
	КонецЕсли;
		
	// Переменные из описания замера.
	ВремяНачалаЗамера	 = ОписаниеЗамера["ВремяНачала"];
	ИмяКлючевойОперации	 = ОписаниеЗамера["КлючеваяОперация"];
	ГлобальнаяОперация   = ОписаниеЗамера["ГлобальнаяОперация"];

	ТекущееВремя = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Длительность = ТекущееВремя - ВремяНачалаЗамера;
	                                  				// Фиксация длительной ключевой операции.
	ПараметрыЗамера = Новый Структура;
	ПараметрыЗамера.Вставить("КлючеваяОперация", ИмяКлючевойОперации);
	ПараметрыЗамера.Вставить("Длительность", (Длительность)/1000);
	ПараметрыЗамера.Вставить("ДатаНачалаКлючевойОперации", ВремяНачалаЗамера);
	ПараметрыЗамера.Вставить("ДатаОкончанияКлючевойОперации", ТекущееВремя);
	ПараметрыЗамера.Вставить("ГлобальнаяОперация", ГлобальнаяОперация);
	
	ЗаписатьЗамерыВремени(ПараметрыЗамера);
	
КонецПроцедуры

Процедура ЗаписатьЗамерыВремени(ПараметрыЗамера)
	
	УстановитьПривилегированныйРежим(Истина);
	
	НаборЗаписей = РегистрыСведений.ЗамерыВремени.СоздатьНаборЗаписей();
	ДатаЗаписи = Дата(1,1,1) + ТекущаяУниверсальнаяДатаВМиллисекундах()/1000;
	ДатаЗаписиЛокальная = ТекущаяДатаСеанса();
	
    КлючеваяОперацияСсылка = ПараметрыЗамера.КлючеваяОперация;
				
	Запись = НаборЗаписей.Добавить();		
	Запись.КлючеваяОперация = КлючеваяОперацияСсылка;
	
	//Запись.ВремяНачала = ПараметрыЗамера.ДатаНачалаКлючевойОперации;			
	Запись.ВремяВыполнения = ?(ПараметрыЗамера.Длительность = 0, 0.001, ПараметрыЗамера.Длительность); // Длительность меньше разрешения таймера
	Запись.ГлобальнаяОперация = ПараметрыЗамера.ГлобальнаяОперация;
	//Запись.ВремяОкончания = ПараметрыЗамера.ДатаОкончанияКлючевойОперации;
	
	Запись.ДатаЗаписи = ДатаЗаписи;
	Запись.ДатаЗаписиЛокальная = ДатаЗаписиЛокальная;
	
	Если НаборЗаписей.Количество() > 0 Тогда
		Попытка
			НаборЗаписей.Записать(Ложь);
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры


