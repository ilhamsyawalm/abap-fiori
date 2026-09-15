CLASS lhc_xl06 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR xl06 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR xl06 RESULT result.

    METHODS processdata FOR MODIFY
       keys FOR ACTION xl06~processdata RESULT result.

ENDCLASS.

CLASS lhc_xl06 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processdata.

    DATA : lt_table    TYPE STANDARD TABLE OF zyupi_sd_t_insth,

           lt_create   TYPE TABLE FOR CREATE zyupi_sd_i_instruction,

           lr_business TYPE RANGE OF i_businesspartner-businesspartner,

           ls_table    TYPE zyupi_sd_t_insth.

* Get data from zyupi_sd_t_insth, I_SalesOrganizationText, I_CnsldtnDistributionChannel, I_BusinessPartner
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      SELECT cust_mat, sales_org, dist_channel, cust_country, sold_end, ship_end, material
       FROM zyupi_sd_t_insth
       WHERE cust_mat = @<fs_key>-cust_mat
         AND sales_org = @<fs_key>-sales_org
         AND dist_channel = @<fs_key>-dist_channel
         AND cust_country = @<fs_key>-cust_country
         AND sold_end = @<fs_key>-sold_end
         AND ship_end = @<fs_key>-ship_end
         AND material = @<fs_key>-material
       INTO TABLE @DATA(lt_insth).
      IF sy-subrc <> 0.
* Untuk SalesOrg dari field sales_org
        SELECT salesorganization
         FROM i_salesorganizationtext
         WHERE salesorganization = @<fs_key>-sales_org
         INTO TABLE @DATA(lt_salesorg).

        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Sales Organization { <fs_key>-sales_org } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.

* Untuk distchannel dari field dist_channel
        SELECT distributionchannel
         FROM i_cnsldtndistributionchannel
         WHERE distributionchannel = @<fs_key>-dist_channel
         INTO TABLE @DATA(lt_distchannel).

        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Distribution Channel { <fs_key>-dist_channel } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.
* Untuk Businesspartner dari field cust_country, sold_end, & ship_end
*    Assign semua 3 field ke type range
        lr_business = VALUE #(
          FOR ls IN keys
          (
            sign   = 'I'
            option = 'EQ'
            low    = |{ ls-cust_country ALPHA = IN }|
          )
          (
            sign   = 'I'
            option = 'EQ'
            low    = |{ ls-sold_end ALPHA = IN }|
          )
          (
            sign   = 'I'
            option = 'EQ'
            low    = |{ ls-ship_end ALPHA = IN }|
          )
        ).

* Select ke I_BusinessPartner
        SELECT businesspartner
         FROM i_businesspartner
         WHERE businesspartner IN @lr_business
         INTO TABLE @DATA(lt_business).

* Validate 3 field
        READ TABLE lt_business INTO DATA(ls_business) WITH KEY businesspartner = |{ <fs_key>-cust_country ALPHA = IN }|.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Customer Country { <fs_key>-cust_country } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.

        READ TABLE lt_business INTO ls_business WITH KEY businesspartner = |{ <fs_key>-sold_end ALPHA = IN }|.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Sold to End Customer { <fs_key>-sold_end } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.

        READ TABLE lt_business INTO ls_business WITH KEY businesspartner = |{ <fs_key>-ship_end ALPHA = IN }|.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Ship to End Customer { <fs_key>-ship_end } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.

*Validate material
        SELECT product
          FROM i_productdescription
          WHERE product = @<fs_key>-material
          INTO TABLE @DATA(lt_product).

        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Material { <fs_key>-material } not Found !|
            )
          ) TO reported-xl06.
          APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
          RETURN.
        ENDIF.

        "Modify Table Z untuk assign valuenya
        MOVE-CORRESPONDING <fs_key> TO ls_table.
        IF sy-subrc = 0.

          ls_table-created_by = cl_abap_context_info=>get_user_technical_name( ).
          ls_table-created_at = cl_abap_context_info=>get_system_date(  ).
          ls_table-last_changed_by = cl_abap_context_info=>get_user_technical_name( ).
          ls_table-last_changed_at = cl_abap_context_info=>get_system_date(  ).

*          zyupi_sd_cl_insth=>modify_table( is_table = ls_table ).
          APPEND VALUE #(
            %cid                = <fs_key>-%tky-cust_mat
            custmat             = <fs_key>-cust_mat
            salesorganization   = <fs_key>-sales_org
            distributionchannel = <fs_key>-dist_channel
            customercountry     = <fs_key>-cust_country
            soldtoendcustomer   = <fs_key>-sold_end
            shiptoendcustomer   = <fs_key>-ship_end
            material            = <fs_key>-material
            custmatdesc         = <fs_key>-cust_matdesc
            specialinstr        = <fs_key>-special_instr
            packing             = <fs_key>-packing
            expired             = <fs_key>-expired
*            createdat           = cl_abap_context_info=>get_system_date( )
*            createdby           = cl_abap_context_info=>get_user_technical_name( )
*            lastchangedat       = cl_abap_context_info=>get_system_date( )
*            lastchangedby       = cl_abap_context_info=>get_user_technical_name( )
          ) TO lt_create.

          "Bisa bikin kondisi kalo lt_create lengthnya/banyak row data sama dengan yg ada di itab, baru jalankan modifynya
          MODIFY ENTITIES OF zyupi_sd_i_instruction
            ENTITY insth
            CREATE FROM lt_create
            MAPPED DATA(ls_mapped)
            FAILED DATA(ls_failed)
            REPORTED DATA(ls_reported).
        ENDIF.

      ELSE.
        "Error karena customer material sudah ada di ztable
        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Customer Material { <fs_key>-cust_mat } Already assign|
          )
        ) TO reported-xl06.
        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-xl06.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.