# My work

  

- [[#Global entries]]

- [[#Global Totals]]

- [[#By client - TG]]

- [[#Global by Client - TG]]

- [[#By month - April]]

- [[#Global by month - April]]

  

---

## Global entries

  

```dataview

TABLE WITHOUT ID

Client,

Date,

Start,

End,

Hours,

round(Hours * 30, 2) AS Revenue

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

```

  

#### Global Totals

  

```dataview

TABLE WITHOUT ID

round(sum(rows.Hours), 2) AS "Total Hours",

"**" + sum(map(rows.Hours, (r) => r * 30)) + "**" AS "Total Revenue"

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

GROUP BY abc

```

  

---

## By client - TG

  

```dataview

TABLE WITHOUT ID

Client,

Date,

Start,

End,

Hours,

round(Hours * 30, 2) AS Revenue

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

WHERE Client = "TG"

```

  

#### Global by Client - TG

  

```dataview

TABLE WITHOUT ID

round(sum(rows.Hours), 2) AS "Total Hours",

sum(map(rows.Hours, (r) => r * 30)) AS "Total Revenue"

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

WHERE Client = "TG"

GROUP BY abc

```

  

---

## By month - April

  

```dataview

TABLE WITHOUT ID

Client,

Date,

Start,

End,

Hours,

round(Hours * 30, 2) AS Revenue

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

WHERE date(Date).month = 4

```

  

#### Global by month - April

  

```dataview

TABLE WITHOUT ID

round(sum(rows.Hours), 2) AS "Total Hours",

sum(map(rows.Hours, (r) => r * 30)) AS "Total Revenue"

FROM "_work"

WHERE work

FLATTEN work AS W

FLATTEN split(W, " \| ")[0] AS Client

FLATTEN split(W, " \| ")[1] AS Date

FLATTEN split(W, " \| ")[2] AS Start

FLATTEN split(W, " \| ")[3] AS End

FLATTEN date(Date + "T" + End) AS Tend

FLATTEN date(Date + "T" + Start) AS Tstart

FLATTEN round((Tend - Tstart).hours, 2) AS Hours

WHERE date(Date).month = 4

GROUP BY abc

```

  

---