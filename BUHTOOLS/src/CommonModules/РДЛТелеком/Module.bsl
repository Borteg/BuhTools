Процедура ПолучитьДанныеРДЛТелеком() Экспорт
	
	ДатаНачала = ТекущаяДата() - 86400;
	ДатаНачала = НачалоДня(ДатаНачала);
	
	ДатаОкончания = КонецДня(ДатаНачала);
	
	ДанныеРДЛ = Обработки.ПолучитьДанныеРДЛ.ПолучитьДанныеРДЛТелекомЗаПериод(ДатаНачала,ДатаОкончания);	
	
	
	ЗаписатьДанныеРДЛ(ДанныеРДЛ);
	
КонецПроцедуры

Функция ПреобразоватьДатуJson(Дата) Экспорт
	
	ДатаВФормате1с =  СтрЗаменить(Дата,"-","");
	ДатаВФормате1с =  СтрЗаменить(ДатаВФормате1с,":","");
	ДатаВФормате1с =  СтрЗаменить(ДатаВФормате1с," ","");
	
	ДатаВФормате1с =  Дата(ДатаВФормате1с);
	
	Возврат ДатаВФормате1с;
	
КонецФункции

Процедура ЗаписатьДанныеРДЛ(ДанныеРДЛ)
	//Новый коммит в релиз
	Для Каждого Строка ИЗ ДанныеРДЛ Цикл
		МенеджерЗаписи = РегистрыСведений.ДанныеРДЛТелеком.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(МенеджерЗаписи,Строка);	
		МенеджерЗаписи.PaymentTime = ПреобразоватьДатуJson(Строка.PaymentTime);
		Попытка
			МенеджерЗаписи.RefundTime = ПреобразоватьДатуJson(Строка.RefundTime);
			МенеджерЗаписи.Записать();
		Исключение
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = ОписаниеОшибки();
			Сообщение.Сообщить();
		КонецПопытки;
	КонецЦикла;	
	
КонецПроцедуры

Процедура ОтправитьУведомлениеОбОшибке(Ошибка,ДатаНачала,ДатаОкончания) Экспорт
	
	Профиль = Новый ИнтернетПочтовыйПрофиль;
	Профиль.АдресСервераSMTP = "mail.ufs-online.ru"; 
	Профиль.ПортSMTP = 25;
	Профиль.Пользователь = "1c";
	Профиль.Пароль = "";
	Почта = Новый ИнтернетПочта;
	Попытка
		Почта.Подключиться(Профиль);
	Исключение
		Возврат;
	КонецПопытки;
	
	Сообщение = Новый ИнтернетПочтовоеСообщение;
	Сообщение.Отправитель.Адрес = "1c@ufs-online.ru";
	
	Сообщение.Получатели.Добавить("elobanov@ufs-online.ru");
	
	Сообщение.Тема = "Ошибка в получении данных РДЛ Телеком за: " + ДатаНачала + " - "+ ДатаОкончания;
	Текст = Строка(Ошибка);
	
	Сообщение.Тексты.Добавить(Текст,ТипТекстаПочтовогоСообщения.ПростойТекст); 
	
	Попытка
		Почта.Послать(Сообщение);	
	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить();	
	КонецПопытки;
	
	Почта.Отключиться();
	

КонецПроцедуры



