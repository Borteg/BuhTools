
Функция СозданиеПодключениеUFS() Экспорт
	
	Connection = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout  = 0;
	Connection.CommandTimeout   = 0;
	
	Connection.Open ("DRIVER={SQL Server};SERVER=db1;UID=elobanov;PWD=!155255!;DATABASE=PGW2_R");
	
	Возврат Connection;

КонецФункции