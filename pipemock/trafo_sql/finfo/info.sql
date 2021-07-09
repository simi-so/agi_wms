WITH

simi_trafo_wms_dp_pubstate_v AS (
  SELECT 
    * 
  FROM
    simi.trafo_wms_dp_pubstate_v
  WHERE
    identifier LIKE 'test.info%'
),

tv_with_geom AS (
  SELECT 
    attr_3props_json,
    tv_id
  FROM
    simi.simidata_table_view tv 
  JOIN
    simi.trafo_wms_pg_table_v tbl ON tv.postgres_table_id = tbl.table_id
  JOIN
    simi.trafo_tableview_attr_geo_append_v a ON tv.id = a.tv_id
  WHERE 
    tbl.has_geometry IS TRUE
),

dsv_dependency_unique AS ( -- Stellt sicher, dass bei Fehlerfassung pro dsv nur eine custom info zurückgegeben wird
  SELECT 
    data_set_view_id,
    d.dtype AS dependency_type,
    (max(dependency_id::varchar))::uuid AS dependency_id
  FROM
    simi.simiextended_relation r
  JOIN
    simi.simiextended_dependency d ON r.dependency_id = d.id
  WHERE
    r.relation_type = '1_display'
  GROUP BY
    data_set_view_id,
    d.dtype
),

custom_info AS (
  SELECT
    py_module_name,
    sql_query, 
    display_template,
    CASE
      WHEN sql_query IS NOT NULL THEN 'sql'
      WHEN py_module_name IS NOT NULL THEN 'module'
      ELSE 'wms'
    END AS info_type,
    CASE
      WHEN sql_query IS NOT NULL THEN 'dummy service name'
      ELSE NULL
    END AS sql_service_name,
    data_set_view_id
  FROM
    simi.simiextended_dependency d
  JOIN
    dsv_dependency_unique dd ON d.id = dd.dependency_id
  WHERE
    dependency_type = 'simiExtended_FeatureInfo'
),


custom_info_json AS (
  SELECT
    jsonb_strip_nulls(
      jsonb_build_object(
        'type', info_type,
        'db_url', sql_service_name,
        'sql', sql_query,
        'module', py_module_name,
        'template', display_template
      )
    ) AS info_json,
    data_set_view_id
  FROM
    custom_info
),

feature_report AS (
  SELECT
    name AS rep_name,
    data_set_view_id
  FROM
    simi.simiextended_dependency d
  JOIN
    dsv_dependency_unique dd ON d.id = dd.dependency_id
  WHERE
    dependency_type = 'simiExtended_Report'
),

dsv AS (
  SELECT 
    jsonb_strip_nulls(
      jsonb_build_object(
        'name', identifier,
        'title', COALESCE(title, identifier),
        'attributes', attr_3props_json,
        'info_template', info_json,
        'feature_report', rep_name
      )
    ) AS dsv_json,
    dsv.id AS dsv_id
  FROM
    simi.simidata_data_set_view dsv
  JOIN
    simi_trafo_wms_dp_pubstate_v dp ON dsv.id = dp.dp_id
  LEFT JOIN
    tv_with_geom tg ON dsv.id = tg.tv_id
  LEFT JOIN
    custom_info_json i ON dsv.id = i.data_set_view_id
  LEFT JOIN
    feature_report rep ON dsv.id = rep.data_set_view_id
  WHERE
    dp.published IS TRUE     
),

facade_dsv AS (
  SELECT
    jsonb_agg(dsv_json) AS dsv_json,
    facade_layer_id AS fl_id
  FROM
    dsv d
  JOIN
    simi.simiproduct_properties_in_facade pif ON d.dsv_id = pif.data_set_view_id 
  GROUP BY 
    facade_layer_id
),

facade AS (
  SELECT
    jsonb_build_object(
        'name', identifier,
        'title', COALESCE(title, identifier),
        'layers', dsv_json
    ) AS fl_json
  FROM
    simi.simiproduct_facade_layer fl
  JOIN
    simi_trafo_wms_dp_pubstate_v dp ON fl.id = dp.dp_id
  JOIN
    facade_dsv fd ON fl.id = fd.fl_id
  WHERE
    published IS TRUE
)

SELECT dsv_json AS sa_json FROM dsv
UNION ALL
SELECT fl_json AS sa_json FROM facade
