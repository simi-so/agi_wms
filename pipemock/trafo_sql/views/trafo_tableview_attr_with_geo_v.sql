
DROP VIEW IF EXISTS simi.trafo_tableview_attr_geo_append_v;

CREATE VIEW simi.trafo_tableview_attr_geo_append_v AS 

/* Gibt die Attribute einer Tableview inkl. Geometrie-Platzhalterspalte zurück.
 * */
WITH 

tableview_nongeo_attr AS ( 
  SELECT
    table_view_id as tv_id,
    tf."name" as attr_name,
    vf.sort 
  FROM 
    simi.simidata_view_field vf 
  JOIN
    simi.simidata_table_field tf on vf.table_field_id = tf.id 
),

tableview_geo_attr as ( 
  SELECT  
    tv.id as tv_id,
    'geometry' AS attr_name,
    99999 AS sort
  FROM  
    simi.simi.simidata_table_view tv
  JOIN 
    simi.simi.simidata_postgres_table t ON tv.postgres_table_id = t.id
  WHERE 
      t.geo_field_name IS NOT NULL
    AND
      t.geo_type IS NOT NULL
    AND 
      t.geo_epsg_code IS NOT NULL 
),

tableview_attr_union AS (
  SELECT tv_id, attr_name, sort FROM tableview_nongeo_attr
  UNION ALL 
  SELECT tv_id, attr_name, sort FROM tableview_geo_attr
)

SELECT 
  tv_id,
  jsonb_agg(attr_name ORDER BY sort) AS attr_names_json
FROM
  tableview_attr_union
GROUP BY 
  tv_id
;





