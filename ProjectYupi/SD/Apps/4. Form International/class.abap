CLASS lhc_ztest_sd_r_h_from DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ztest_sd_r_h_from RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR ztest_sd_r_h_from RESULT result.

    METHODS setitems FOR DETERMINE ON MODIFY
       keys FOR ztest_sd_r_h_from~setitems.
    METHODS setparty FOR DETERMINE ON MODIFY
       keys FOR ztest_sd_r_h_from~setparty.

ENDCLASS.

CLASS lhc_ztest_sd_r_h_from IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setparty.
    READ ENTITIES OF ztest_sd_r_h_from IN LOCAL MODE
      ENTITY ztest_sd_r_h_from
        FIELDS ( deliverydocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.
      SELECT deliverydocument, soldtoparty, shiptoparty
       FROM i_deliverydocument
       WHERE deliverydocument = @ls_data-deliverydocument
       INTO TABLE @DATA(lt_delivery).

      IF sy-subrc = 0.
        READ TABLE lt_delivery INTO DATA(ls_delivery) INDEX 1.
        IF sy-subrc = 0.
          MODIFY ENTITIES OF ztest_sd_r_h_from IN LOCAL MODE
           ENTITY ztest_sd_r_h_from
           UPDATE FIELDS ( zsoldtoparty zshiptoparty )
           WITH VALUE #( ( %tky = ls_data-%tky
                           zsoldtoparty = ls_delivery-soldtoparty
                           zshiptoparty = ls_delivery-shiptoparty
           ) )
           REPORTED DATA(lt_reported).

          reported-ztest_sd_r_h_from = CORRESPONDING #( lt_reported-ztest_sd_r_h_from ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD setitems.
    READ ENTITIES OF ztest_sd_r_h_from IN LOCAL MODE
      ENTITY ztest_sd_r_h_from
        FIELDS ( deliverydocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_data) INDEX 1.
    IF sy-subrc = 0.

      " 1. Baca item yang sudah ada (existing items) untuk mendapatkan nomor urut terakhir
      READ ENTITIES OF ztest_sd_r_h_from IN LOCAL MODE
        ENTITY ztest_sd_r_h_from BY \_items
          FIELDS ( zdoc_number_ci_indo_item ) WITH VALUE #( ( %tky = ls_data-%tky ) )
        RESULT DATA(lt_existing_items).

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
             salesindo~transactioncurrency, deliv~yy1_referencedocument_dli
       FROM i_deliverydocumentitem AS deliv
       LEFT JOIN i_salesorderitem AS salesint ON deliv~yy1_referencedocument_dli = salesint~yy1_referencedocument_sdi
                                              AND deliv~yy1_referencedocumenti_dli = salesint~yy1_referencedocumenti_sdi
                                              AND salesint~salesorganization = '3100'
       LEFT JOIN i_salesorderitem AS salesindo ON deliv~yy1_referencedocument_dli = salesindo~yy1_referencedocument_sdi
                                               AND deliv~yy1_referencedocumenti_dli = salesindo~yy1_referencedocumenti_sdi
                                               AND salesindo~salesorganization = '1100'
       WHERE deliv~deliverydocument = @ls_data-deliverydocument
       INTO TABLE @DATA(lt_delivery).

      IF sy-subrc = 0.
        SORT lt_delivery BY deliverydocument deliverydocumentitem.

        MODIFY ENTITIES OF ztest_sd_r_h_from IN LOCAL MODE
          ENTITY ztest_sd_r_h_from
            CREATE BY \_items
            FIELDS ( zdoc_number_ci_indo_item zdelivery_number zdelivery_item zproduct zproduct_desc
                     zquantity zbaseunit zcif_int_price zcif_indo_price
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
                zcif_indo_price = ls_row-netamountindo
                zcurrency = ls_row-transactioncurrency
                zref_po_country = ls_row-yy1_referencedocument_dli
              ) )
            ) )
          MAPPED DATA(lt_mapped)
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.