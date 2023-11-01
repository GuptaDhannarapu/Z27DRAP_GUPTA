@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View of Sales Head'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity Z27D_C_SALES_HEAD
as projection on Z27D_I_SALES_HEAD
//composition[0..*] of Z27D_C_SALES_ITEM as _soItem
//association[1..*] to Z27D_C_SALES_ATTACH as _soAttach
//on $projection.sales_doc = _soAttach.sales_doc
{
    key sales_doc,
    created_at,
    created_by,
    sales_org,
    sales_dist,
    sales_div,
    @Semantics.amount.currencyCode: 'cost_currency'
    total_cost,
    cost_currency,
    block_status,
//    case block_status
//        when '98' then 2
//        when 'X' then 1
//        else 3 
//    end as block_status, 
//    case block_status
//        when '98' then 'yet to Approve'
//        when 'X' then 'Blocked'
//        else 'Approved'
//    end as block_status_msg, 
    LastChangedTimestamp,
    
    _soItem : redirected to composition child Z27D_C_SALES_ITEM
//    _soAttach :
}
