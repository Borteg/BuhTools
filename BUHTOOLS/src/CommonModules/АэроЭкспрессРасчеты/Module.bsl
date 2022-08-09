
Функция ПодсчитатьКоличествоБилетов(Знач ДатаНачала,Знач ДатаОкончания) Экспорт
	
	ДатаНачалаСтрока = Формат(ДатаНачала,"ДФ=yyyyMMdd");
	ДатаОкончания = КонецДня(ДатаОкончания) + 1; 
	ДатаОкончанияСтрока = Формат(ДатаОкончания,"ДФ=yyyyMMdd");

	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=fin_auditor;PWD=Cdthrf123;DATABASE=PGW2_R");

	ТекстЗапроса = "set transaction isolation level read uncommitted
	|SET NOCOUNT ON
	| DECLARE @begDate DATETIME = '"+ДатаНачалаСтрока+"'  
	| DECLARE @endDate DATETIME = '"+ДатаОкончанияСтрока+"'
	|   SELECT   t.type as ТИП,count(p.ticketid) as КоличествоБилетовВсего 
	|				FROM Trans t (NOLOCK) JOIN 
	|					   orRzhdAE o (NOLOCK) ON t.idtrans = o.idtrans JOIN
	|						AeroTicketClass aeroclass (NOLOCK) ON o.ticketclass = aeroclass.AeroTicketClassId JOIN
	|                      AeroPassenger p (NOLOCK) on p.TransId = t.idtrans  left JOIN 
	|					    ufs_Accountings acc on (t.idtrans = acc.idtrans and acc.idtaker = 49283 and t.type = 14 and acc.tpstatus = 5)                  
	|				WHERE
	|				t.status = 0 --транзакция успешная
	|				AND t.test = 0 --не тестовая
	|			AND t.ConfirmDate >= @begDate
	|			AND t.ConfirmDate < @endDate
	|	AND 1 = 
	|	 (SELECT COUNT(*) FROM Trans t (NOLOCK) JOIN AeroPassenger a (NOLOCK) ON t.idtrans = a.TransId 
	|			AND a.ticketid=p.ticketid AND
	|			t.status = 0 --транзакция успешная
	|			AND t.test = 0 --не тестовая
	|			AND t.ConfirmDate >= @begDate 
	|				AND t.ConfirmDate < @endDate)
	|	group by
	|	t.type";
	
	//Сообщить(ТекстЗапроса);
	RecordSet = Connection.Execute(ТекстЗапроса);
	
	
	КоличествоБилетов = 0;
	
	Пока НЕ RecordSet.EOF() Цикл
		
		ТИП = Число(RecordSet.Fields("ТИП").Value);
		Если Тип = 1 Тогда
			КоличествоБилетов = КоличествоБилетов + Число(RecordSet.Fields("КоличествоБилетовВсего").Value);
		Иначе
			КоличествоБилетов = КоличествоБилетов - Число(RecordSet.Fields("КоличествоБилетовВсего").Value);
		КонецЕсли;
		RecordSet.MoveNext();
		
	КонецЦикла; 
	RecordSet.Close();
	Connection.Close();

	Возврат КоличествоБилетов;
	
КонецФункции
