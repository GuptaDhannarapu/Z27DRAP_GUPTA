@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Attachements interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z27D_I_SALES_ATTACH as select from y27d_db_attach
association to parent Z27D_I_SALES_ITEM as _soItem on
$projection.sales_doc = _soItem.sales_doc and
$projection.item_positon = _soItem.item_position
association to Z27D_I_SALES_HEAD as _sohead
on $projection.sales_doc = _sohead.sales_doc
{
    key vbeln as sales_doc,
    key posnr as item_positon,
    key attch_id as attach_Id,
    @Semantics.largeObject:{
    mimeType: 'Mimetype',
    fileName: 'Filename',
    contentDispositionPreference: #INLINE }
    @EndUserText.label: 'Document'
    document as Document,
    mimetype as Mimetype,
    filename as Filename,
    comments as Comments,
    _soItem,
    _sohead
}
