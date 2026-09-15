CLASS lhc_xl06 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA : lv_error TYPE abap_bool.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR xl06 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR xl06 RESULT result.

    METHODS processdata FOR MODIFY
      keys FOR ACTION xl06~processdata.

*    METHODS processdata FOR MODIFY
*       keys FOR ACTION xl06~processdata RESULT result.

ENDCLASS.

CLASS lhc_xl06 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processdata.

    DATA: lt_table    TYPE STANDARD TABLE OF zyupi_sd_t_insth,
          lt_create   TYPE TABLE FOR CREATE zyupi_sd_i_instruction,

          lr_business TYPE RANGE OF i_businesspartner-businesspartner,

          ls_table    TYPE zyupi_sd_t_insth.

    " 1. Buat Range untuk Business Partner secara massal (di luar loop)
    lr_business = VALUE #(
      FOR ls IN keys ( sign = 'I' option = 'EQ' low = |{ ls-cust_country ALPHA = IN }| )
                     ( sign = 'I' option = 'EQ' low = |{ ls-sold_end ALPHA = IN }| )
                     ( sign = 'I' option = 'EQ' low = |{ ls-ship_end ALPHA = IN }| )
    ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      " Check Duplicate Data
      SELECT SINGLE cust_mat
        FROM zyupi_sd_t_insth
        WHERE cust_mat     = @<fs_key>-cust_mat
          AND sales_org    = @<fs_key>-sales_org
          AND dist_channel = @<fs_key>-dist_channel
          AND cust_country = @<fs_key>-cust_country
          AND sold_end     = @<fs_key>-sold_end
          AND ship_end     = @<fs_key>-ship_end
          AND material     = @<fs_key>-material
        INTO @DATA(lv_cust_mat_exist).

      IF sy-subrc = 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Customer Material { <fs_key>-cust_mat } Already assigned|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      " Validate Sales Org
      SELECT SINGLE salesorganization
        FROM i_salesorganizationtext
        WHERE salesorganization = @<fs_key>-sales_org
        INTO @DATA(lv_sales_org).

      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Sales Organization { <fs_key>-sales_org } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      " Validate Dist Channel
      SELECT SINGLE distributionchannel
        FROM i_cnsldtndistributionchannel
        WHERE distributionchannel = @<fs_key>-dist_channel
        INTO @DATA(lv_dist_channel).

      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Distribution Channel { <fs_key>-dist_channel } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      " Validate Business Partners
      SELECT businesspartner
        FROM i_businesspartner
        WHERE businesspartner IN @lr_business
        INTO TABLE @DATA(lt_business).

      READ TABLE lt_business INTO DATA(ls_business) WITH KEY businesspartner = |{ <fs_key>-cust_country ALPHA = IN }|.
      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Customer Country { <fs_key>-cust_country } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      READ TABLE lt_business INTO ls_business WITH KEY businesspartner = |{ <fs_key>-sold_end ALPHA = IN }|.
      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Sold to End Customer { <fs_key>-sold_end } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      READ TABLE lt_business INTO ls_business WITH KEY businesspartner = |{ <fs_key>-ship_end ALPHA = IN }|.
      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Ship to End Customer { <fs_key>-ship_end } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      " Validate Material
      SELECT SINGLE product
        FROM i_productdescription
        WHERE product = @<fs_key>-material
        INTO @DATA(lv_product).

      IF sy-subrc <> 0.
        lv_error =  abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Material { <fs_key>-material } not Found !|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <fs_key> TO ls_table.
      ls_table-created_by = cl_abap_context_info=>get_user_technical_name( ).
      ls_table-created_at = cl_abap_context_info=>get_system_date(  ).
      ls_table-last_changed_by = cl_abap_context_info=>get_user_technical_name( ).
      ls_table-last_changed_at = cl_abap_context_info=>get_system_date(  ).
      TRY.
          zyupi_sd_cl_insth=>modify_table( is_table = ls_table ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      " Assign ke lt_create dengan %cid unik (misal menggunakan sy-tabix atau %tky)

*      APPEND VALUE #(
*        %cid                = |CID_{ sy-tabix }|
*        custmat             = <fs_key>-cust_mat
*        salesorganization   = <fs_key>-sales_org
*        distributionchannel = <fs_key>-dist_channel
*        customercountry     = <fs_key>-cust_country
*        soldtoendcustomer   = <fs_key>-sold_end
*        shiptoendcustomer   = <fs_key>-ship_end
*        material            = <fs_key>-material
*        custmatdesc         = <fs_key>-cust_matdesc
*        specialinstr        = <fs_key>-special_instr
*        packing             = <fs_key>-packing
*        expired             = <fs_key>-expired
*      ) TO lt_create.

    ENDLOOP.

    " Execute CREATE secara sekaligus di luar LOOP
    IF lt_create IS NOT INITIAL AND lv_error <> abap_true.
*      MODIFY ENTITIES OF zyupi_sd_i_instruction
*        ENTITY insth
*        CREATE FROM lt_create
*        MAPPED DATA(ls_mapped)
*        FAILED DATA(ls_failed)
*        REPORTED DATA(ls_reported).
*
*      " Gabungkan error/message dari EML jika ada
*      failed-xl06   = CORRESPONDING #( BASE ( failed-xl06 ) ls_failed-insth ).
*      reported-xl06 = CORRESPONDING #( BASE ( reported-xl06 ) ls_reported-insth ).
    ENDIF.

    " POPULATE RESULT (Wajib untuk Action yang mendefinisikan RESULT)
    " Sesuaikan %param dengan struktur CDS/Entity insth Anda
*    READ ENTITIES OF zyupi_sd_i_instruction
*      ENTITY insth
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_result_entities).
*
*    result = VALUE #( FOR ls_res IN lt_result_entities (
*     %tky   = CORRESPONDING #( ls_res-%tky )
*     %param = CORRESPONDING #( ls_res )
*   ) ).

  ENDMETHOD.

ENDCLASS.