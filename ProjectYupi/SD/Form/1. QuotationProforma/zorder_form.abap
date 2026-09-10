SELECT SINGLE CUSTOMER
FROM I_SalesDocumentPartner WITH PRIVILEGED ACCESS
WHERE SalesDocument = @SalesDocument-Salesdocument
AND PartnerFunction = 'WE'
INTO @DATA(ls_customer).

IF ls_customer IS NOT INITIAL.
    SELECT SINGLE CityName, CountryName
    FROM YY1_Address WITH PRIVILEGED ACCESS
    WHERE Customer = @ls_customer
    AND Language = 'E'
    INTO ( @DATA(lv_CityName) , @DATA(lv_CountryName) ).

    CONCATENATE lv_CityName lv_CountryName INTO
    SALESDOCUMENT_EXTENSION_OUT-YY1_ZDESTIONATIONOF_SDH SEPARATED BY ', '.
ELSE.
    SALESDOCUMENT_EXTENSION_OUT-YY1_ZDESTIONATIONOF_SDH = ''.
ENDIF.

"Add By Sol_ilham 09.09.2026 for Quotation Proforma Form
SELECT SINGLE CUSTOMER
FROM I_SalesDocumentPartner WITH PRIVILEGED ACCESS
WHERE SalesDocument = @SalesDocument-Salesdocument
AND PartnerFunction = 'RE'
INTO @DATA(ls_customer1).

if ls_customer1 IS NOT INITIAL.
SELECT SINGLE a~TelephoneNumber2, a~FaxNumber, a~CityName,
              b~CommunicationRemarkText,
              c~BankAccountName, c~BankAccountHolderName, c~SwiftCode, c~BankAccount, c~BankNumber,
              d~CountryName
    FROM i_customer WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_AddressCommunicationRemark_2 WITH PRIVILEGED ACCESS as b ON a~addressid = b~addressid
    LEFT join I_BankChainBankDetail WITH PRIVILEGED ACCESS as c ON a~customer = c~bkchnbp
                                                                AND c~collectionauthind = 'X'
    LEFT join I_CountryText with PRIVILEGED ACCESS as d ON a~country = d~Country
                                                        and d~language = 'E'
    WHERE a~Customer = @ls_customer1
    INTO (@DATA(lv_telephone), @DATA(lv_faxnumber), @DATA(lv_CityName1),
          @DATA(lv_attn),
          @DATA(lv_bankaccname), @DATA(lv_bankname), @DATA(lv_swiftcode), @DATA(lv_bankacc),@DATA(lv_bankkey),
          @DATA(lv_CountryName1)).
    if sy-subrc = 0.
      salesdocument_extension_out-yy1_zphone_sdh = lv_telephone.
      salesdocument_extension_out-yy1_zfax_sdh = lv_faxnumber.
      salesdocument_extension_out-yy1_zattn_sdh = lv_attn.
      salesdocument_extension_out-yy1_zbankaccount_sdh = lv_bankaccname.
      salesdocument_extension_out-yy1_zbankname_sdh = lv_bankname.
      salesdocument_extension_out-yy1_zswiftcode_sdh = lv_swiftcode.
      salesdocument_extension_out-yy1_zbankacc_sdh = lv_bankacc.
      salesdocument_extension_out-yy1_zbankkey_sdh = lv_bankkey.
      CONCATENATE lv_CityName1 lv_CountryName1 INTO salesdocument_extension_out-YY1_ZDESTINATION_sDH SEPARATED BY ', '.
    endif.
endif.
"End By Sol_ilham 09.09.2026 for Quotation Proforma Form
