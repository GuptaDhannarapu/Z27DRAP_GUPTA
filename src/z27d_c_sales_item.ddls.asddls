@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Item consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z27D_C_SALES_ITEM as projection on Z27D_I_SALES_ITEM
//association to parent Z27D_C_SALES_HEAD as _sohead on
//$projection.sales_doc = _sohead.sales_doc
//composition[0..*] of Z27D_C_SALES_ATTACH as _attach

{
    key sales_doc,
    key item_position,
    mat_num,
    mat_desc,
    @Semantics.amount.currencyCode: 'cost_currency'
    unit_cost,
    @Semantics.amount.currencyCode: 'cost_currency'
    total_item_cost,
    cost_currency,
    @Semantics.quantity.unitOfMeasure: 'unit'
    quanity,
    unit,
    last_changed,
    _sohead : redirected to parent Z27D_C_SALES_HEAD,
    _soattach : redirected to composition child Z27D_C_SALES_ATTACH
}
