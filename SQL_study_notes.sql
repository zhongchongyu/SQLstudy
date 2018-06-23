 /* ******************************************************************************************************************************************** */
 /* ***************************************************************** 初级 ********************************************************************* */
 /* ******************************************************************************************************************************************** */
 
-- 这里是筛选纵列
SELECT  year AS "Year"             -- SQL中 双引号 通常来表示要指定的列名
        ,month AS "Month"
        ,month_name AS "MonthName"
        ,south AS "South"
        ,west AS "West"
        ,midwest AS "MidWest"
        ,northeast AS "NorthEast"
        ,west + south - 4*year AS "NonseasonCol"
	FROM tutorial.us_housing_units
	
	WHERE month_name LIKE 'J%'               -- 若不区分大小写则使用 ILIKE 
		AND year NOT IN (1996,1997,1998)
		AND (year BETWEEN 1996 AND 1999     -- 相当于: >= AND <=
			OR west IS NULL)

	/* 这里不进行筛选，仅仅改变结构 */
	ORDER BY Year DESC, month         -- 可以对多个列进行排序，默认升序，若要降序则加上 DESC； 另外列名可以通过数字来替换：ORDER BY 1 DESC, 2
	LIMIT 1000
  
  
-- 查询字句的顺序： 
SELECT
FROM
WHERE       -- WHERE 是在聚合之前 对整个表进行过滤
GROUP BY    -- 这时新的表还没有生成，所以 GROUP BY 后面的字段应该用原名，不能用 AS 后的名字
HAVING      -- HAVING 实在聚合的时候 对组进行过滤，因此需要包含聚合函数
ORDER BY    -- 这时新的表 SELECT 的表已经生成了，所以 ORDER BY 后面可以接 AS 后的名字
LIMIT
 
 /* ******************************************************************************************************************************************** */
 /* ***************************************************************** 中级 ********************************************************************* */
 /* ******************************************************************************************************************************************** */
 
 /*
  * 中级的主要内容包括：
  * 聚合函数(COUNT; SUM; MIN/MAX; AVG)
  * GROUP BY, 以及对分组的筛选：HAVING
  * JOIN(INNER JOIN; LEFT JOIN; RIGHT JOIN; FULL OUTER JOIN), 
  * 	以及 JOIN 有关的筛选('AND'连接作为 ON 的条件，仅对合并前某个表进行过滤，而'WHERE'连接作为筛选条件，对合并后的整张表进行过滤)
  *		以及多键的 JOIN （就是在 JOIN 后面用 AND 连接，	且 AND 后面是等式限制）和 self-JOIN （通常用来筛选）
  * UNION， 纵向拼接（JOIN是横向拼接）
  *
  * DISTINCT
  * CASE, 通过类似 if 语句的方法，创造一个新的变量
  * 
  */
 
-- 聚合函数
SELECT  COUNT(month) AS CountYear
        ,SUM(month) AS SumMonth
        ,MIN(month) AS MinMonth
        ,MAX(month) AS MaxMonth
        ,AVG(month) AS Avgmonth
	FROM tutorial.us_housing_units
  
  
-- GROUP BY
-- 执行顺序是：先执行 FROM ，找到数据集后执行 GROUP BY ，最后执行 SELECT
SELECT 	year
		,MIN(low)
        ,month
		,MAX(high)
	FROM tutorial.aapl_historical_stock_price
	GROUP BY 1, 3        -- 这个 1，3是指前面select后面的第几个列
    ORDER BY year, month
  
  
-- DISTINCT
SELECT 	DISTINCT year,month      -- 只筛选相应列的唯一组合值
	FROM tutorial.aapl_historical_stock_price
  
SELECT	COUNT(distinct year) as "count year"
		,COUNT(DISTINCT month) as "count month"
	FROM tutorial.aapl_historical_stock_price
  
  
-- CASE         -- 其实就是 SQL 中的 if 语句     从 case 到 end 之间的所有内容，其实就相当于一个新的列
SELECT 	player_name
		,weight
		,CASE WHEN weight > 250 THEN 'over 250'
			 WHEN weight > 200 THEN '201-250'
			 WHEN weight > 175 THEN '176-200'
			 ELSE '175 or under' END AS weight_group
	FROM benn.college_football_players

SELECT 	COUNT(CASE WHEN year = 'FR' THEN 1 ELSE NULL END) AS fr_count
		,COUNT(CASE WHEN year = 'SO' THEN 1 ELSE NULL END) AS so_count
		,COUNT(CASE WHEN year = 'JR' THEN 1 ELSE NULL END) AS jr_count
		,COUNT(CASE WHEN year = 'SR' THEN 1 ELSE NULL END) AS sr_count
	FROM benn.college_football_players
  
  
-- 别名
SELECT 	players.school_name
		,players.player_name
		,players.position
		,players.weight
	FROM benn.college_football_players players
	WHERE players.state = 'GA'
	ORDER BY players.weight DESC


-- JOIN 和 Subqueries
(
SELECT   b_table.btime AS btime
        ,b_table.bid AS bid
        ,o_table.oid AS oid
        ,b_table.fee AS fee
      
    FROM ( 
        SELECT   CAST(bubble_time AS TIMESTAMP) AS btime
                ,bid AS bid
                ,fee AS fee
            FROM ku.biao 
            WHERE CONCAT_WS('-',year,month,day) = '2017-03-10'
    ) btable

    -- 去除一天冒泡 50 次的 pid
    INNER JOIN (
        SELECT  pid
                ,COUNT(DISTINCT cbid) as cnt
            FROM ku.biao 
            WHERE CONCAT_WS('-',year,month,day) = '2017-03-10'
            GROUP BY pid
            HAVING cnt < 50
    ) filter
    ON btable.pid = filter.pid

    -- 通过 connecter 为冒泡添加 oid
    LEFT JOIN(
        SELECT   param['oid'] as oid
                ,param['bid'] as bid
        FROM ku.biao 	
        WHERE CONCAT_WS('-',year,month,day) = '2017-03-10'
    ) connecter
    ON btable.bid = connecter.bid

    -- 添加 otable
    LEFT JOIN (
        SELECT *
        FROM ku.biao 
        WHERE CONCAT_WS('-',year,month,day) = '2017-03-10'
    ) otable
    ON connecter.order_id = otable.oid
)

-- UNION
SELECT *
    FROM tutorial.crunchbase_investments_part1
    
UNION ALL

SELECT *
    FROM tutorial.crunchbase_investments_part2  

 /* ******************************************************************************************************************************************** */
 /* ***************************************************************** 高级 ********************************************************************* */
 /* ******************************************************************************************************************************************** */
 
 
------------------
---- 数据类型 ----
------------------
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
| Imported as	|			Stored as			|	With these rules																	|
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
|    String		|		  VARCHAR(1024)			|	Any characters, with a maximum field length of 1024 characters.						|
|  Date/Time	|			TIMESTAMP			|	Stores year, month, day, hour, minute and second values as YYYY-MM-DD hh:mm:ss.		|
|    Number		|		DOUBLE PRECISION		|	Numerical, with up to 17 significant digits decimal precision.						|
|   Boolean		|			BOOLEAN				|	Only TRUE or FALSE values.															|
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- 其中 “Imported as” 表示在SQL中输入的数据类型； “Stored as” 表示SQL官方的与前面相对应的数据类型；
-- 数据类型转换
SELECT  CAST(funding_total_usd AS VARCHAR) AS funding_total_usd_string      -- 方法 1
        ,founded_at_clean::VARCHAR AS founded_at_string                     -- 方法 2
    FROM tutorial.crunchbase_companies_clean_date
  


--------------------------------------------------------------------------------------------------------------------
---- 时间有关 ： 时间操作;  NOW()(及其他获取当时时间的方法);  EXTRACT(提取年/月/日...);  DATE_TRUNC(设置精度);  ----
--------------------------------------------------------------------------------------------------------------------

SELECT 	companies.founded_at_clean
		,acquisitions.acquired_at_cleaned
		-- 这里 INTERVAL 表示一段时间间隔，后面可直接接英语表达式
		,INTERVAL '10 days 999 secs' AS test_interval,	
		-- DATE 相减， 返回整数，表示天数
		,acquisitions.acquired_at_cleaned::DATE - companies.founded_at_clean::DATE AS date_to_acquisition,	
		-- TIME 相减， 返回 INTERVAL 形式
		,(acquisitions.acquired_at_cleaned::TIME + INTERVAL '100 secs') - acquisitions.acquired_at_cleaned::TIME AS date_to_acquisition
		-- TIMESTAMP 相减， 返回 INTERVAL 形式	
		,acquisitions.acquired_at_cleaned::TIMESTAMP - companies.founded_at_clean::TIMESTAMP AS time_to_acquisition		
	FROM tutorial.crunchbase_companies_clean_date companies
	JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
	ON acquisitions.company_permalink = companies.permalink
	WHERE founded_at_clean IS NOT NULL

-- 获取当前时间时，不需要依赖与 FROM （该时间是世界协调时间，中国在东八区，所以应该再加上 8 hours）
SELECT 	CURRENT_DATE AS date
		,CURRENT_TIME AS time
		,CURRENT_TIMESTAMP AS timestamp
		,LOCALTIME AS localtime
		,LOCALTIMESTAMP AS localtimestamp
		,NOW() AS now
    
-- 截取 TIMESTAMP 中的一部分
SELECT 	cleaned_date
		,EXTRACT('year'   FROM cleaned_date) AS year		-- 返回年份				整数
		,EXTRACT('month'  FROM cleaned_date) AS month		-- 返回月份				整数
		,EXTRACT('day'    FROM cleaned_date) AS day			-- 返回当月第几天		整数
		,EXTRACT('hour'   FROM cleaned_date) AS hour		-- 返回小时				整数
		,EXTRACT('minute' FROM cleaned_date) AS minute		-- 返回分钟				整数
		,EXTRACT('second' FROM cleaned_date) AS second		-- 返回秒数				小数
		,EXTRACT('decade' FROM cleaned_date) AS decade		-- 返回年份前三位数		整数
		,EXTRACT('dow'    FROM cleaned_date) AS day_of_week	-- 返回星期几			整数
	FROM tutorial.sf_crime_incidents_cleandate
  
-- 将 TIMESTAMP 精确到指定精度
SELECT 	cleaned_date,
		,DATE_TRUNC('year'   , cleaned_date) AS year		-- 精确到年：	xxxx-01-01 00:00:00
		,DATE_TRUNC('month'  , cleaned_date) AS month		-- 精确到月：	xxxx-xx-01 00:00:00
		,DATE_TRUNC('week'   , cleaned_date) AS week		-- 精确到周：	xxxx-xx-xx 00:00:00
		,DATE_TRUNC('day'    , cleaned_date) AS day			-- 精确到天： 	xxxx-xx-xx 00:00:00
		,DATE_TRUNC('hour'   , cleaned_date) AS hour		-- 精确到时: 	xxxx-xx-xx xx:00:00
		,DATE_TRUNC('minute' , cleaned_date) AS minute		-- 精确到分：	xxxx-xx-xx xx:xx:00
		,DATE_TRUNC('second' , cleaned_date) AS second		-- 精确到秒：	xxxx-xx-xx xx:xx:xx
		,DATE_TRUNC('decade' , cleaned_date) AS decade		-- 精确到十年：	xxx0-01-01 00:00:00
	FROM tutorial.sf_crime_incidents_cleandate				-- 注意 DATE_TRUNC 返回形式是 TIMESTAMP
  

  
--------------------------------------------------------------------------------------------------
---- String Functions (LEFT; RIGHT; SUBSTR; TRIM; POSITION; CONCAT/||; UPPER/LOWER; COALESCE  ----
--------------------------------------------------------------------------------------------------
SELECT 	incidnt_num
		,date
		,LEFT(date, 10) AS cleaned_date						-- 返回某变量最左边起的 n 个字符
		,RIGHT(date, LENGTH(date) - 11) AS cleaned_time		-- 返回某变量最右边起的 n 个字符
		,SUBSTR(date, 4, 2) AS day							-- 返回某变量从 某字符起的 n个字符
		
		-- 参数： 1. leading/trailing/both 指定从 左/右/两边 删除字符； 2. '' 内的任何字符否会被去除； 3. FROM 指定需要修剪的列名
		,TRIM(both '0+M ' FROM date) AS test_1				-- 剔除特定字符后的剩余字符
		
		,POSITION('A' IN date) AS a_position_1				-- POSITION and STRPOS 都用来返回某个字符的首次出现位置
		,STRPOS(date, 'A') AS a_position_2 					-- POSITION and STRPOS 都用来返回某个字符的首次出现位置
		
		,CONCAT(incidnt_num, ' in date of: ', date) AS concat_1		-- CONCAT 只是把字符串拼接在一起
		,incidnt_num || ' in date of: ' || date AS concat_2			-- 也可以通过 || 操作符进行拼接
		
		,LOWER(date) AS lowered								-- 字母小写化
		,UPPER(date) AS uppered								-- 字母大写化
	FROM tutorial.sf_crime_incidents_2014_01

SELECT 	incidnt_num,
		descript,
		COALESCE(descript, 'No Description')             	-- COALESCE 用来填补空值
	FROM tutorial.sf_crime_incidents_cleandate
	ORDER BY descript DESC 	
    
	
------------------------------------------------------------------------------
---- Subqueries
------------------------------------------------------------------------------
(
-- 一般需要二级操作中，两个操作不同，且 groupby 的分组变量不同，则需要 Subqueries
SELECT 	LEFT(sub.date, 2) AS cleaned_month,
		sub.day_of_week,
		AVG(sub.incidents) AS average_incidents
	FROM(													-- Subqueries 直接用 FROM 连接
        SELECT day_of_week,
			date,
			COUNT(incidnt_num) AS incidents
			FROM tutorial.sf_crime_incidents_2014_01
			GROUP BY 1,2
		) sub
	GROUP BY 1,2
	ORDER BY 1,2

	
SELECT *
	FROM tutorial.sf_crime_incidents_2014_01
	WHERE date IN (
		SELECT date									-- Subqueries 用 WHERE 连接
			FROM tutorial.sf_crime_incidents_2014_01
			ORDER BY date
			LIMIT 5
		)


SELECT incidents.*,
       sub.count AS total_incidents_in_category
  FROM tutorial.sf_crime_incidents_2014_01 incidents
  JOIN (													-- Subqueries 用 JOIN 连接
        SELECT category,
               COUNT(*) AS count
          FROM tutorial.sf_crime_incidents_2014_01
         GROUP BY 1
         ORDER BY 2
         LIMIT 3
       ) sub
    ON sub.category = incidents.category


SELECT COALESCE(acquisitions.month, investments.month) AS month,				----  Subqueries 后面的 FROM 和 JOIN 分别包含一个 子查询
       acquisitions.companies_acquired,
       investments.companies_rec_investment
  FROM (
        SELECT acquired_month AS month,
               COUNT(DISTINCT company_permalink) AS companies_acquired
          FROM tutorial.crunchbase_acquisitions
         GROUP BY 1
       ) acquisitions

  FULL JOIN (
        SELECT funded_month AS month,
               COUNT(DISTINCT company_permalink) AS companies_rec_investment
          FROM tutorial.crunchbase_investments
         GROUP BY 1
       )investments

    ON acquisitions.month = investments.month
 ORDER BY 1 DESC


SELECT investor_name,									-- 也可以与 UNION 结合起来
       COUNT(*) AS sum_raise
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
       ) sub
  GROUP BY 1
  ORDER BY 2 DESC
)



------------------------------------------------------------------------------
---- 窗口函数
------------------------------------------------------------------------------
SELECT depname, empno, salary, avg(salary) OVER (PARTITION BY depname) FROM empsalary;

  depname  | empno | salary |          avg          
- - - - - -| - - - |- - - - |- - - - - - - - - - - -
 develop   |    11 |   5200 | 5020.0000000000000000
 develop   |     7 |   4200 | 5020.0000000000000000
 develop   |     9 |   4500 | 5020.0000000000000000
 develop   |     8 |   6000 | 5020.0000000000000000
 develop   |    10 |   5200 | 5020.0000000000000000
 personnel |     5 |   3500 | 3700.0000000000000000
 personnel |     2 |   3900 | 3700.0000000000000000
 sales     |     3 |   4800 | 4866.6666666666666667
 sales     |     1 |   5000 | 4866.6666666666666667
 sales     |     4 |   4800 | 4866.6666666666666667
(10 rows)


SELECT depname, empno, salary, rank() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;

  depname  | empno | salary | rank 
- - - - - -| - - - |- - - - |- - - - - 
 develop   |     8 |   6000 |    1
 develop   |    10 |   5200 |    2
 develop   |    11 |   5200 |    2
 develop   |     9 |   4500 |    4
 develop   |     7 |   4200 |    5
 personnel |     2 |   3900 |    1
 personnel |     5 |   3500 |    2
 sales     |     1 |   5000 |    1
 sales     |     4 |   4800 |    2
 sales     |     3 |   4800 |    2
(10 rows)


SELECT salary, sum(salary) OVER () FROM empsalary;

 salary |  sum  
- - - - |- - - - -
   5200 | 47100
   5000 | 47100
   3500 | 47100
   4800 | 47100
   3900 | 47100
   4200 | 47100
   4500 | 47100
   4800 | 47100
   6000 | 47100
   5200 | 47100
(10 rows)


SELECT salary, sum(salary) OVER (ORDER BY salary) FROM empsalary;

 salary |  sum  
- - - - |- - - - -
   3500 |  3500
   3900 |  7400
   4200 | 11600
   4500 | 16100
   4800 | 25700
   4800 | 25700
   5000 | 30700
   5200 | 41100
   5200 | 41100
   6000 | 47100
(10 rows)

-- 这两条命令可以看出，窗口函数和 group by 的区别
-- group by： 先按照 指定变量 进行分组， 然后在组内对其余变量进行聚合，每组每个聚合函数都聚合出一个值，最后每条数据是一个组的数据
-- 窗口函数： 先对指定变量进行聚合（如果聚合时要考虑某种分组，则用 PARTITION 参数），然后对其余变量进行分组，分组完成后，每条数据后面拼接一个聚合之后的数值
SELECT  RIDER_TYPE
        ,AVG(DURATION_SECONDS) OVER() AS "OVER"
    FROM tutorial.dc_bikeshare_q1_2012
  
SELECT  RIDER_TYPE
        ,AVG(DURATION_SECONDS)
    FROM tutorial.dc_bikeshare_q1_2012
    GROUP BY 1



SELECT start_terminal
        ,duration_seconds
        ,SUM(duration_seconds) OVER												-- 后面如果跟着 order 表示累积，否则表示直接相加（不仅适用于SUM，也适用于COUNT, RANK等）
            (PARTITION BY start_terminal ORDER BY start_time)
            AS running_total
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'



SELECT  start_terminal
        ,duration_seconds
        ,SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_total
        ,(duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal))*100 as percentages
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
    ORDER BY 1, 4 DESC


SELECT END_TERMINAL
        ,DURATION_SECONDS
        ,SUM(DURATION_SECONDS) OVER (PARTITION BY END_TERMINAL ORDER BY DURATION_SECONDS DESC) AS RESULT
    FROM Tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
 
 
SELECT  start_terminal											    -- ROW_NUMBER() 仅仅是显示行号而已，如果分组，就是组内行号
        ,start_time
        ,duration_seconds
        ,ROW_NUMBER() OVER (PARTITION BY start_terminal
                            ORDER BY start_time)
                        AS row_number
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
 
 
SELECT  start_terminal												-- RANK() 表示排序结果，与row_number函数不同的是，rank函数考虑到了over子句中排序字段值相同的情况
        ,duration_seconds											-- DENSE_RANK() 表示在排名是，多条重复的只算作一条，接下来紧接着进行排名
        ,RANK() OVER (PARTITION BY start_terminal
                        ORDER BY start_time)
                AS rank
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'

 
SELECT start_terminal
        ,duration_seconds
        ,NTILE(4) OVER												-- NTILE(k) 可以对排序进行分组处理，分成k组，然后标号分别从 1 到 k
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS quartile
        ,NTILE(5) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS quintile
        ,NTILE(100) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS percentile
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
    ORDER BY start_terminal, duration_seconds
 
 
 
 
 -- LAG and LEAD
SELECT  start_terminal
        ,duration_seconds
        ,LAG(duration_seconds, 1) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds) AS lag
        ,LEAD(duration_seconds, 1) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds) AS lead
        ,duration_seconds -LAG(duration_seconds, 1) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds) AS difference
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
    ORDER BY start_terminal, duration_seconds
  
  
SELECT *						-- 用 Subqueries 去除含空的行
    FROM (
        SELECT start_terminal
            ,duration_seconds
            ,duration_seconds -LAG(duration_seconds, 1) OVER
                (PARTITION BY start_terminal ORDER BY duration_seconds)
                AS difference
        FROM tutorial.dc_bikeshare_q1_2012
        WHERE start_time < '2012-01-08'
        ORDER BY start_terminal, duration_seconds
        ) sub
    WHERE sub.difference IS NOT NULL
 
 
 -- 窗口别名
SELECT start_terminal
        ,duration_seconds
        ,NTILE(4) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS quartile
        ,NTILE(5) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS quintile
        ,NTILE(100) OVER
            (PARTITION BY start_terminal ORDER BY duration_seconds)
            AS percentile
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
    ORDER BY start_terminal, duration_seconds
 
-- 可以写成：
SELECT start_terminal
        ,duration_seconds
        ,NTILE(4) OVER ntile_window AS quartile
        ,NTILE(5) OVER ntile_window AS quintile
        ,NTILE(100) OVER ntile_window AS percentile
    FROM tutorial.dc_bikeshare_q1_2012
    WHERE start_time < '2012-01-08'
    WINDOW ntile_window AS
            (PARTITION BY start_terminal ORDER BY duration_seconds)
    ORDER BY start_terminal, duration_seconds
 
 
 
 -------------------------------------------------------------------
 -----   调优   
 -------------------------------------------------------------------
 
--1. 数据集大小
--   通过时间窗口 或 子查询+LIMIT
--2. 尽量少用 join ，如果一定要用，可以考虑在 join 之前先缩小每个表的大小
--3. 最开头加上 EXPLAIN ，可以得到预计的计算量


