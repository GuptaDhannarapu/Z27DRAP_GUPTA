@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Attachements Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z27D_C_SALES_ATTACH as projection on Z27D_I_SALES_ATTACH
//association to parent Z27D_C_SALES_ITEM as _soItem on
//$projection.sales_doc = _soItem.sales_doc and
//$projection.item_positon = _soItem.item_position
{
    key sales_doc,
    key item_positon,
    key attach_Id,
    Document,
    Mimetype,
    Filename,
    Comments,
    _soItem : redirected to parent Z27D_C_SALES_ITEM,
    _sohead : redirected to Z27D_C_SALES_HEAD
}
