CLASS lsc_z27d_c_sales_head DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS cleanup_finalize REDEFINITION.
    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z27d_c_sales_head IMPLEMENTATION.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD save_modified.
DATA ls_so_head TYPE y27d_db_vbak.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_db_vbak.
    SELECT FROM y27d_db_vbak FIELDS MAX( vbeln ) INTO @DATA(lv_fin_vbeln).
    GET TIME STAMP FIELD FINAL(lv_time_stamp).
    IF create-sohead IS NOT INITIAL.
      MODIFY y27d_db_vbak FROM TABLE @( VALUE #( FOR ls_so IN create-sohead
                            LET ls_final = VALUE y27d_db_vbak( erdat = sy-datum
                                                               ernam = sy-uname
                                                               vbeln = lv_fin_vbeln + 1  )
                            IN (  CORRESPONDING #( BASE ( ls_final ) ls_so MAPPING
                                                             vkorg = sales_org
                                                             vtweg = sales_dist
                                                             spart = sales_div
                                                             waerk = cost_currency
                                                             faksk = block_status
                                                             netwr = total_cost
                                                     EXCEPT vbeln erdat ernam ) ) ) ).
    ENDIF.
    IF update-sohead IS NOT INITIAL.
      DATA ls_so_cont TYPE zif_structure=>ts_control.
      DATA:lt_so_cont    TYPE zif_structure=>tt_control,
           lv_total_cost TYPE y27d_db_vbak-netwr.

      GET TIME STAMP FIELD FINAL(lv_time).
      LOOP AT update-sohead ASSIGNING FIELD-SYMBOL(<fs_entity>).

        ls_so_head = CORRESPONDING #( <fs_entity> MAPPING
                     erdat = created_at
                     ernam = created_by
                     faksk = block_status
                     netwr = total_cost
                     spart = sales_div
                     vbeln = sales_doc
                     vkorg = sales_org
                     waerk = cost_currency
                     vtweg = sales_dist ).
        ls_so_head-last_changed_timestamp = lv_time.

        APPEND ls_so_head TO lt_so_head.

        ls_so_cont = CORRESPONDING #( <fs_entity>-%control MAPPING
                                      erdat = created_at
                       ernam = created_by
                       faksk = block_status
                       netwr = total_cost
                       spart = sales_div
                       vbeln = sales_doc
                       vkorg = sales_org
                       waerk = cost_currency
                       vtweg = sales_dist
                       last_changed_timestamp = LastChangedTimestamp ).
        ls_so_cont-vbeln_id = ls_so_head-vbeln.
        APPEND ls_so_cont TO lt_so_cont.

      ENDLOOP.
*      IF lt_so_head IS NOT INITIAL.
*        SELECT * FROM y27d_db_vbap FOR ALL ENTRIES IN @lt_so_head
*        WHERE vbeln EQ @lt_so_head-vbeln
*        INTO TABLE @DATA(lt_so_vbap).
*        IF lt_so_vbap IS NOT INITIAL.
*          READ ENTITIES OF z27d_c_sales_head IN LOCAL MODE
*              ENTITY soItem
*              FIELDS ( sales_doc_num item_position quanity unit_cost ) WITH CORRESPONDING #( lt_so_head MAPPING sales_doc_num = vbeln )
*              RESULT DATA(lt_so_item).
*          LOOP AT lt_so_item ASSIGNING FIELD-SYMBOL(<fs_so_item>).
*            lt_so_vbap[ vbeln = <fs_so_item>-sales_doc_num
*                        posnr = <fs_so_item>-item_position ]-netwr = <fs_so_item>-total_item_cost.
*          ENDLOOP.
*          LOOP AT lt_so_vbap ASSIGNING FIELD-SYMBOL(<fs_so_vbap>).
*            lv_total_cost = lv_total_cost + <fs_so_vbap>-netwr.
*            DATA(lv_vbeln) = <fs_so_vbap>-vbeln.
*          ENDLOOP.
*          lt_so_head[ vbeln = lv_vbeln ]-netwr = lv_total_cost.
*          lt_so_cont[ vbeln_id = lv_vbeln ]-netwr = 01.
*        ENDIF.
*      ENDIF.
      y27d_cl_operation_un=>get_instance( )->buffer_so_head_update( it_so_h = lt_so_head
                                                                    it_so_c = lt_so_cont ).

      y27d_cl_operation_un=>get_instance(  )->save(  ).

    ENDIF.
    IF delete IS NOT INITIAL.
      DATA: lr_so_doc TYPE RANGE OF y27d_db_vbak-vbeln.
      lr_so_doc = VALUE #( BASE lr_so_doc FOR ls_sohead IN delete-sohead
                           ( sign = 'I' option ='EQ' low = ls_sohead-sales_doc )  ).

      DELETE FROM y27d_db_vbak WHERE vbeln IN @lr_so_doc.

    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_Z27D_C_SALES_HEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR z27d_c_sales_head RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR sohead RESULT result.

    METHODS blockorder FOR MODIFY
      IMPORTING keys FOR ACTION sohead~blockorder RESULT result.

    METHODS unblockorder FOR MODIFY
      IMPORTING keys FOR ACTION sohead~unblockorder RESULT result.

ENDCLASS.

CLASS lhc_Z27D_C_SALES_HEAD IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  DATA lt_result LIKE LINE OF result.

    SELECT * FROM y27d_db_vbak
    FOR ALL ENTRIES IN @keys
    WHERE vbeln = @keys-sales_doc
    INTO TABLE @FINAL(lt_so_head).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_so_head ASSIGNING FIELD-SYMBOL(<fs_so_head>).
      lt_REsult = VALUE #( sales_doc        = <fs_so_head>-vbeln

                           %update             = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %delete              = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

*                           %assoc-_soItem      = COND #( WHEN <fs_so_head>-faksk = 'X'
*                                                          THEN if_abap_behv=>fc-f-read_only
*                                                          ELSE if_abap_behv=>fc-f-unrestricted )


                           %action-blockOrder   = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-o-disabled
                                                          ELSE if_abap_behv=>fc-o-enabled )

                           %action-unblockOrder = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          ELSE if_abap_behv=>fc-o-disabled ) ).

      APPEND lt_result TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD blockOrder.
  READ ENTITIES OF z27d_c_sales_head IN LOCAL MODE
    ENTITY Sohead
    FIELDS ( block_status block_status_msg  ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_so_head).
    LOOP AT lt_so_head ASSIGNING FIELD-SYMBOL(<fs_so_head>).
      MODIFY ENTITIES OF z27d_c_sales_head IN LOCAL MODE
     ENTITY Sohead
     UPDATE
     FIELDS ( block_status ) WITH VALUE #( ( %tky = <fs_so_head>-%tky
                                            block_status = 1 ) ).
    ENDLOOP.
*    y27d_cl_operation_un=>get_instance( )->buffer_so_order_block( it_so_h = lt_so_h
*                                                                  iv_para = 'X' ).
    result = VALUE #( FOR ls_so_h1 IN lt_so_head
                      ( sales_doc           = ls_so_h1-sales_doc
                        %param-sales_doc    = ls_so_h1-sales_doc
                        %param-block_status_msg = ls_so_h1-block_status ) ).
  ENDMETHOD.

  METHOD unblockOrder.
  READ ENTITIES OF z27d_c_sales_head IN LOCAL MODE
    ENTITY Sohead
    FIELDS ( block_status block_status_msg  ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_so_head).
    LOOP AT lt_so_head ASSIGNING FIELD-SYMBOL(<fs_so_head>).
      MODIFY ENTITIES OF z27d_c_sales_head IN LOCAL MODE
     ENTITY Sohead
     UPDATE
     FIELDS ( block_status ) WITH VALUE #( ( %tky = <fs_so_head>-%tky
                                            block_status = 3 ) ).
    ENDLOOP.
*    y27d_cl_operation_un=>get_instance( )->buffer_so_order_block( it_so_h = lt_so_h
*                                                                  iv_para = 'X' ).
    result = VALUE #( FOR ls_so_h1 IN lt_so_head
                      ( sales_doc           = ls_so_h1-sales_doc
                        %param-sales_doc    = ls_so_h1-sales_doc
                        %param-block_status_msg = ls_so_h1-block_status ) ).
  ENDMETHOD.

ENDCLASS.
