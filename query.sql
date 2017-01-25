SELECT *
FROM (
       SELECT
         started_state,
         avg(time_spent) / 60,
         pkey
       FROM (
              SELECT
                ji.ID,
                #   ji.SUMMARY,
                #   cg.id  AS old,
                #   cg2.id AS new,
                ci_old.NEWSTRING                                    AS started_state,
                #   ci_new.OLDSTRING as end_state,
                #   ids1.row,
                #   ids2.row,
                sum(timestampdiff(MINUTE, cg.created, cg2.CREATED)) AS time_spent,
                PROJECT.pkey
              FROM jiraissue ji
                JOIN project ON ji.PROJECT = project.id AND PROJECT.pkey IN ('TS', 'PE', 'TSI')
                JOIN changegroup cg ON cg.issueid = ji.ID
                JOIN changegroup cg2 ON cg.issueid = cg2.issueid
                JOIN (
                       SELECT
                         listed1.id,
                         listed1.issueid,
                         @rownum1 := @rownum1 + 1 AS row
                       FROM
                         (SELECT
                            incg.ID AS id,
                            incg.issueid
                          FROM changegroup incg
                            JOIN changeitem inci ON inci.groupid = incg.ID AND inci.field = 'status'
                          ORDER BY incg.issueid, incg.created) listed1
                         CROSS JOIN (SELECT @rownum1 := 0) r) ids1 ON ids1.id = cg.ID
                JOIN (
                       SELECT
                         listed2.id,
                         @rownum2 := @rownum2 + 1 AS row
                       FROM
                         (SELECT incg.ID AS id
                          FROM changegroup incg
                            JOIN changeitem inci ON inci.groupid = incg.ID AND inci.field = 'status'
                          ORDER BY incg.issueid, incg.created) listed2
                         CROSS JOIN (SELECT @rownum2 := 0) r) ids2 ON ids2.id = cg2.ID
                JOIN changeitem ci_old ON ci_old.groupid = cg.id AND ci_old.FIELD = 'status'
                JOIN changeitem ci_new
                  ON ci_new.groupid = cg2.id AND ci_new.FIELD = 'status' /*AND ci_new.OLDSTRING = ci_old.NEWSTRING */AND
                     ids2.row = ids1.row + 1
              WHERE ji.CREATED > date_sub(now(), INTERVAL 30 DAY)
              GROUP BY ji.ID, ci_old.NEWSTRING, PROJECT.pkey) summed
       GROUP BY started_state, pkey
     ) avged
  JOIN (SELECT
          issuestatus.pname,
          c.NAME,
          c.POS,
          rv.ID,
          (CASE rv.ID
           WHEN 290
             THEN 'TS'
           WHEN 357
             THEN 'PE'
           WHEN 690
             THEN 'TSI' END) AS pkey
        FROM AO_60DB71_COLUMN c
          JOIN AO_60DB71_RAPIDVIEW rv
            ON rv.ID = c.RAPID_VIEW_ID AND rv.ID IN (290 /* TS */, 357 /* PE */, 690 /* TSI */)
          JOIN AO_60DB71_COLUMNSTATUS cs ON c.ID = cs.COLUMN_ID AND cs.POS = 0
          JOIN issuestatus ON issuestatus.ID = cs.STATUS_ID
        ORDER BY rv.ID, c.POS) orders ON orders.pkey = avged.pkey AND orders.pname = started_state
ORDER BY orders.pkey, orders.POS;
