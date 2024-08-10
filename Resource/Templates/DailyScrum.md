---
tags:
  - "#daily-scrum"
sticker: emoji//1f33b
created: <% tp.file.creation_date('DD-MM-YYYY' + ' ' + 'HH:mm') %>
banner:
---
# <% moment(tp.file.title,'YYYY-MM-DD').format("dddd, DD MMMM YYYY") %>
<< [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').subtract(1, 'd').format('YYYY-MM-DD') %>|Yesterday]] | [[<% fileDate = moment(tp.file.title, 'YYYY-MM-DD').add(1, 'd').format('YYYY-MM-DD') %>|Tomorrow]] >>

> [!tip] Quote of the Day  
> > <% tp.web.daily_quote() %>

---

#  😀 Daily Quests
- [ ] read Medium Columns (fixed)

---

# 대전 청년 월세 지원
https://djhousing.or.kr/
https://www.bokjiro.go.kr/ssis-tbu/twataa/wlfareInfo/moveTWAT52011M.do?wlfareInfoId=WLF00005253