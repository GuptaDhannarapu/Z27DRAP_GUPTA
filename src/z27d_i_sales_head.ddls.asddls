@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Head interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity Z27D_I_SALES_HEAD as select from y27d_db_vbak as soHead
composition[0..*] of Z27D_I_SALES_ITEM as _soItem
//association[1..*] to Z27D_I_SALES_ITEM as _soItem
//on $projection.sales_doc = _soItem.sales_doc
{
    key vbeln as sales_doc,
    erdat as created_at,
    @Semantics.user.createdBy: true
    ernam as created_by,
    vkorg as sales_org,
    vtweg as sales_dist,
    spart as sales_div,
    @Semantics.amount.currencyCode: 'cost_currency'
    netwr as total_cost,
    waerk as cost_currency,
    faksk as block_status,
    case faksk
        when '98' then 2
        when 'X' then 1
        else 3 
    end as faksk, 
    case faksk
        when '98' then 'yet to Approve'
        when 'X' then 'Blocked'
        else 'Approved'
    end as block_status_msg, 
    last_changed_timestamp as LastChangedTimestamp,
    _soItem 
}
