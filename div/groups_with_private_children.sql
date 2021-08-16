WITH

dsv_perm_base AS (
  SELECT 
    level_ AS perm_level,
    p.data_set_view_id AS dsv_id,
    role_id,
    (r."name" = 'public') AS is_public_role
  FROM 
    simi.simidata_data_set_view d
  JOIN
    simi.simiiam_permission p ON d.id = p.data_set_view_id 
  JOIN
    simi.simiiam_role r ON p.role_id = r.id  
),

dsv_public_perm AS (
  SELECT 
    *
  FROM 
    dsv_perm_base
  WHERE
    is_public_role IS TRUE 
),

dsv_private_perm AS (
  SELECT 
    *
  FROM 
    dsv_perm_base
  WHERE
    is_public_role IS FALSE  
),

dsv_perm AS ( -- Permissions einer Rolle für ein datasetview. Falls eine public PERMISSION besteht und diese höher ist, wird diese verwendet (übersteuerung)
  SELECT 
    sp.role_id,
    data_set_view_id AS dsv_id,
    CASE 
      WHEN COALESCE(perm_level, '0_non_public') > level_ THEN perm_level -- --> public permission level wins 
      ELSE level_
    END AS perm_level
  FROM 
    simi.simiiam_permission sp    
  LEFT JOIN
   dsv_public_perm p ON sp.data_set_view_id = p.dsv_id 
),

fl_public_perm AS (
  SELECT 
    role_id,
    facade_layer_id,
    min(perm_level) AS level_public,
    count(*) AS count_public
  FROM 
    simi.simiproduct_properties_in_facade pif
  JOIN
    dsv_public_perm p ON pif.data_set_view_id = p.dsv_id
  GROUP BY 
    facade_layer_id, role_id 
),

fl_private_perm AS (
  SELECT 
    role_id,
    facade_layer_id,
    min(perm_level) AS perm_level,
    count(*) AS count_private
  FROM 
    simi.simiproduct_properties_in_facade pif
  JOIN
    dsv_private_perm p ON pif.data_set_view_id = p.dsv_id
  GROUP BY 
    facade_layer_id, role_id 
),

fl_all_children_count AS (
  SELECT 
    facade_layer_id,
    count(*) AS count_all
  FROM 
    simi.simiproduct_properties_in_facade pif
  GROUP BY 
    facade_layer_id
),

/* Aus den Kindern abgeleitete Berechtigung einer Rolle für einen Facadelayer. 
 * 
 * Fl mit gemischten Berechtigungen public und 2-n private werden noch als berechtigt 
 * ausgegeben (was falsch ist). Dies wird in folgenden CTEs adressiert.
 */
fl_perm_raw AS (
  SELECT 
    COALESCE(priv.facade_layer_id, pub.facade_layer_id) AS fl_id,
    COALESCE(priv.role_id, pub.role_id) AS role_id,
    CASE 
      WHEN COALESCE(perm_level, '999_max_level') < COALESCE(level_public, '999_max_level') THEN COALESCE(perm_level, '999_max_level')
      ELSE COALESCE(level_public, '999_max_level')
    END AS perm_level, -- Falls sowohl private wie public vorhanden, "erbt" der fl den tiefsten level
    count_private,
    count_public  
  FROM
    fl_public_perm pub
  FULL OUTER JOIN
    fl_private_perm priv ON pub.facade_layer_id = priv.facade_layer_id
),

/* Aus den Kindern abgeleitete Berechtigung einer Rolle für einen Facadelayer. 
 * 
 * Mit der Where-Bedingung wird sichergestellt, dass Facadelayer mit teilweiser
 * Berechtigung für mehrere private Rollen nicht berechtigt werden.
 * Beispiel mit den privaten Rollen A und B, Public (P) und DatasetView 1-3:
 * 1 A
 * 2 B
 * 3 P
 * 
 * Der Facadelayer darf für keine der Rollen berechtigt werden. Im folgenen 
 * Beispiel darf der Facadelayer nur für B berechtigt sein:
 * 1 A,B
 * 2 B
 * 3 P
 */
fl_perm AS ( 
  SELECT
    fl_id,
    r.role_id,
    perm_level
  FROM
    fl_perm_raw r
  JOIN
    fl_all_children_count c ON r.fl_id = c.facade_layer_id
  WHERE
    count_all = COALESCE(count_public, 0) + COALESCE(count_private, 0) 
),

sa_perm_union AS ( -- permissions for single actors
  SELECT role_id, dsv_id AS sa_id, perm_level FROM dsv_perm
  UNION ALL 
  SELECT role_id, fl_id AS sa_id, perm_level FROM fl_perm
),

sa_perm AS (
  SELECT
    sa_id,  
    role_id,
    perm_level,
    (r."name" = 'public') AS is_public_role
  FROM 
    sa_perm_union sa
  JOIN
    simi.simiiam_role r ON sa.role_id = r.id  
),

layergroup_with_public_sa AS ( -- Alle Produktlisten mit 1-n "public" Kindern
  SELECT 
    lg.id AS lg_id,
    sa.role_id,
    min(sa.perm_level) AS level_public,
    count(*) AS count_public
  FROM
    simi.simiproduct_properties_in_list p
  JOIN
    sa_perm sa ON p.single_actor_id = sa.sa_id
  JOIN
    simi.simiproduct_layer_group lg ON p.product_list_id = lg.id
  WHERE
    sa.is_public_role IS TRUE 
  GROUP BY 
    lg.id, sa.role_id 
),

layergroup_with_private_sa AS ( -- Alle Layergruppen mit 1-n "private" Kindern
  SELECT 
    lg.id AS lg_id,
    sa.role_id,
    min(sa.perm_level) AS level_private,
    count(*) AS count_private
  FROM
    simi.simiproduct_properties_in_list p
  JOIN
    sa_perm sa ON p.single_actor_id = sa.sa_id
  JOIN
    simi.simiproduct_layer_group lg ON p.product_list_id = lg.id
  WHERE
    sa.is_public_role IS FALSE  
  GROUP BY 
    lg.id, sa.role_id 
),

pl_all_children_count AS (
  SELECT 
    product_list_id AS pl_id,
    count(*) AS count_all
  FROM
    simi.simiproduct_properties_in_list
  GROUP BY 
    product_list_id
),

lg_perm_raw AS ( -- Gleiche Logik wie bei fl_perm_raw
  SELECT 
    COALESCE(priv.lg_id, pub.lg_id) AS lg_id,
    COALESCE(priv.role_id, pub.role_id) AS role_id,
    CASE 
      WHEN COALESCE(level_private, '999_max_level') < COALESCE(level_public, '999_max_level') THEN COALESCE(level_private, '999_max_level')
      ELSE COALESCE(level_public, '999_max_level')
    END AS perm_level, -- Falls sowohl private wie public vorhanden, "erbt" die lg den tiefsten level
    COALESCE(count_public, 0) AS count_public,
    COALESCE(count_private, 0) AS count_private
  FROM
    layergroup_with_public_sa pub
  FULL OUTER JOIN
    layergroup_with_private_sa priv ON pub.lg_id = priv.lg_id
),

lg_perm AS ( 
  SELECT
    dp.title,
    dp.identifier,
    r.role_id,
    perm_level,
    count_all,
    count_public,
    count_private
  FROM
    lg_perm_raw r
  JOIN
    simi.simi.simiproduct_data_product dp ON r.lg_id = dp.id
  JOIN
    pl_all_children_count c ON r.lg_id = c.pl_id
  WHERE
      count_all = COALESCE(count_public, 0) + COALESCE(count_private, 0)
    AND
      count_private > 0
    AND
      count_public > 0
)

SELECT * FROM lg_perm