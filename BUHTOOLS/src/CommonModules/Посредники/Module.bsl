
	
		
Функция ЗапросОтчетПоСайту() Экспорт

	ЗапросОтчетПоСайту = "
						 | SELECT t.idtrans
						 | ,t.tPayType
						 | ,t.idServ
						 | ,t.type
						 | ,t.amount
						 | ,t.fee
						 | ,t.idTaker
						 | --,t.idadvert
						 | INTO #ALLTRANS 
						 | FROM Trans t 
						 | JOIN orUPay pay on t.idtrans = pay.idtrans
						 | WHERE  (PAY.type = 1 or PAY.type =3) and PAY.status = 0 and t.status = 0 and pay.paydelivered >= @BEGDate  and pay.paydelivered < @ENDDate
						 | 
						 | SELECT serv.nameServ
						 | ,NoFilter.idtrans
						 | ,NoFilter.type
						 | ,NoFilter.amount
						 | ,NoFilter.fee
						 | ,NoFilter.idTaker
						 | --,NoFilter.idadvert
						 | ,acc.sumsrv
						 | ,acc.sumfee
						 | ,acc.sum,
						 | acc.idtaker as Bank
						 | INTO #WithFilter 
						 | From #ALLTRANS NoFilter  
						 | JOIN ufs_Accountings acc on acc.idtrans = NoFilter.idtrans 
						 | JOIN Services serv on serv.idServ = NoFilter.idServ  
						 | Where acc.idpayer = 47072  and acc.phase = 1 and acc.tpstatus = 5
						 | 
						 | Select wf.nameserv AS SERV
						 | ,wf.idTaker AS ProvID
						 | ,mem.shortName AS ProvName
						 | ,wf.Bank AS BankID
						 | ,mem2.shortname as BankName
						 | ,sum(case when WF.type = 1 then WF.amount else (-1)*WF.amount end) as AMOUNT
						 | ,SUM(wf.fee) as FEE
						 | ,SUM(case when WF.type = 1 then WF.sum else (-1)*WF.sum end) as CLIENTPAY  
						 | From #WithFilter WF 
						 | JOIN members mem on mem.idMember = wf.idTaker
						 | JOIN members mem2 on mem2.idMember = wf.Bank
						 | --JOIN members mem3 on mem3.idMember = wf.idadvert
						 | group by WF.nameServ
						 | ,wf.idTaker
						 | ,mem.shortName
						 | ,mem2.shortName
						 | ,wf.Bank
						 | --,wf.idadvert
						 | --,mem3.shortName
						 | 
						 | Drop Table #ALLTRANS 
						 | Drop Table #WithFilter";

	Возврат ЗапросОтчетПоСайту;

КонецФункции