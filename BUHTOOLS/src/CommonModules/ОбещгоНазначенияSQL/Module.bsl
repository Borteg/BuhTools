
Функция СозданиеПодключениеUFS() Экспорт
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=elobanov;PWD=!155255!;DATABASE=PGW2_R");
	
	Возврат Connection;

КонецФункции

Функция ОбъявитьДаты(Знач ДатаНачала,Знач ДатаОкончания) Экспорт
	
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

Функция ОбъявитьНачалоЗапроса() Экспорт
	
	ТекстОбъявления = "	
	| SET transaction isolation level read uncommitted
	| SET NOCOUNT ON";
	
	Возврат ТекстОбъявления;
	
КонецФункции