
-- ตามโจทย์ เลือกมา 3 ตาราง
-- 1. ตาราง Pet (เอนทิตีหลัก)
CREATE TABLE Pet (
    pet_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    pet_tag_code VARCHAR(20) UNIQUE NOT NULL, -- UNIQUE: รหัสป้ายห้อยคอต้องไม่ซ้ำกัน
    CONSTRAINT chk_birth_date CHECK (birth_date <= CURRENT_DATE) -- CHECK: วันเกิดต้องไม่ใช่อนาคต
);

-- 2. ตาราง Visit (เอนทิตีอ่อน - Weak Entity)
CREATE TABLE Visit (
    pet_id INT NOT NULL,
    visit_no INT NOT NULL,
    visit_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- DEFAULT: ใช้วันเวลาปัจจุบันหากไม่ระบุ
    vet_id INT NOT NULL,
    PRIMARY KEY (pet_id, visit_no), -- การใช้ Composite Key เป็นการแสดงความเป็น Weak Entity
    FOREIGN KEY (pet_id) REFERENCES Pet(pet_id) ON DELETE CASCADE,
    CONSTRAINT chk_visit_no CHECK (visit_no > 0) -- CHECK: ครั้งที่เข้ารับบริการต้องมากกว่า 0
);

-- 3. ตาราง Prescription (ตารางเชื่อม M:N และตอบโจทย์ยอดเงินใบเสร็จ)
CREATE TABLE Prescription (
    pet_id INT NOT NULL,
    visit_no INT NOT NULL,
    med_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    days INT NOT NULL,
    billed_price NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (pet_id, visit_no, med_id),
    FOREIGN KEY (pet_id, visit_no) REFERENCES Visit(pet_id, visit_no) ON DELETE CASCADE,
    CONSTRAINT chk_days CHECK (days > 0), -- CHECK: จำนวนวันจ่ายยาต้องมากกว่า 0
    CONSTRAINT chk_billed_price CHECK (billed_price >= 0) -- CHECK: ราคาต้องไม่ติดลบ
);

