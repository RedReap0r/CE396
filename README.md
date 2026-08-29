# Workshop 2 — ใจดีคลินิกรักษาสัตว์

## ส่วนที่ 2 — ตารางอธิบายชนิดของแอตทริบิวต์ (Data Dictionary)

อธิบายการวิเคราะห์ชนิดของแอตทริบิวต์ (Simple / Composite / Multivalued / Derived / Key) และการเลือกใช้ชนิดข้อมูล PostgreSQL พร้อมเหตุผลประกอบตามกฎธุรกิจ

| ชื่อแอตทริบิวต์ | ตารางที่สังกัด | ชนิดของแอตทริบิวต์ (Attribute Type) | ชนิดข้อมูล PostgreSQL | เหตุผลประกอบการออกแบบและเลือกใช้ |
| :--- | :--- | :--- | :--- | :--- |
| **pet_id** | Pet | Key Attribute (Primary Key) | `SERIAL` | ใช้เป็นรหัสระบุตัวตนของสัตว์เลี้ยงที่ไม่ซ้ำกัน โดยเลือกใช้ `SERIAL` เพื่อให้ระบบฐานข้อมูลทำการรันลำดับตัวเลข (Auto-increment) ให้โดยอัตโนมัติ |
| **subdistrict**, **district**, **province** | Owner | Composite Attribute | `VARCHAR(100)` | แตกข้อมูลที่อยู่ออกเป็นแอตทริบิวต์ย่อย (แขวง, เขต, จังหวัด) เพื่อให้สามารถสืบค้นและทำรายงานสรุปข้อมูลแยกตามรายเขตได้ตามที่กฎธุรกิจระบุ |
| **phone_number** | Owner_phone | Multivalued Attribute | `VARCHAR(15)` | เจ้าของ 1 คนสามารถมีเบอร์โทรได้หลายเบอร์ จึงแยกสร้างเป็นตารางใหม่เพื่อบันทึกข้อมูลเป็นรายบรรทัด ป้องกันการผิดกฎและหลีกเลี่ยงการเก็บค่าหลายค่าด้วยเครื่องหมายจุลภาคในคอลัมน์เดียว |
| **birth_date** | Pet | Simple Attribute | `DATE` | ใช้เก็บข้อมูลวันเกิดของสัตว์เลี้ยงที่เป็นค่าเดี่ยว เพื่อนำไปใช้อ้างอิงเป็นฐานข้อมูลตั้งต้นสำหรับการคำนวณอายุ (Age) ของสัตว์เลี้ยงในระบบ |
| **age** | *(ไม่มีในตาราง)* | Derived Attribute | *(ไม่มี)* | เป็นข้อมูลที่ได้จากการคำนวณโดยนำ `birth_date` มาเทียบกับวันปัจจุบัน จึงไม่ออกแบบให้เป็นคอลัมน์ในฐานข้อมูล เพื่อป้องกันปัญหาข้อมูลไม่อัปเดตเมื่อเวลาผ่านไป |
| **visit_no** | Visit | Partial Key | `INTEGER` | ทำหน้าที่เป็นคีย์บางส่วนใน Weak Entity โดยใช้ร่วมกับ `pet_id` เพื่อนับลำดับการเข้ารับบริการของสัตว์แต่ละตัวเป็นครั้งที่ 1, 2, 3... ตามที่ระบบต้องการ |
| **billed_price** | Prescription | Simple Attribute | `NUMERIC(10, 2)` | ใช้เก็บบันทึกราคายาคงที่ ณ เวลาที่ทำการออกใบเสร็จ เพื่อบังคับให้ยอดเงินในประวัติการรักษาไม่เปลี่ยนแปลงย้อนหลัง หากราคายาปัจจุบันในตาราง Medicine ถูกปรับเปลี่ยน |

## Diagram and ERD

```mermaid
erDiagram
    %% กำหนดความสัมพันธ์ (Relationships)
    Owner ||--o{ Owner_phone : "has_phone"
    Owner ||--|{ Pet : "owns"
    Pet ||--o{ Visit : "makes (Weak)"
    Vet ||--o{ Visit : "examines"
    Vet ||--o{ Vet_specialty : "has_specialty"
    Visit ||--o{ Prescription : "includes"
    Medicine ||--o{ Prescription : "used_in"

    %% กำหนดตารางและแอตทริบิวต์
    Owner {
        int owner_id PK
        varchar first_name
        varchar last_name
        varchar subdistrict
        varchar district
        varchar province
    }
    
    Owner_phone {
        int phone_id PK
        int owner_id FK
        varchar phone_number
    }
    
    Pet {
        int pet_id PK
        varchar name
        varchar species
        date birth_date
        int owner_id FK
    }
    
    Vet {
        int vet_id PK
        varchar name
    }
    
    Vet_specialty {
        int specialty_id PK
        int vet_id FK
        varchar specialty
    }
    
    Visit {
        int pet_id PK,FK
        int visit_no PK "Partial Key"
        timestamp visit_date
        int vet_id FK
    }
    
    Medicine {
        int med_id PK
        varchar name
        decimal current_price
    }
    
    Prescription {
        int pet_id PK,FK
        int visit_no PK,FK
        int med_id PK,FK
        varchar dosage
        int days
        decimal billed_price
    }
