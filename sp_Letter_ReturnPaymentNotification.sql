USE [CorpSol]
GO
/****** Object:  StoredProcedure [dbo].[sp_Letter_ReturnPaymentNotification]    Script Date: 4/5/2022 11:22:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_Letter_ReturnPaymentNotification]   
 @CLAIMNO as VARCHAR(40)
AS  
BEGIN  
	--select 
	--	PolicyNumber,
	--	InsuredName,
	--	case 
	--		when SUBSTRING(PolicyNumber, 1, 1) = '7' then 'Savings'
	--		when SUBSTRING(PolicyNumber, 1, 1) = '9' then 'Life'
	--		else 'Health'
	--	end as PolicyType,
	--	OwnerName,
	--	cast(format(Nominal, 'N', 'id-ID') as varchar(30)) Nominal,
	--	AccountNumber,
	--	AccountName,
	--	Company,
	--	Addr1,
	--	Addr2,
	--	Addr3,		
	--	Status,
	--	FORMAT (TransferDate, 'dd MMMM yyyy', 'id-ID') TransferDate,	
	--	FORMAT (getdate(), 'dd MMMM yyyy', 'id-ID') PrintDate	
	-- from StatusPaymentPremi where TransId = @CLAIMNO  
	select 
		paysur.F07PNO PolicyNumber, 
		prf.OwnerName OwnerName,
		paysur.Insured_Name InsuredName,
		case 
			when paysur.f07trntyp = 'KLAIM SAVING' then 'Savings'
			when paysur.f07trntyp = 'REFUND PREMI' then 'Life'
			else 'Health'
		end as PolicyType,
		cast(format(paysur.F07AMT, 'N', 'id-ID') as varchar(30)) Nominal, 
		paysur.F07BBACNO AccountNumber,
		paysur.F07BNAM AccountName,
		paysur.Owner_Name Company,
		prf.addr1 Addr1,
		prf.addr2 Addr2,
		prf.addr3 Addr3,
		paysur.Status_Data [Status],
		FORMAT (paysur.Tgl_trans, 'dd MMMM yyyy', 'id-ID') TransferDate,	
		FORMAT (getdate(), 'dd MMMM yyyy', 'id-ID') PrintDate
	from 
		[PaymentSurroundingAMFS].[dbo].[GER_det] paysur,
		(select
			case 
				when a.FOR_ATT_OF = '' then 
				case
					when CLTSEX = 'M' then 'BPK ' + SURNAME
					when CLTSEX = 'F' then 'IBU ' + SURNAME
					else SURNAME
				end 
				else a.FOR_ATT_OF 
			end OwnerName, 
			b.CHDRNUM PolNum,
			c.RINTERNET,  
			a.CLTADDR01 addr1, 
			LTRIM(RTRIM(a.CLTADDR02)) + ' ' + LTRIM(RTRIM(a.CLTADDR03)) addr2, 
			LTRIM(RTRIM(a.CLTADDR04)) + ' ' + LTRIM(RTRIM(a.CLTADDR05)) addr3
			--+ ' ' + CLTPCODE addr3 
		from 
			CLNTPF a,
			CHDRPF b left join CLEXPF c on b.COWNNUM = c.CLNTNUM
		where 
			a.CLNTNUM = b.COWNNUM) prf
	where 
		Dept_Code = '6052549' 
		and prf.PolNum = paysur.F07PNO
		and paysur.f07trntyp in ('KLAIM SAVING', 'REFUND PREMI')
		--and paysur.Insured_Name != ''
		and Status_Data is not null
		and cast(paysur.GUID as varchar(100)) = @CLAIMNO
END  