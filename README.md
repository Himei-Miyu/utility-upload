# Utility upload everywhere

### Syntax

-   USERNAME : ระบุชื่อ Github
-   EMAIL : ระบุเมลล์ Github
-   BRANCH : ระบุ branch
-   REPOSITORY : ระบุชื่อ repository
-   MESSAGE : กำหนด ข้อความ commit ต้องมีสัญลักษณ์ "" หรือ ฟันหนูคลุมข้อความเสมอในกรณีที่ต้องการใช้ข้อความเว้นวรรค เช่น "new update foo bar"

### Optional

-	-i , -init , --initial
-	-s , -sign , --signature

### Pattern

```bash
bash <(curl -fsSL https://himei.city/api/scripts/git-push) [OPTIONAL] USERNAME EMAIL BRANCH REPOSITORY MESSAGE
```

### Example

เมื่ออัพโหลด code ครั้งแรก หรือมีการเปลี่ยน branch หรือ repository

```bash
bash <(curl -fsSL https://himei.city/api/scripts/git-push) -init
```

อัพโหลดครั้งต่อไป ไม่จำเป็นต้องใส่ init ต่อท้าย

```bash
bash <(curl -fsSL https://himei.city/api/scripts/git-push) miyu miyu@example.com main example-repo "refactor code"
```
