CLASS lhc_zyupi_sd_r_hcii DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zyupi_sd_r_hcii RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zyupi_sd_r_hcii RESULT result.

    METHODS setitems FOR DETERMINE ON MODIFY
       keys FOR zyupi_sd_r_hcii~setitems.

    METHODS setparty FOR DETERMINE ON MODIFY
       keys FOR zyupi_sd_r_hcii~setparty.

*    METHODS generatepdf FOR DETERMINE ON MODIFY
*       keys FOR zyupi_sd_r_hcii~generatepdf.

    METHODS generatepdf FOR DETERMINE ON SAVE
       keys FOR zyupi_sd_r_hcii~generatepdf.

    METHODS valueheader FOR VALIDATE ON SAVE
       keys FOR zyupi_sd_r_hcii~valueheader.

    METHODS invpeb.

ENDCLASS.

CLASS lhc_zyupi_sd_r_hcii IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setitems.
    READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
      ENTITY zyupi_sd_r_hcii
        FIELDS ( deliverydocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.

      " 1. Baca item yang sudah ada (existing items) untuk mendapatkan nomor urut terakhir
      READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
        ENTITY zyupi_sd_r_hcii BY \_items
          FIELDS ( zdoc_number_ci_indo_item zdelivery_number zdelivery_item ) WITH VALUE #( ( %tky = ls_data-%tky ) )
        RESULT DATA(lt_existing_items).


      READ TABLE lt_existing_items INTO DATA(ls_check) WITH KEY zdelivery_number = ls_data-deliverydocument.
      IF sy-subrc = 0.
        " 1. Do Nothing
      ELSE.
        " 2. Cari nilai maksimum dari zdoc_number_ci_indo_item yang sudah ada
        DATA(lv_max_item) = 0.
        LOOP AT lt_existing_items INTO DATA(ls_exist).
          DATA(lv_num) = CONV i( ls_exist-zdoc_number_ci_indo_item ).
          IF lv_num > lv_max_item.
            lv_max_item = lv_num.
          ENDIF.
        ENDLOOP.

        " 3. Ambil data delivery item dari database
        SELECT deliv~deliverydocument, deliv~deliverydocumentitem, deliv~product,
               deliv~deliverydocumentitemtext, deliv~originaldeliveryquantity, deliv~baseunit,
               salesint~netpriceamount AS netamountint,
               salesindo~netpriceamount AS netamountindo,
               salesindo~transactioncurrency, deliv~yy1_referencedocument_dli,
               ztable~freight, ztable~insurance
         FROM i_deliverydocumentitem AS deliv
         LEFT JOIN i_salesorderitem AS salesint ON deliv~yy1_referencedocument_dli = salesint~yy1_referencedocument_sdi
                                                AND deliv~yy1_referencedocumenti_dli = salesint~yy1_referencedocumenti_sdi
                                                AND salesint~salesorganization = '3100'
         LEFT JOIN i_salesorderitem AS salesindo ON deliv~yy1_referencedocument_dli = salesindo~yy1_referencedocument_sdi
                                                 AND deliv~yy1_referencedocumenti_dli = salesindo~yy1_referencedocumenti_sdi
                                                 AND salesindo~salesorganization = '1100'
         LEFT JOIN zyupi_sd_t_pfi AS ztable ON deliv~product = ztable~product
                                           AND ztable~salesorg = '3100'
         WHERE deliv~deliverydocument = @ls_data-deliverydocument
         INTO TABLE @DATA(lt_delivery).

        IF sy-subrc = 0.
          SORT lt_delivery BY deliverydocument deliverydocumentitem.

          MODIFY ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
            ENTITY zyupi_sd_r_hcii
              CREATE BY \_items
              FIELDS ( zdoc_number_ci_indo_item zdelivery_number zdelivery_item zproduct zproduct_desc
                       zquantity zbaseunit zcif_int_price zfob_int_price zcif_indo_price zfob_indo_price
                       zcurrency zref_po_country )
              WITH VALUE #( (
                %tky    = ls_data-%tky
                %target = VALUE #( FOR ls_row IN lt_delivery INDEX INTO lv_index (
                  %cid      = |CID_{ ls_data-zuuid }_{ ls_row-deliverydocument }_{ lv_index }|
                  %is_draft = ls_data-%is_draft
                  " 4. Lanjutkan nomor dari data yang sudah ada + kelipatan index baru
                  zdoc_number_ci_indo_item = |{ lv_max_item + ( lv_index * 10 ) }|
                  zdelivery_number = ls_row-deliverydocument
                  zdelivery_item = ls_row-deliverydocumentitem
                  zproduct = ls_row-product
                  zproduct_desc = ls_row-deliverydocumentitemtext
                  zquantity = ls_row-originaldeliveryquantity
                  zbaseunit = ls_row-baseunit
                  zcif_int_price = ls_row-netamountint
                  zfob_int_price = ls_row-netamountint - ( ls_row-originaldeliveryquantity * ( ls_row-freight + ls_row-insurance ) )
                  zcif_indo_price = ls_row-netamountindo
                  zfob_indo_price = ls_row-netamountindo - ( ls_row-originaldeliveryquantity * ( ls_row-freight + ls_row-insurance ) )
                  zcurrency = ls_row-transactioncurrency
                  zref_po_country = ls_row-yy1_referencedocument_dli
                ) )
              ) )
            MAPPED DATA(lt_mapped)
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD setparty.
    READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
      ENTITY zyupi_sd_r_hcii
        FIELDS ( deliverydocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.
      SELECT deliverydocument, soldtoparty, shiptoparty, documentdate
       FROM i_deliverydocument
       WHERE deliverydocument = @ls_data-deliverydocument
       INTO TABLE @DATA(lt_delivery).

      IF sy-subrc = 0.
        READ TABLE lt_delivery INTO DATA(ls_delivery) INDEX 1.
        IF sy-subrc = 0.
          MODIFY ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
           ENTITY zyupi_sd_r_hcii
           UPDATE FIELDS ( zdoc_date_ci_indo zsoldtoparty zshiptoparty )
           WITH VALUE #( ( %tky = ls_data-%tky
                           zdoc_date_ci_indo = ls_delivery-documentdate
                           zsoldtoparty = ls_delivery-soldtoparty
                           zshiptoparty = ls_delivery-shiptoparty
           ) )
           REPORTED DATA(lt_reported).

          reported-zyupi_sd_r_hcii = CORRESPONDING #( lt_reported-zyupi_sd_r_hcii ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD generatepdf.
    "tempat generate PDfnya
    TYPES : BEGIN OF ty_header,
              docno          TYPE string,
              docdate        TYPE string,
              soldname       TYPE string,
              soldprefix1    TYPE string,
              soldprefix2    TYPE string,
              soldstreet     TYPE string,
              soldsuffix1    TYPE string,
              soldsuffix2    TYPE string,
              soldpostal     TYPE string,
              soldcity       TYPE string,
              soldcountry    TYPE string,
              soldphone      TYPE string,
              soldfax        TYPE string,
              soldattn       TYPE string,
              shipname       TYPE string,
              shipprefix1    TYPE string,
              shipprefix2    TYPE string,
              shipstreet     TYPE string,
              shipsuffix1    TYPE string,
              shipsuffix2    TYPE string,
              shippostal     TYPE string,
              shipcity       TYPE string,
              shipcountry    TYPE string,
              shipphone      TYPE string,
              shipfax        TYPE string,
              shipattn       TYPE string,
              contype        TYPE string,
              ponumber       TYPE string,
              consealtara    TYPE string,
              headernote     TYPE string,
              footernote     TYPE string,
              shipterms      TYPE string,
              payterms       TYPE string,
            END OF ty_header,

            begin of ty_sum,
              totalqtycarton TYPE i_deliverydocumentitem-originaldeliveryquantity,
              totalvalue     TYPE zyupi_sd_t_icii-zfob_indo_price,
              freight        TYPE zyupi_sd_t_icii-zfob_indo_price,
              insurance      TYPE zyupi_sd_t_icii-zfob_indo_price,
              grandtotal     TYPE zyupi_sd_t_icii-zfob_indo_price,
              currency       TYPE zyupi_sd_t_icii-zcurrency,              
            END OF ty_sum,

            BEGIN OF ty_fob,
              divtext     TYPE string,
              qtyincarton TYPE i_deliverydocumentitem-originaldeliveryquantity,
              totalprice  TYPE zyupi_sd_t_icii-zfob_indo_price,
              matnr       type matnr,
              division    type SPART, 
            END OF ty_fob,
            
            begin of ty_ICM,
              product type MATNR,
              productDesc type abap.char(60),
              packing type zyupi_sd_t_insth-packing,
              qty type i_deliverydocumentitem-originaldeliveryquantity,
              price type zyupi_sd_t_icii-zcif_int_price,
              total type zyupi_sd_t_icii-zcif_int_price,
            end of ty_icm.

    DATA : lt_fob            TYPE STANDARD TABLE OF ty_fob,
           lt_icm            TYPE STANDARD TABLE OF ty_icm,

           lt_matnrByDiv     type standard table of ty_fob,

           ls_header         TYPE ty_header,
           ls_fob            TYPE ty_fob,
           ls_matnrByDiv     type ty_fob,

           ls_InvoicePEB     TYPE ty_sum, "InvoicePEB
           ls_icm            TYPE ty_sum, "CustomerMerah

           lv_total_freight   TYPE p LENGTH 16 DECIMALS 2,
           lv_total_insurance TYPE p LENGTH 16 DECIMALS 2,
           lv_count           TYPE i.

    READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
     ENTITY zyupi_sd_r_hcii
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(lt_data).

    READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
     ENTITY zyupi_sd_r_hcii BY \_items
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(lt_data_items).

    "Get data for Header
    READ TABLE lt_data INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.
      "Query Header
      SELECT a~customer, a~bpcustomerfullname, a~streetprefixname1, a~streetprefixname2, a~stretname1,
             a~streetsuffixname1, a~streetsuffixname2, a~postalcode, a~cityname, a~country1,
             concat_with_space( a~telephonenumber1, a~telephonenumber2, 1 ) AS telephone_combined,
             a~faxnumber, b~communicationremarktext
      FROM zyupi_sd_i_address_customer AS a
      LEFT JOIN i_addresscommunicationremark_2 AS b ON a~addressid = b~addressid
      WHERE a~customer = @ls_data-zsoldtoparty
      INTO TABLE @DATA(lt_solddetail).

      SELECT a~customer, a~bpcustomerfullname, a~streetprefixname1, a~streetprefixname2, a~stretname1,
             a~streetsuffixname1, a~streetsuffixname2, a~postalcode, a~cityname, a~country1,
             concat_with_space( a~telephonenumber1, a~telephonenumber2, 1 ) AS telephone_combined,
             a~faxnumber, b~communicationremarktext
      FROM zyupi_sd_i_address_customer AS a
      LEFT JOIN i_addresscommunicationremark_2 AS b ON a~addressid = b~addressid
      WHERE a~customer = @ls_data-zshiptoparty
      INTO TABLE @DATA(lt_shipdetail).

      DATA(lv_deliv) = VALUE #( lt_data_items[ 1 ]-zdelivery_number OPTIONAL ).

      SELECT SINGLE a~deliverydocument, a~incotermsclassification, a~incotermstransferlocation,        
                    d~paymenttermsname
        FROM i_deliverydocument WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~deliverydocument = b~deliverydocument
        INNER JOIN i_salesorderitem WITH PRIVILEGED ACCESS AS c ON b~yy1_referencedocument_dli = c~yy1_referencedocument_sdi
                                        AND b~yy1_referencedocumenti_dli = c~yy1_referencedocumenti_sdi
                                        AND c~salesorganization = '1100'
        INNER JOIN i_paymenttermstext WITH PRIVILEGED ACCESS AS d ON c~customerpaymentterms = d~paymentterms
                                          AND d~language = 'E'
        WHERE a~deliverydocument = @lv_deliv
        INTO @DATA(ls_terms).

      DATA(lt_dupt_po) = lt_data_items.
      SORT lt_dupt_po BY zref_po_country.
      DELETE ADJACENT DUPLICATES FROM lt_dupt_po COMPARING zref_po_country.

      "Mapping header
      ls_header-docno = ls_data-zdoc_number_ci_indo.
      ls_header-docdate = ls_data-zdoc_date_ci_indo.
      READ TABLE lt_solddetail INTO DATA(ls_solddetail) WITH KEY customer = ls_data-zsoldtoparty.
      IF sy-subrc = 0.
        ls_header-soldname = ls_solddetail-bpcustomerfullname.
        ls_header-soldprefix1 = ls_solddetail-streetprefixname1.
        ls_header-soldprefix2 = ls_solddetail-streetprefixname2.
        ls_header-soldstreet = ls_solddetail-stretname1.
        ls_header-soldsuffix1 = ls_solddetail-streetsuffixname1.
        ls_header-soldsuffix2 = ls_solddetail-streetsuffixname2.
        ls_header-soldpostal = ls_solddetail-postalcode.
        ls_header-soldcity = ls_solddetail-cityname.
        ls_header-soldcountry = ls_solddetail-country1.
        ls_header-soldphone = ls_solddetail-telephone_combined.
        ls_header-soldfax = ls_solddetail-faxnumber.
        ls_header-soldattn = ls_solddetail-communicationremarktext.
      ENDIF.

      READ TABLE lt_shipdetail INTO DATA(ls_shipdetail) WITH KEY customer = ls_data-zshiptoparty.
      IF sy-subrc = 0.
        ls_header-shipname = ls_shipdetail-bpcustomerfullname.
        ls_header-shipprefix1 = ls_shipdetail-streetprefixname1.
        ls_header-shipprefix2 = ls_shipdetail-streetprefixname2.
        ls_header-shipstreet = ls_shipdetail-stretname1.
        ls_header-shipsuffix1 = ls_shipdetail-streetsuffixname1.
        ls_header-shipsuffix2 = ls_shipdetail-streetsuffixname2.
        ls_header-shippostal = ls_shipdetail-postalcode.
        ls_header-shipcity = ls_shipdetail-cityname.
        ls_header-shipcountry = ls_shipdetail-country1.
        ls_header-shipphone = ls_shipdetail-telephone_combined.
        ls_header-shipfax = ls_shipdetail-faxnumber.
        ls_header-shipattn = ls_shipdetail-communicationremarktext.
      ENDIF.
      ls_header-contype = ls_data-zcont_type.
      ls_header-ponumber = REDUCE string(
                            INIT s = ``
                            FOR <item> IN lt_dupt_po
                            WHERE ( zref_po_country IS NOT INITIAL )
                            NEXT s = COND #( WHEN s IS INITIAL THEN <item>-zref_po_country
                                            ELSE s && |, | && <item>-zref_po_country )
                          ).      
      ls_header-consealtara = |{ ls_data-zcont_seal_1 } { ls_data-zcont_seal_2 }|.
      ls_header-headernote = ls_data-zheader_note.   
      ls_header-footernote = ls_data-zfooter_note.         
      ls_header-shipterms = |{ ls_terms-incotermsclassification } { ls_terms-incotermstransferlocation }|.
      ls_header-payterms = ls_terms-paymenttermsname.

      DATA(lt_dupt_products) = lt_data_items.
      SORT lt_dupt_products BY zproduct.
      DELETE ADJACENT DUPLICATES FROM lt_dupt_products COMPARING zproduct.

      "Start InvoicePEB
      IF lt_dupt_products IS NOT INITIAL.
        "Query ke table mas bony based on product & salesorg = 1100
        SELECT product, freight, insurance
         FROM zyupi_sd_t_pfi
         FOR ALL ENTRIES IN @lt_dupt_products
         WHERE product = @lt_dupt_products-zproduct
         AND salesorg = '1100'
         INTO TABLE @DATA(lt_pfi).

        SELECT a~product, a~division, b~divisionname
         FROM i_product WITH PRIVILEGED ACCESS AS a
         LEFT JOIN i_divisiontext AS b ON a~division = b~division
         FOR ALL ENTRIES IN @lt_dupt_products
         WHERE a~product = @lt_dupt_products-zproduct
         INTO TABLE @DATA(lt_division).

        loop at lt_data_items into DATA(ls_data_items).
          READ TABLE lt_division INTO DATA(ls_division) WITH KEY product = ls_data_items-zproduct.
          IF sy-subrc = 0.
            clear : ls_matnrByDiv.
            ls_matnrByDiv-matnr = ls_data_items-zproduct.
            ls_matnrByDiv-divtext = ls_division-divisionname.
            ls_matnrByDiv-qtyincarton = ls_data_items-zquantity.
            ls_matnrByDiv-totalprice = ls_data_items-zfob_indo_price.
            ls_matnrByDiv-division = ls_division-division.
            APPEND ls_matnrByDiv TO lt_matnrByDiv.
          ENDIF.
        endloop.

        SORT lt_division BY division.
        DELETE ADJACENT DUPLICATES FROM lt_division COMPARING division.
      ENDIF.

      "Mapping Items for InvoicePEB
      LOOP AT lt_division INTO DATA(ls_division).
        CLEAR : ls_fob.
        ls_fob-divtext = ls_division-divisionname.
        Sum zquantity (saya ingin ngesum based on division yang sama) "masih harus dibenarkan
        ls_fob-qtyincarton = REDUCE #(
          INIT q = 0
          FOR <item> IN lt_matnrByDiv
          WHERE ( <item>-division = ls_division-division )
          NEXT q = q + <item>-qtyincarton
        ).
        " Sum zfob_indo_price (saya ingin ngesum based on division yang sama)
        ls_fob-totalprice = REDUCE #(
          INIT p = CONV f( 0 ) 
          FOR <item> IN lt_matnrByDiv
           WHERE ( <item>-division = ls_division-division )        
          NEXT p = p + <item>-zfob_indo_price
        ).
        ls_InvoicePEB-totalqtycarton = ls_header-totalqtycarton + ls_fob-qtyincarton.
        ls_InvoicePEB-totalvalue = ls_header-totalvalue + ls_fob-totalprice.
        ls_InvoicePEB-currency = VALUE #( lt_data_items[ 1 ]-zcurrency OPTIONAL ).
        APPEND ls_fob TO lt_fob.
      ENDLOOP.

      CLEAR: lv_total_freight, lv_total_insurance.
      LOOP AT lt_dupt_products INTO DATA(ls_dupt_items).
        READ TABLE lt_pfi INTO DATA(ls_pfi) WITH KEY product = ls_dupt_items-zproduct.
        IF sy-subrc = 0.
          lv_total_freight   = lv_total_freight   + ( ls_pfi-freight * ls_dupt_items-zquantity ).
          lv_total_insurance = lv_total_insurance + ( ls_pfi-insurance * ls_dupt_items-zquantity ).
        ENDIF.
      ENDLOOP.
      ls_InvoicePEB-freight   = lv_total_freight.
      ls_InvoicePEB-insurance = lv_total_insurance.

      ls_InvoicePEB-grandtotal = ls_InvoicePEB-totalvalue + ls_InvoicePEB-freight + ls_InvoicePEB-insurance.
      
      "Generate xml using method InvoicePEB( )
      DATA lo_writer        TYPE REF TO if_sxml_writer.
      DATA lo_string_writer TYPE REF TO cl_sxml_string_writer.
      DATA lv_xstring       TYPE xstring.
      DATA lv_base64        TYPE string.
      DATA lv_xml_data      TYPE string.

      lo_writer = cl_sxml_string_writer=>create( ).

      "================ Header ================"
      lo_writer->open_element( name = 'Form' ).
      lo_writer->open_element( name = 'HeaderNode' ).

      lo_writer->open_element( name = 'CommercialInvoice' ).
      lo_writer->write_value( |{ ls_header-docno }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'CommercialInvoiceDate' ).
      lo_writer->write_value( |{ ls_header-docdate }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'Container' ).
      lo_writer->write_value( |{ ls_header-contype }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'ConSealTara' ).
      lo_writer->write_value( |{ ls_header-consealtara }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'ponumber' ).
      lo_writer->write_value( |{ ls_header-ponumber }| ).
      lo_writer->close_element( ).

      "sold
      lo_writer->open_element( name = 'soldname' ).
      lo_writer->write_value( |{ ls_header-soldname }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldprefix1' ).
      lo_writer->write_value( |{ ls_header-soldprefix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldprefix2' ).
      lo_writer->write_value( |{ ls_header-soldprefix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldstreet' ).
      lo_writer->write_value( |{ ls_header-soldstreet }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpsuffix1' ).
      lo_writer->write_value( |{ ls_header-soldsuffix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpsuffix2' ).
      lo_writer->write_value( |{ ls_header-soldsuffix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpostal' ).
      lo_writer->write_value( |{ ls_header-soldpostal }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldcity' ).
      lo_writer->write_value( |{ ls_header-soldcity }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldcountry' ).
      lo_writer->write_value( |{ ls_header-soldcountry }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldphone' ).
      lo_writer->write_value( |{ ls_header-soldphone }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldfax' ).
      lo_writer->write_value( |{ ls_header-soldfax }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldattn' ).
      lo_writer->write_value( |{ ls_header-soldattn }| ).
      lo_writer->close_element( ).

      "ship
      lo_writer->open_element( name = 'shipname' ).
      lo_writer->write_value( |{ ls_header-shipname }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipprefix1' ).
      lo_writer->write_value( |{ ls_header-soldprefix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipprefix2' ).
      lo_writer->write_value( |{ ls_header-soldprefix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipstreet' ).
      lo_writer->write_value( |{ ls_header-soldstreet }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippsuffix1' ).
      lo_writer->write_value( |{ ls_header-soldsuffix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippsuffix2' ).
      lo_writer->write_value( |{ ls_header-soldsuffix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippostal' ).
      lo_writer->write_value( |{ ls_header-soldpostal }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipcity' ).
      lo_writer->write_value( |{ ls_header-soldcity }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipcountry' ).
      lo_writer->write_value( |{ ls_header-soldcountry }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipphone' ).
      lo_writer->write_value( |{ ls_header-shipphone }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipfax' ).
      lo_writer->write_value( |{ ls_header-shipfax }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipattn' ).
      lo_writer->write_value( |{ ls_header-shipattn }| ).
      lo_writer->close_element( ).

      "terms
      lo_writer->open_element( name = 'totalqtycarton' ).
      lo_writer->write_value( |{ ls_InvoicePEB-totalqtycarton }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'totalvalue' ).
      lo_writer->write_value( |{ ls_InvoicePEB-totalvalue }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'currency' ).
      lo_writer->write_value( |{ ls_InvoicePEB-currency }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipterms' ).
      lo_writer->write_value( |{ ls_header-shipterms }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'payterms' ).
      lo_writer->write_value( |{ ls_header-payterms }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'headernote' ).
      lo_writer->write_value( |{ ls_header-headernote }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'footernote' ).
      lo_writer->write_value( |{ ls_header-footernote }| ).
      lo_writer->close_element( ).

      "freight
      lo_writer->open_element( name = 'freight' ).
      lo_writer->write_value( |{ ls_InvoicePEB-freight }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'insurance' ).
      lo_writer->write_value( |{ ls_InvoicePEB-insurance }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'grandtotal' ).
      lo_writer->write_value( |{ ls_InvoicePEB-grandtotal }| ).
      lo_writer->close_element( ).

      "Items
      lo_writer->open_element( name = 'ItemNode' ).

      lv_count = 0.
      LOOP AT lt_fob INTO DATA(ls_inputFOB).
        lv_count += 1.

        lo_writer->open_element( name = 'Item' ).

        lo_writer->open_element( name = 'NoItems' ).
        lo_writer->write_value( |{ lv_count }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'divtext' ).
        lo_writer->write_value( |{ ls_inputFOB-divtext }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'qtyincarton' ).
        lo_writer->write_value( |{ ls_inputFOB-qtyincarton }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'totalprice' ).
        lo_writer->write_value( |{ ls_inputFOB-totalprice }| ).
        lo_writer->close_element( ).

        lo_writer->close_element( ). " item
      ENDLOOP.
      lo_writer->close_element( ). " items

      lo_writer->close_element( ). " labelform
      lo_writer->close_element( ). " form1


      "Output xml -> Jadikan method global biar ga ditulis beulang
      lo_string_writer ?= lo_writer.
      lv_xstring = lo_string_writer->get_output( ).

      lv_base64 = cl_web_http_utility=>encode_x_base64( lv_xstring ).
      lv_xml_data = lv_base64.
      TRY.
          TRY.
              DATA(lo_pdf_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                   comm_scenario  = 'YY1_ADOBE_FORMS_SRV'
              ).

              DATA(lo_pdf_client) = cl_web_http_client_manager=>create_by_http_destination( lo_pdf_destination ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Content-Type'
                i_value = 'application/json' ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Accept'
                i_value = 'application/json' ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Accept-Charset'
                i_value = 'UTF-8' ).

              "---- Request body
              TYPES: BEGIN OF ty_ads_body,
                       xdp_template       TYPE string,
                       xml_data           TYPE string,
                       form_type          TYPE string,
                       form_locale        TYPE string,
                       tagged_pdf         TYPE string,
                       embed_font         TYPE string,
                       change_not_allowed TYPE string,
                       print_not_allowed  TYPE string,
                     END OF ty_ads_body.

              DATA(ls_body) = VALUE ty_ads_body(
                xdp_template       = 'ZYUPI_SD_F_INT_INVOICEPEB_V1/ZYUPI_SD_T_INT_INVOICEPEB_V1'
                xml_data           = lv_xml_data
                form_type          = 'print'
                form_locale        = 'en_US'
                tagged_pdf         = '1'
                embed_font         = '0'
                change_not_allowed = 'false'
                print_not_allowed  = 'false'
              ).

              DATA(lv_json) =
                /ui2/cl_json=>serialize(
                  data        = ls_body
                  compress    = abap_true
                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

              lo_pdf_client->get_http_request( )->append_text( lv_json ).

              DATA(lo_response) =
                lo_pdf_client->execute( i_method = if_web_http_client=>post ).

              DATA(ls_status) = lo_response->get_status( ).

              DATA(lv_response) = lo_response->get_text( ).

              FIND REGEX '"fileContent":"([^"]+)"'
                IN lv_response
                SUBMATCHES DATA(lv_pdf_base64).
              "-------------------------------------------------
              " DESTINATION / COMM ARRANGEMENT ERROR
              "-------------------------------------------------
            CATCH cx_http_dest_provider_error INTO DATA(lx_dest2).
              DATA(lv_dest2) = lx_dest2->get_text( ).
              "-------------------------------------------------
              " HTTP CLIENT / EXECUTION ERROR
              "-------------------------------------------------
            CATCH cx_web_http_client_error INTO DATA(lx_http2).
              DATA(lv_http2) = lx_http2->get_text( ).
              "-------------------------------------------------
              " JSON / REGEX / UNEXPECTED ERROR
              "-------------------------------------------------
            CATCH cx_root INTO DATA(lx_root2).
              DATA(lv_root2) = lx_root2->get_text( ).
          ENDTRY.
          IF lv_pdf_base64 IS NOT INITIAL.
            DATA lv_pdf_xstring TYPE xstring.
            DATA lv_error TYPE string.
            TRY.
                lv_pdf_xstring = cl_web_http_utility=>decode_x_base64( lv_pdf_base64 ).
                MODIFY ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
                  ENTITY zyupi_sd_r_hcii
                    UPDATE FIELDS ( zattachment1 mimetype1 filename1 )
                    WITH VALUE #( ( %tky         = ls_data-%tky
                                    zattachment1 = lv_pdf_xstring
                                    mimetype1    = 'application/pdf'
                                    filename1    = |Invoice_PEB_{ ls_header-docno }.pdf| ) )
                  FAILED   DATA(ls_failed_pdf)
                  REPORTED DATA(ls_reported_pdf).
              CATCH cx_root INTO DATA(lx_root).
                lv_error = lx_root->get_text( ).
            ENDTRY.
          ENDIF.

          if lt_dupt_products is not initial.
            "Start Invoice Customer Merah
            Select material, packing, cust_country
              from zyupi_sd_t_insth
              for all entries in @lt_dupt_products
              where material = @lt_dupt_products-zproduct
                and cust_country = ls_data-zshiptoparty
              into table @DATA(lt_insth).

            loop at lt_dupt_products into DATA(ls_dupt_items).
              ls_icm-product = ls_dupt_items-zproduct.
              ls_icm-productDesc = ls_dupt_items-zproduct_desc.
              read table lt_insth into DATA(ls_insth) with key material = ls_dupt_items-zproduct.
              IF sy-subrc = 0.
                ls_icm-packing = ls_insth-packing.  
              endif.           
              ls_icm-qty = REDUCE #(
                INIT q = 0
                FOR <item> IN lt_data_items
                WHERE ( <item>-zproduct = ls_dupt_items-zproduct )
                NEXT q = q + <item>-zquantity
              ).             
              ls_icm-price = REDUCE #(
                INIT q = 0
                FOR <item> IN lt_data_items
                WHERE ( <item>-zproduct = ls_dupt_items-zproduct )
                NEXT q = q + <item>-zcif_int_price
              ).            
              ls_icm-total = ls_icm-qty * ls_icm-price.
              
              ls_icm-totalqtycarton = ls_icm-totalqtycarton + ls_icm-qty.
              ls_icm-grandtotal = ls_icm-grandtotal + ls_icm-total.
              ls_icm-currency = VALUE #( lt_data_items[ 1 ]-zcurrency OPTIONAL ).
            endloop.
          endif.
      "Generate xml using method Invoice Customer Merah, Kuning (Harus benerin)
      DATA lo_writer        TYPE REF TO if_sxml_writer.
      DATA lo_string_writer TYPE REF TO cl_sxml_string_writer.
      DATA lv_xstring       TYPE xstring.
      DATA lv_base64        TYPE string.
      DATA lv_xml_data      TYPE string.

      lo_writer = cl_sxml_string_writer=>create( ).

      "================ Header ================"
      lo_writer->open_element( name = 'Form' ).
      lo_writer->open_element( name = 'HeaderNode' ).

      lo_writer->open_element( name = 'CommercialInvoice' ).
      lo_writer->write_value( |{ ls_header-docno }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'CommercialInvoiceDate' ).
      lo_writer->write_value( |{ ls_header-docdate }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'Container' ).
      lo_writer->write_value( |{ ls_header-contype }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'ConSealTara' ).
      lo_writer->write_value( |{ ls_header-consealtara }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'ponumber' ).
      lo_writer->write_value( |{ ls_header-ponumber }| ).
      lo_writer->close_element( ).

      "sold
      lo_writer->open_element( name = 'soldname' ).
      lo_writer->write_value( |{ ls_header-soldname }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldprefix1' ).
      lo_writer->write_value( |{ ls_header-soldprefix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldprefix2' ).
      lo_writer->write_value( |{ ls_header-soldprefix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldstreet' ).
      lo_writer->write_value( |{ ls_header-soldstreet }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpsuffix1' ).
      lo_writer->write_value( |{ ls_header-soldsuffix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpsuffix2' ).
      lo_writer->write_value( |{ ls_header-soldsuffix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldpostal' ).
      lo_writer->write_value( |{ ls_header-soldpostal }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldcity' ).
      lo_writer->write_value( |{ ls_header-soldcity }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldcountry' ).
      lo_writer->write_value( |{ ls_header-soldcountry }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldphone' ).
      lo_writer->write_value( |{ ls_header-soldphone }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldfax' ).
      lo_writer->write_value( |{ ls_header-soldfax }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'soldattn' ).
      lo_writer->write_value( |{ ls_header-soldattn }| ).
      lo_writer->close_element( ).

      "ship
      lo_writer->open_element( name = 'shipname' ).
      lo_writer->write_value( |{ ls_header-shipname }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipprefix1' ).
      lo_writer->write_value( |{ ls_header-soldprefix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipprefix2' ).
      lo_writer->write_value( |{ ls_header-soldprefix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipstreet' ).
      lo_writer->write_value( |{ ls_header-soldstreet }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippsuffix1' ).
      lo_writer->write_value( |{ ls_header-soldsuffix1 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippsuffix2' ).
      lo_writer->write_value( |{ ls_header-soldsuffix2 }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shippostal' ).
      lo_writer->write_value( |{ ls_header-soldpostal }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipcity' ).
      lo_writer->write_value( |{ ls_header-soldcity }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipcountry' ).
      lo_writer->write_value( |{ ls_header-soldcountry }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipphone' ).
      lo_writer->write_value( |{ ls_header-shipphone }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipfax' ).
      lo_writer->write_value( |{ ls_header-shipfax }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipattn' ).
      lo_writer->write_value( |{ ls_header-shipattn }| ).
      lo_writer->close_element( ).

      "terms
      lo_writer->open_element( name = 'totalqtycarton' ).
      lo_writer->write_value( |{ ls_InvoicePEB-totalqtycarton }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'totalvalue' ).
      lo_writer->write_value( |{ ls_InvoicePEB-totalvalue }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'currency' ).
      lo_writer->write_value( |{ ls_InvoicePEB-currency }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'shipterms' ).
      lo_writer->write_value( |{ ls_header-shipterms }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'payterms' ).
      lo_writer->write_value( |{ ls_header-payterms }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'headernote' ).
      lo_writer->write_value( |{ ls_header-headernote }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'footernote' ).
      lo_writer->write_value( |{ ls_header-footernote }| ).
      lo_writer->close_element( ).

      "freight
      lo_writer->open_element( name = 'freight' ).
      lo_writer->write_value( |{ ls_InvoicePEB-freight }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'insurance' ).
      lo_writer->write_value( |{ ls_InvoicePEB-insurance }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'grandtotal' ).
      lo_writer->write_value( |{ ls_InvoicePEB-grandtotal }| ).
      lo_writer->close_element( ).

      "Items
      lo_writer->open_element( name = 'ItemNode' ).

      lv_count = 0.
      LOOP AT lt_fob INTO DATA(ls_inputFOB).
        lv_count += 1.

        lo_writer->open_element( name = 'Item' ).

        lo_writer->open_element( name = 'NoItems' ).
        lo_writer->write_value( |{ lv_count }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'divtext' ).
        lo_writer->write_value( |{ ls_inputFOB-divtext }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'qtyincarton' ).
        lo_writer->write_value( |{ ls_inputFOB-qtyincarton }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'totalprice' ).
        lo_writer->write_value( |{ ls_inputFOB-totalprice }| ).
        lo_writer->close_element( ).

        lo_writer->close_element( ). " item
      ENDLOOP.
      lo_writer->close_element( ). " items

      lo_writer->close_element( ). " labelform
      lo_writer->close_element( ). " form1


      "Output xml -> Jadikan method global biar ga ditulis beulang
      lo_string_writer ?= lo_writer.
      lv_xstring = lo_string_writer->get_output( ).

      lv_base64 = cl_web_http_utility=>encode_x_base64( lv_xstring ).
      lv_xml_data = lv_base64.
      TRY.
          TRY.
              DATA(lo_pdf_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                   comm_scenario  = 'YY1_ADOBE_FORMS_SRV'
              ).

              DATA(lo_pdf_client) = cl_web_http_client_manager=>create_by_http_destination( lo_pdf_destination ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Content-Type'
                i_value = 'application/json' ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Accept'
                i_value = 'application/json' ).

              lo_pdf_client->get_http_request( )->set_header_field(
                i_name  = 'Accept-Charset'
                i_value = 'UTF-8' ).

              "---- Request body
              TYPES: BEGIN OF ty_ads_body,
                       xdp_template       TYPE string,
                       xml_data           TYPE string,
                       form_type          TYPE string,
                       form_locale        TYPE string,
                       tagged_pdf         TYPE string,
                       embed_font         TYPE string,
                       change_not_allowed TYPE string,
                       print_not_allowed  TYPE string,
                     END OF ty_ads_body.

              DATA(ls_body) = VALUE ty_ads_body(
                xdp_template       = 'ZYUPI_SD_F_INT_INVOICEPEB_V1/ZYUPI_SD_T_INT_INVOICEPEB_V1'
                xml_data           = lv_xml_data
                form_type          = 'print'
                form_locale        = 'en_US'
                tagged_pdf         = '1'
                embed_font         = '0'
                change_not_allowed = 'false'
                print_not_allowed  = 'false'
              ).

              DATA(lv_json) =
                /ui2/cl_json=>serialize(
                  data        = ls_body
                  compress    = abap_true
                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

              lo_pdf_client->get_http_request( )->append_text( lv_json ).

              DATA(lo_response) =
                lo_pdf_client->execute( i_method = if_web_http_client=>post ).

              DATA(ls_status) = lo_response->get_status( ).

              DATA(lv_response) = lo_response->get_text( ).

              FIND REGEX '"fileContent":"([^"]+)"'
                IN lv_response
                SUBMATCHES DATA(lv_pdf_base64).
              "-------------------------------------------------
              " DESTINATION / COMM ARRANGEMENT ERROR
              "-------------------------------------------------
            CATCH cx_http_dest_provider_error INTO DATA(lx_dest2).
              DATA(lv_dest2) = lx_dest2->get_text( ).
              "-------------------------------------------------
              " HTTP CLIENT / EXECUTION ERROR
              "-------------------------------------------------
            CATCH cx_web_http_client_error INTO DATA(lx_http2).
              DATA(lv_http2) = lx_http2->get_text( ).
              "-------------------------------------------------
              " JSON / REGEX / UNEXPECTED ERROR
              "-------------------------------------------------
            CATCH cx_root INTO DATA(lx_root2).
              DATA(lv_root2) = lx_root2->get_text( ).
          ENDTRY.
          IF lv_pdf_base64 IS NOT INITIAL.
            DATA lv_pdf_xstring TYPE xstring.
            DATA lv_error TYPE string.
            TRY.
                lv_pdf_xstring = cl_web_http_utility=>decode_x_base64( lv_pdf_base64 ).
                MODIFY ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
                  ENTITY zyupi_sd_r_hcii
                    UPDATE FIELDS ( zattachment1 mimetype1 filename1 )
                    WITH VALUE #( ( %tky         = ls_data-%tky
                                    zattachment1 = lv_pdf_xstring
                                    mimetype1    = 'application/pdf'
                                    filename1    = |Invoice_PEB_{ ls_header-docno }.pdf| ) )
                  FAILED   DATA(ls_failed_pdf)
                  REPORTED DATA(ls_reported_pdf).
              CATCH cx_root INTO DATA(lx_root).
                lv_error = lx_root->get_text( ).
            ENDTRY.
          ENDIF.
      ENDTRY.          

      ENDTRY.

      "Mapping Items for Invoice Customer
    ENDIF.
    invpeb( ).
    "Insert xml to table header
  ENDMETHOD.

  METHOD valueheader.
    DATA : lr_delivery TYPE RANGE OF vbeln.

    READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
     ENTITY zyupi_sd_r_hcii
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(lt_data).

    READ TABLE lt_data INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.
      IF ls_data-zsoldtoparty IS INITIAL.
        APPEND VALUE #(
          %tky              = ls_data-%tky
          %state_area       = 'VALIDATE_MANDATORY'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Sold To Party is mandatory'
          )
          %element-zsoldtoparty  = if_abap_behv=>mk-on
        ) TO reported-zyupi_sd_r_hcii.

        APPEND VALUE #(
          %tky = ls_data-%tky
        ) TO failed-zyupi_sd_r_hcii.
      ENDIF.

      IF ls_data-zshiptoparty IS INITIAL.
        APPEND VALUE #(
          %tky              = ls_data-%tky
          %state_area       = 'VALIDATE_MANDATORY'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Ship To Party is mandatory'
          )
          %element-zshiptoparty  = if_abap_behv=>mk-on
        ) TO reported-zyupi_sd_r_hcii.

        APPEND VALUE #(
          %tky = ls_data-%tky
        ) TO failed-zyupi_sd_r_hcii.
      ENDIF.

      IF ls_data-zdoc_number_ci_indo IS INITIAL.
        APPEND VALUE #(
          %tky              = ls_data-%tky
          %state_area       = 'VALIDATE_MANDATORY'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Document Number is mandatory'
          )
          %element-zdoc_number_ci_indo  = if_abap_behv=>mk-on
        ) TO reported-zyupi_sd_r_hcii.

        APPEND VALUE #(
          %tky = ls_data-%tky
        ) TO failed-zyupi_sd_r_hcii.
      ELSE.
        SELECT SINGLE zuuid FROM zyupi_sd_t_hcii
          WHERE zdoc_number_ci_indo = @ls_data-zdoc_number_ci_indo
            AND zuuid              <> @ls_data-zuuid
          INTO @DATA(lv_dup).
        DATA(lv_duplicate) = xsdbool( sy-subrc = 0 ).

        IF lv_duplicate = abap_false.
          LOOP AT lt_data INTO DATA(ls_other)
               WHERE zdoc_number_ci_indo = ls_data-zdoc_number_ci_indo
                 AND zuuid              <> ls_data-zuuid.
            lv_duplicate = abap_true.
            EXIT.
          ENDLOOP.
        ENDIF.

        IF lv_duplicate = abap_true.
          APPEND VALUE #( %tky = ls_data-%tky ) TO failed-zyupi_sd_r_hcii.
          APPEND VALUE #( %tky = ls_data-%tky
            %state_area = 'VALIDATE_DOCNO'
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
              text = |Document Number { ls_data-zdoc_number_ci_indo } is already used| )
            %element-zdoc_number_ci_indo = if_abap_behv=>mk-on )
            TO reported-zyupi_sd_r_hcii.
        ENDIF.
      ENDIF.

      READ ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
          ENTITY zyupi_sd_r_hcii BY \_items
          FIELDS ( zdelivery_number zdelivery_item ) WITH VALUE #( ( %tky = ls_data-%tky ) )
          RESULT DATA(lt_existing_items).

      IF sy-subrc = 0.
        SORT lt_existing_items BY zdelivery_number.
        DELETE ADJACENT DUPLICATES FROM lt_existing_items COMPARING zdelivery_number.

        LOOP AT lt_existing_items INTO DATA(ls_existng).
          APPEND VALUE #( sign   = 'I'
                          option = 'EQ'
                          low    = ls_existng-zdelivery_number ) TO lr_delivery.
        ENDLOOP.

        SORT lr_delivery BY low.
        DELETE ADJACENT DUPLICATES FROM lr_delivery COMPARING low.

        IF lr_delivery IS NOT INITIAL.
          SELECT deliverydocument, soldtoparty, shiptoparty
            FROM i_deliverydocument WITH PRIVILEGED ACCESS
            WHERE deliverydocument IN @lr_delivery
            INTO TABLE @DATA(lt_delivery_parties).

          IF sy-subrc = 0.
            SORT lt_delivery_parties BY shiptoparty.
            DELETE ADJACENT DUPLICATES FROM lt_delivery_parties COMPARING shiptoparty.

            IF lines( lt_delivery_parties ) > 1.
              APPEND VALUE #(
                %tky              = ls_data-%tky
                %state_area       = 'VALIDATE_SHIPTO'
                %msg              = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = 'All items must have the same Ship-to Party!'
                )
              ) TO reported-zyupi_sd_r_hcii.

              APPEND VALUE #(
                %tky = ls_data-%tky
              ) TO failed-zyupi_sd_r_hcii.
            ENDIF.
          ENDIF.

          "Benerin biar ga ngebaca dari zuuid yg sama
          SELECT zdelivery_number
           FROM zyupi_sd_t_icii
           WHERE zdelivery_number IN @lr_delivery
           AND zuuid <> @ls_data-zuuid
           INTO TABLE @DATA(lt_deliv_item).

          IF sy-subrc = 0.
            APPEND VALUE #(
              %tky              = ls_data-%tky
              %state_area       = 'VALIDATE_DELIVERY'
              %msg              = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Some delivery documents have been processed !'
              )
            ) TO reported-zyupi_sd_r_hcii.

            APPEND VALUE #(
              %tky = ls_data-%tky
            ) TO failed-zyupi_sd_r_hcii.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD invpeb.

  ENDMETHOD.

ENDCLASS.