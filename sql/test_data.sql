-- 测试数据脚本
-- 用于生成 FitPulse 平台的示例数据
-- 基于实际数据库表结构

-- 设置客户端字符集和连接字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_database = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_server = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;
SET collation_database = utf8mb4_unicode_ci;
SET collation_server = utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 0;

USE fitpulse_db;

-- ====================================
-- 1. 用户数据 (5个测试用户)
-- ====================================
-- 密码统一为: password123 (BCrypt加密后的hash)
INSERT INTO user (email, password_hash, nickname, avatar_url, gender, birthday, phone, created_at, updated_at) VALUES
('zhangsan@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z2EHCBZoVRLbdH3Qw1pJLxf6', '张三', 'https://i.pravatar.cc/150?img=1', 'MALE', '1990-05-15', '13800138001', NOW(), NOW()),
('lisi@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z2EHCBZoVRLbdH3Qw1pJLxf6', '李四', 'https://i.pravatar.cc/150?img=2', 'FEMALE', '1995-08-20', '13800138002', NOW(), NOW()),
('wangwu@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z2EHCBZoVRLbdH3Qw1pJLxf6', '王五', 'https://i.pravatar.cc/150?img=3', 'MALE', '1988-03-10', '13800138003', NOW(), NOW()),
('zhaoliu@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z2EHCBZoVRLbdH3Qw1pJLxf6', '赵六', 'https://i.pravatar.cc/150?img=4', 'FEMALE', '1992-11-25', '13800138004', NOW(), NOW()),
('sunqi@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z2EHCBZoVRLbdH3Qw1pJLxf6', '孙七', 'https://i.pravatar.cc/150?img=5', 'MALE', '1985-07-08', '13800138005', NOW(), NOW());

-- ====================================
-- 2. 健康档案数据
-- ====================================
INSERT INTO health_profile (user_id, height, current_weight, target_weight, bmi, fitness_level, weekly_workout_days, preferred_time, medical_conditions, family_history, exercise_restrictions, has_cardiovascular_risk, has_diabetes_risk, health_goal, created_at, updated_at) VALUES
(1, 175.0, 75.0, 70.0, 24.49, 'INTERMEDIATE', 4, 'MORNING', '无', '无', '无', 0, 0, '减重5kg,体脂率降到18%', NOW(), NOW()),
(2, 165.0, 58.0, 55.0, 21.30, 'BEGINNER', 3, 'EVENING', '轻度脂肪肝', '父亲有高血压', '无', 0, 0, '减重3kg,改善代谢健康', NOW(), NOW()),
(3, 180.0, 85.0, 95.0, 26.23, 'ADVANCED', 5, 'AFTERNOON', '无', '无', '无', 0, 0, '增肌10kg,提升力量', NOW(), NOW()),
(4, 160.0, 52.0, 52.0, 20.31, 'INTERMEDIATE', 4, 'MORNING', '无', '无', '无', 0, 0, '保持健康,提升柔韧性', NOW(), NOW()),
(5, 178.0, 90.0, 80.0, 28.41, 'BEGINNER', 2, 'EVENING', '高血压', '家族有糖尿病史', '避免高强度运动', 1, 1, '减重10kg,降血压', NOW(), NOW());

-- ====================================
-- 3. 体重记录数据 (最近30天)
-- ====================================
-- 张三的体重记录 (减重中)
INSERT INTO weight_log (user_id, record_date, weight, bmi, body_fat, notes, created_at) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 78.0, 25.47, 22.0, '开始减肥计划', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 77.5, 25.31, 21.8, NULL, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 77.0, 25.14, 21.5, NULL, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 76.5, 24.98, 21.2, NULL, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 76.0, 24.82, 21.0, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 75.5, 24.65, 20.8, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, CURDATE(), 75.0, 24.49, 20.5, '进展顺利', NOW());

-- 李四的体重记录
INSERT INTO weight_log (user_id, record_date, weight, bmi, body_fat, created_at) VALUES
(2, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 60.0, 22.04, 26.0, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(2, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 59.0, 21.67, 25.5, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(2, CURDATE(), 58.0, 21.30, 25.0, NOW());

-- 王五的体重记录 (增肌中)
INSERT INTO weight_log (user_id, record_date, weight, bmi, body_fat, notes, created_at) VALUES
(3, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 85.0, 26.23, 22.0, '开始增肌', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(3, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 86.5, 26.70, 21.5, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(3, CURDATE(), 88.0, 27.16, 21.0, '增重顺利', NOW());

-- ====================================
-- 4. 运动记录数据
-- ====================================
INSERT INTO workout_log (user_id, workout_date, workout_type, duration_minutes, calories_burned, intensity, status, notes, created_at) VALUES
-- 张三的运动记录
(1, CURDATE(), 'CARDIO', 30, 280, 'MODERATE', 'COMPLETED', '晨跑', NOW()),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'CARDIO', 30, 275, 'MODERATE', 'COMPLETED', '晨跑', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'STRENGTH', 45, 200, 'HIGH', 'COMPLETED', '上肢训练', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'CARDIO', 35, 300, 'MODERATE', 'COMPLETED', '晨跑', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'HIIT', 20, 250, 'HIGH', 'COMPLETED', 'HIIT训练', DATE_SUB(NOW(), INTERVAL 4 DAY)),

-- 王五的运动记录 (增肌训练)
(3, CURDATE(), 'STRENGTH', 60, 250, 'HIGH', 'COMPLETED', '胸肌训练', NOW()),
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'STRENGTH', 60, 240, 'HIGH', 'COMPLETED', '背部训练', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'STRENGTH', 60, 245, 'HIGH', 'COMPLETED', '腿部训练', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'CARDIO', 20, 150, 'MODERATE', 'COMPLETED', '有氧恢复', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'STRENGTH', 60, 240, 'HIGH', 'COMPLETED', '肩部训练', DATE_SUB(NOW(), INTERVAL 4 DAY)),

-- 赵六的运动记录 (瑜伽)
(4, CURDATE(), 'FLEXIBILITY', 60, 120, 'LOW', 'COMPLETED', '早晨瑜伽', NOW()),
(4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'FLEXIBILITY', 60, 115, 'LOW', 'COMPLETED', '晚间瑜伽', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(4, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'CARDIO', 45, 150, 'LOW', 'COMPLETED', '散步', DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- 孙七的运动记录
(5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'CARDIO', 25, 180, 'LOW', 'COMPLETED', '慢走', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(5, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'CARDIO', 20, 150, 'LOW', 'COMPLETED', '散步', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ====================================
-- 5. 睡眠记录数据
-- ====================================
INSERT INTO sleep_log (user_id, sleep_date, duration_minutes, sleep_quality, deep_sleep_minutes, notes, created_at) VALUES
-- 张三的睡眠记录
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 450, 4, 120, NULL, NOW()),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 420, 3, 108, '睡眠稍浅', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 480, 5, 150, '睡眠质量很好', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 390, 2, 90, '失眠', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 450, 4, 120, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY)),

-- 李四的睡眠记录
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 480, 5, 150, '睡眠很好', NOW()),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 450, 4, 132, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 465, 4, 140, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- 王五的睡眠记录
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 420, 4, 120, '训练后睡眠质量好', NOW()),
(3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 390, 3, 100, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- 孙七的睡眠记录
(5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 360, 2, 72, '睡眠不足', NOW()),
(5, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 390, 3, 90, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- ====================================
-- 6. 饮食记录数据
-- ====================================
INSERT INTO diet_log (user_id, meal_date, meal_type, calories, protein, carbs, fat, ai_analysis, risk_level, notes, created_at) VALUES
-- 张三今天的饮食
(1, CURDATE(), 'BREAKFAST', 380, 20, 45, 12, '营养均衡,蛋白质充足', 'GREEN', NULL, NOW()),
(1, CURDATE(), 'LUNCH', 550, 45, 60, 10, '高蛋白低脂,适合减脂', 'GREEN', NULL, NOW()),
(1, CURDATE(), 'DINNER', 420, 35, 25, 20, 'Omega-3脂肪酸丰富', 'GREEN', NULL, NOW()),
(1, CURDATE(), 'SNACK', 180, 5, 20, 10, '健康零食', 'GREEN', NULL, NOW()),

-- 李四今天的饮食 (低碳水)
(2, CURDATE(), 'BREAKFAST', 420, 25, 15, 30, '低碳水高脂,符合生酮饮食', 'GREEN', NULL, NOW()),
(2, CURDATE(), 'LUNCH', 380, 40, 20, 15, '高蛋白,碳水适中', 'GREEN', NULL, NOW()),
(2, CURDATE(), 'DINNER', 480, 50, 10, 25, '优质蛋白,低碳水', 'GREEN', NULL, NOW()),

-- 王五今天的饮食 (高蛋白)
(3, CURDATE(), 'BREAKFAST', 520, 45, 50, 15, '高蛋白,适合增肌', 'GREEN', NULL, NOW()),
(3, CURDATE(), 'LUNCH', 720, 55, 80, 18, '热量充足,蛋白质丰富', 'GREEN', NULL, NOW()),
(3, CURDATE(), 'DINNER', 580, 50, 60, 10, '营养全面', 'GREEN', NULL, NOW()),
(3, CURDATE(), 'SNACK', 280, 20, 35, 8, '训练后加餐', 'GREEN', '训练后补充', NOW()),

-- 赵六今天的饮食 (素食)
(4, CURDATE(), 'BREAKFAST', 320, 15, 50, 8, '植物蛋白,纤维丰富', 'GREEN', NULL, NOW()),
(4, CURDATE(), 'LUNCH', 420, 25, 55, 12, '藜麦优质蛋白', 'GREEN', NULL, NOW()),
(4, CURDATE(), 'DINNER', 350, 15, 60, 8, '低脂高纤', 'GREEN', NULL, NOW()),

-- 孙七的饮食 (需要改进)
(5, CURDATE(), 'BREAKFAST', 450, 12, 65, 15, '碳水过高,蛋白不足', 'YELLOW', NULL, NOW()),
(5, CURDATE(), 'LUNCH', 680, 20, 85, 25, '热量偏高,油脂较多', 'YELLOW', NULL, NOW()),
(5, CURDATE(), 'DINNER', 520, 18, 70, 18, '碳水偏高', 'YELLOW', NULL, NOW());

-- ====================================
-- 7. 更多智能体配置
-- ====================================
INSERT INTO agent (name, avatar_url, category, description, visibility, status, usage_count, created_at, updated_at) VALUES
('增肌教练', 'https://i.pravatar.cc/150?img=11', 'MUSCLE_COACH', '专注于力量训练和肌肉增长的专业教练,帮助你科学增肌', 'PUBLIC', 'APPROVED', 0, NOW(), NOW()),
('营养顾问', 'https://i.pravatar.cc/150?img=12', 'NUTRITION_ADVISOR', '提供个性化营养建议和饮食计划,优化你的饮食结构', 'PUBLIC', 'APPROVED', 0, NOW(), NOW()),
('睡眠专家', 'https://i.pravatar.cc/150?img=13', 'GENERAL', '帮助改善睡眠质量,解决睡眠问题', 'PUBLIC', 'APPROVED', 0, NOW(), NOW()),
('健身助手', 'https://i.pravatar.cc/150?img=14', 'GENERAL', '全方位健身指导,帮助你达成健康目标', 'PUBLIC', 'APPROVED', 0, NOW(), NOW());

-- 获取新增智能体的ID
SET @agent_muscle_id = LAST_INSERT_ID();
SET @agent_nutrition_id = @agent_muscle_id + 1;
SET @agent_sleep_id = @agent_muscle_id + 2;
SET @agent_fitness_id = @agent_muscle_id + 3;

-- 智能体配置
INSERT INTO agent_config (agent_id, system_prompt, language_style, can_read_profile, can_read_workouts, can_read_diet_logs, kb_scope, llm_model_id, llm_params, created_at, updated_at) VALUES
(@agent_muscle_id, '你是一位专业的增肌教练,精通力量训练和肌肉增长理论。请根据用户的身体数据和训练记录,提供科学的训练建议。', 'PROFESSIONAL', 1, 1, 1, '["fitness", "nutrition"]', 1, '{"temperature": 0.7, "max_tokens": 1000}', NOW(), NOW()),
(@agent_nutrition_id, '你是一位专业的营养师,精通营养学和饮食规划。请根据用户的健康目标和饮食偏好,提供个性化的营养建议。', 'PROFESSIONAL', 1, 0, 1, '["nutrition", "health"]', 1, '{"temperature": 0.7, "max_tokens": 1000}', NOW(), NOW()),
(@agent_sleep_id, '你是一位睡眠顾问,了解睡眠科学和改善睡眠的方法。请帮助用户分析睡眠数据,提供改善建议。', 'ENCOURAGING', 1, 0, 0, '["health", "sleep"]', 1, '{"temperature": 0.7, "max_tokens": 800}', NOW(), NOW()),
(@agent_fitness_id, '你是一位全能健身助手,可以帮助用户规划训练、饮食和生活方式。', 'CASUAL', 1, 1, 1, '["fitness", "nutrition", "health"]', 1, '{"temperature": 0.8, "max_tokens": 1000}', NOW(), NOW());

-- ====================================
-- 8. 对话记录数据
-- ====================================
-- 张三与减脂教练的对话 (agent_id = 1, 这是在 init.sql 中创建的默认智能体)
INSERT INTO conversation (user_id, agent_id, title, status, message_count, last_message_at, created_at, updated_at) VALUES
(1, 1, '减脂计划咨询', 'ACTIVE', 6, NOW(), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

SET @conversation_id_1 = LAST_INSERT_ID();

INSERT INTO message (conversation_id, role, content, llm_model_id, created_at) VALUES
(@conversation_id_1, 'user', '你好,我想制定一个减脂计划', 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@conversation_id_1, 'assistant', '你好!我看了你的健康档案,你目前体重75kg,目标是70kg。根据你的情况,我建议采用循序渐进的方式。首先,让我们从饮食和运动两方面入手。你目前的运动频率如何?', 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@conversation_id_1, 'user', '我现在每周跑步3-4次,每次30分钟左右', 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@conversation_id_1, 'assistant', '很好!你已经有不错的运动习惯。我建议:\n\n1. **有氧运动**: 保持目前的跑步频率,可以逐渐延长到40-45分钟\n2. **力量训练**: 每周增加2次力量训练,帮助提升代谢\n3. **饮食控制**: 创造每日300-500卡路里的热量缺口\n4. **饮水**: 每天至少2000ml水\n\n这样每周可以健康减重0.5-1kg。你觉得如何?', 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(@conversation_id_1, 'user', '听起来不错!具体的饮食应该怎么安排?', 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(@conversation_id_1, 'assistant', '根据你的情况,建议每日摄入:\n\n- **总热量**: 1800-2000卡路里\n- **蛋白质**: 120-140g (帮助保持肌肉)\n- **碳水化合物**: 180-200g (优先选择复合碳水)\n- **脂肪**: 50-60g (健康脂肪为主)\n\n**三餐分配**:\n- 早餐: 30% (高蛋白)\n- 午餐: 40% (均衡)\n- 晚餐: 30% (低碳水)\n\n避免加工食品和高糖饮料。需要我给你一个详细的一周食谱吗?', 1, DATE_SUB(NOW(), INTERVAL 4 DAY));

-- 李四与营养顾问的对话
INSERT INTO conversation (user_id, agent_id, title, status, message_count, last_message_at, created_at, updated_at) VALUES
(2, @agent_nutrition_id, '低碳饮食咨询', 'ACTIVE', 2, NOW(), DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

SET @conversation_id_2 = LAST_INSERT_ID();

INSERT INTO message (conversation_id, role, content, llm_model_id, created_at) VALUES
(@conversation_id_2, 'user', '我想尝试低碳水饮食,应该注意什么?', 1, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(@conversation_id_2, 'assistant', '你好!低碳水饮食确实是一个有效的减脂方式。我注意到你有轻度脂肪肝,低碳饮食对改善这个情况很有帮助。\n\n**低碳饮食要点**:\n1. **碳水控制**: 每日50-100g (约占总热量的20-30%)\n2. **蛋白质**: 增加到体重的1.5-2倍 (g)\n3. **脂肪**: 适量增加健康脂肪\n4. **蔬菜**: 大量绿叶蔬菜\n\n**注意事项**:\n- 避免精制碳水\n- 多喝水\n- 补充电解质\n- 循序渐进,避免突然改变\n\n你有什么特别想了解的吗?', 1, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 王五与增肌教练的对话
INSERT INTO conversation (user_id, agent_id, title, status, message_count, last_message_at, created_at, updated_at) VALUES
(3, @agent_muscle_id, '增肌训练计划', 'ACTIVE', 2, NOW(), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

SET @conversation_id_3 = LAST_INSERT_ID();

INSERT INTO message (conversation_id, role, content, llm_model_id, created_at) VALUES
(@conversation_id_3, 'user', '我想增肌,目前训练强度够吗?', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@conversation_id_3, 'assistant', '从你的训练记录看,你的训练频率很好!每周保持高强度力量训练。为了更好的增肌效果,我建议:\n\n**训练计划** (5天分化):\n- 周一: 胸+三头\n- 周二: 背+二头\n- 周三: 休息/有氧\n- 周四: 肩+腹\n- 周五: 腿\n- 周六: 休息\n- 周日: 轻量有氧\n\n**关键点**:\n1. 每个部位8-12组\n2. 重量选择: 8-12RM\n3. 组间休息: 60-90秒\n4. 渐进超负荷\n\n你觉得这个计划合适吗?', 1, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- ====================================
-- 9. 健康计划数据
-- ====================================
INSERT INTO health_plan (user_id, agent_id, plan_type, start_date, end_date, duration_days, plan_config, status, created_at, updated_at) VALUES
(1, 1, 'FAT_LOSS', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 54 DAY), 84, '{"target_weight": 70, "target_body_fat": 18, "weekly_goal": 0.5, "daily_calories": 1900}', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),

(2, @agent_nutrition_id, 'FAT_LOSS', DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 76 DAY), 90, '{"daily_carbs": 80, "daily_protein": 100, "daily_fat": 60, "meal_timing": "intermittent_fasting"}', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW()),

(3, @agent_muscle_id, 'MUSCLE_GAIN', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 92 DAY), 112, '{"target_weight": 95, "target_muscle": 75, "weekly_goal": 0.3, "daily_calories": 3200}', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW()),

(4, @agent_sleep_id, 'MAINTENANCE', DATE_SUB(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 53 DAY), 60, '{"target_duration": 480, "target_quality": 5, "sleep_schedule": "22:00-06:00"}', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

SET FOREIGN_KEY_CHECKS = 1;

-- ====================================
-- 数据统计
-- ====================================
SELECT '✅ 测试数据导入完成!' as status;
SELECT '=====================================' as '';
SELECT CONCAT('用户: ', COUNT(*), ' 条') as summary FROM user;
SELECT CONCAT('健康档案: ', COUNT(*), ' 条') as summary FROM health_profile;
SELECT CONCAT('体重记录: ', COUNT(*), ' 条') as summary FROM weight_log;
SELECT CONCAT('运动记录: ', COUNT(*), ' 条') as summary FROM workout_log;
SELECT CONCAT('睡眠记录: ', COUNT(*), ' 条') as summary FROM sleep_log;
SELECT CONCAT('饮食记录: ', COUNT(*), ' 条') as summary FROM diet_log;
SELECT CONCAT('智能体: ', COUNT(*), ' 条') as summary FROM agent;
SELECT CONCAT('对话: ', COUNT(*), ' 条') as summary FROM conversation;
SELECT CONCAT('消息: ', COUNT(*), ' 条') as summary FROM message;
SELECT CONCAT('健康计划: ', COUNT(*), ' 条') as summary FROM health_plan;
SELECT '=====================================' as '';
