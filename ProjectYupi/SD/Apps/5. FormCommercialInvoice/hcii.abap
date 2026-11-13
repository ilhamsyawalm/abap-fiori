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
              totalqtycarton TYPE i_deliverydocumentitem-originaldeliveryquantity,
              totalvalue     TYPE zyupi_sd_t_icii-zfob_indo_price,
              freight        TYPE zyupi_sd_t_icii-zfob_indo_price,
              insurance      TYPE zyupi_sd_t_icii-zfob_indo_price,
              grandtotal     TYPE zyupi_sd_t_icii-zfob_indo_price,
              currency       TYPE zyupi_sd_t_icii-zcurrency,
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

            BEGIN OF ty_item,
              divtext     TYPE string,
              qtyincarton TYPE i_deliverydocumentitem-originaldeliveryquantity,
              totalprice  TYPE zyupi_sd_t_icii-zfob_indo_price,
            END OF ty_item.

    DATA : lt_item            TYPE STANDARD TABLE OF ty_item,

           ls_header          TYPE ty_header,
           ls_item            TYPE ty_item,

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

      SELECT SINGLE a~deliverydocument, a~incotermsclassification, a~incotermstransferlocation, d~paymenttermsname
        FROM i_deliverydocument WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~deliverydocument = b~deliverydocument
        INNER JOIN i_salesorderitem WITH PRIVILEGED ACCESS AS c ON b~yy1_referencedocument_dli = c~yy1_referencedocument_sdi
                                        AND b~yy1_referencedocumenti_dli = c~yy1_referencedocumenti_sdi
                                        AND c~salesorganization = '1100'
        INNER JOIN i_paymenttermstext WITH PRIVILEGED ACCESS AS d ON c~customerpaymentterms = d~paymentterms
                                          AND d~language = 'E'
        WHERE a~deliverydocument = @lv_deliv
        INTO @DATA(ls_shipping).

      DATA(lt_dupt_items) = lt_data_items.
      SORT lt_dupt_items BY zproduct.
      DELETE ADJACENT DUPLICATES FROM lt_dupt_items COMPARING zproduct.

      DATA(lt_po_items) = lt_data_items.
      SORT lt_po_items BY zref_po_country.
      DELETE ADJACENT DUPLICATES FROM lt_po_items COMPARING zref_po_country.

      IF lt_dupt_items IS NOT INITIAL.
        "Query ke table mas bony based on product & salesorg = 1100

        SELECT product, freight, insurance
         FROM zyupi_sd_t_pfi
         FOR ALL ENTRIES IN @lt_dupt_items
         WHERE product = @lt_dupt_items-zproduct
         AND salesorg = '1100'
         INTO TABLE @DATA(lt_pfi).

        SELECT a~division, b~divisionname
         FROM i_product WITH PRIVILEGED ACCESS AS a
         LEFT JOIN i_divisiontext AS b ON a~division = b~division
         FOR ALL ENTRIES IN @lt_dupt_items
         WHERE a~product = @lt_dupt_items-zproduct
         INTO TABLE @DATA(lt_division).

        SORT lt_division BY division.
        DELETE ADJACENT DUPLICATES FROM lt_division COMPARING division.
      ENDIF.

      "Mapping header
      ls_header-docno = ls_data-zdoc_number_ci_indo.
      ls_header-docdate = ls_data-zdoc_date_ci_indo.
      ls_header-contype = ls_data-zcont_type.
      ls_header-consealtara = |{ ls_data-zcont_seal_1 } { ls_data-zcont_seal_2 }|.
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

      ls_header-shipterms = |{ ls_shipping-incotermsclassification } { ls_shipping-incotermstransferlocation }|.
      ls_header-payterms = ls_shipping-paymenttermsname.
      ls_header-headernote = ls_data-zheader_note.
      ls_header-footernote = ls_data-zfooter_note.

      "Mapping Items
      LOOP AT lt_division INTO DATA(ls_division).
        CLEAR : ls_item.
        ls_item-divtext = ls_division-divisionname.
        " Sum zquantity
        ls_item-qtyincarton = REDUCE #(
          INIT q = 0
          FOR <item> IN lt_data_items
          " WHERE ( zdivision = ls_division-division ) " Opsional jika ada filter
          NEXT q = q + <item>-zquantity
        ).

        " Sum zfob_indo_price
        ls_item-totalprice = REDUCE #(
          INIT p = CONV f( 0 ) " Sesuaikan tipe data amount (misal: f, p, atau decfloat)
          FOR <item> IN lt_data_items
          NEXT p = p + <item>-zfob_indo_price
        ).
        ls_header-totalqtycarton = ls_header-totalqtycarton + ls_item-qtyincarton.
        ls_header-totalvalue = ls_header-totalvalue + ls_item-totalprice.
        ls_header-currency = VALUE #( lt_data_items[ 1 ]-zcurrency OPTIONAL ).
        APPEND ls_item TO lt_item.
      ENDLOOP.

      ls_header-ponumber = REDUCE string(
      INIT s = ``
      FOR <item> IN lt_po_items
      WHERE ( zref_po_country IS NOT INITIAL )
      NEXT s = COND #( WHEN s IS INITIAL THEN <item>-zref_po_country
                       ELSE s && |, | && <item>-zref_po_country )
     ).

      CLEAR: lv_total_freight, lv_total_insurance.
      LOOP AT lt_dupt_items INTO DATA(ls_dupt_items).
        READ TABLE lt_pfi INTO DATA(ls_pfi) WITH KEY product = ls_dupt_items-zproduct.
        IF sy-subrc = 0.
          lv_total_freight   = lv_total_freight   + ( ls_pfi-freight * ls_dupt_items-zquantity ).
          lv_total_insurance = lv_total_insurance + ( ls_pfi-insurance * ls_dupt_items-zquantity ).
        ENDIF.
      ENDLOOP.
      ls_header-freight   = lv_total_freight.
      ls_header-insurance = lv_total_insurance.

      ls_header-grandtotal = ls_header-totalvalue + ls_header-freight + ls_header-insurance.

      "Generate xml using method invpeb( )
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
      lo_writer->write_value( |{ ls_header-totalqtycarton }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'totalvalue' ).
      lo_writer->write_value( |{ ls_header-totalvalue }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'currency' ).
      lo_writer->write_value( |{ ls_header-currency }| ).
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
      lo_writer->write_value( |{ ls_header-freight }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'insurance' ).
      lo_writer->write_value( |{ ls_header-insurance }| ).
      lo_writer->close_element( ).

      lo_writer->open_element( name = 'grandtotal' ).
      lo_writer->write_value( |{ ls_header-grandtotal }| ).
      lo_writer->close_element( ).

      "Items
      lo_writer->open_element( name = 'ItemNode' ).

      lv_count = 0.
      LOOP AT lt_item INTO DATA(ls_iteminput).
        lv_count += 1.

        lo_writer->open_element( name = 'Item' ).

        lo_writer->open_element( name = 'NoItems' ).
        lo_writer->write_value( |{ lv_count }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'divtext' ).
        lo_writer->write_value( |{ ls_iteminput-divtext }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'qtyincarton' ).
        lo_writer->write_value( |{ ls_iteminput-qtyincarton }| ).
        lo_writer->close_element( ).

        lo_writer->open_element( name = 'totalprice' ).
        lo_writer->write_value( |{ ls_iteminput-totalprice }| ).
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
*                MODIFY ENTITIES OF zyupi_sd_r_hcii IN LOCAL MODE
*                 ENTITY zyupi_sd_r_hcii
*                 UPDATE FIELDS ( zattachment1 mimetype1 filename1 )
*                 WITH VALUE #( ( %tky = ls_data-%tky
*                                 zattachment1 = lv_pdf_xstring
*                                 mimetype1 = 'application/pdf'
*                                 filename1 = |Invoice_PEB_{ ls_header-docno }.pdf|
*                 ) )
*                 REPORTED DATA(lt_reported).
*
*                reported-zyupi_sd_r_hcii = CORRESPONDING #( lt_reported-zyupi_sd_r_hcii ).
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