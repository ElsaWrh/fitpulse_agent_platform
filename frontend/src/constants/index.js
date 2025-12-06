/**
 * 全局常量定义
 */

// 性别
export const GENDER = {
  MALE: 'MALE',
  FEMALE: 'FEMALE',
  OTHER: 'OTHER'
}

export const GENDER_LABELS = {
  [GENDER.MALE]: '男',
  [GENDER.FEMALE]: '女',
  [GENDER.OTHER]: '其他'
}

// 活动水平
export const ACTIVITY_LEVEL = {
  SEDENTARY: 'SEDENTARY',           // 久坐
  LIGHT: 'LIGHT',                   // 轻度活动
  MODERATE: 'MODERATE',             // 中度活动
  ACTIVE: 'ACTIVE',                 // 重度活动
  VERY_ACTIVE: 'VERY_ACTIVE'        // 极重度活动
}

export const ACTIVITY_LEVEL_LABELS = {
  [ACTIVITY_LEVEL.SEDENTARY]: '久坐(几乎不运动)',
  [ACTIVITY_LEVEL.LIGHT]: '轻度活动(每周1-3次)',
  [ACTIVITY_LEVEL.MODERATE]: '中度活动(每周3-5次)',
  [ACTIVITY_LEVEL.ACTIVE]: '重度活动(每周6-7次)',
  [ACTIVITY_LEVEL.VERY_ACTIVE]: '极重度活动(每天2次)'
}

// 健康目标
export const HEALTH_GOAL = {
  LOSE_WEIGHT: 'LOSE_WEIGHT',       // 减重
  GAIN_WEIGHT: 'GAIN_WEIGHT',       // 增重
  MAINTAIN: 'MAINTAIN',             // 保持
  BUILD_MUSCLE: 'BUILD_MUSCLE',     // 增肌
  IMPROVE_HEALTH: 'IMPROVE_HEALTH'  // 改善健康
}

export const HEALTH_GOAL_LABELS = {
  [HEALTH_GOAL.LOSE_WEIGHT]: '减重',
  [HEALTH_GOAL.GAIN_WEIGHT]: '增重',
  [HEALTH_GOAL.MAINTAIN]: '保持体重',
  [HEALTH_GOAL.BUILD_MUSCLE]: '增肌',
  [HEALTH_GOAL.IMPROVE_HEALTH]: '改善健康'
}

// 运动类型
export const WORKOUT_TYPE = {
  CARDIO: 'CARDIO',           // 有氧
  STRENGTH: 'STRENGTH',       // 力量
  FLEXIBILITY: 'FLEXIBILITY', // 柔韧性
  BALANCE: 'BALANCE',         // 平衡性
  SPORTS: 'SPORTS'            // 运动项目
}

export const WORKOUT_TYPE_LABELS = {
  [WORKOUT_TYPE.CARDIO]: '有氧运动',
  [WORKOUT_TYPE.STRENGTH]: '力量训练',
  [WORKOUT_TYPE.FLEXIBILITY]: '柔韧性训练',
  [WORKOUT_TYPE.BALANCE]: '平衡性训练',
  [WORKOUT_TYPE.SPORTS]: '运动项目'
}

// 睡眠质量
export const SLEEP_QUALITY = {
  POOR: 'POOR',
  FAIR: 'FAIR',
  GOOD: 'GOOD',
  EXCELLENT: 'EXCELLENT'
}

export const SLEEP_QUALITY_LABELS = {
  [SLEEP_QUALITY.POOR]: '差',
  [SLEEP_QUALITY.FAIR]: '一般',
  [SLEEP_QUALITY.GOOD]: '良好',
  [SLEEP_QUALITY.EXCELLENT]: '极好'
}

// 消息角色
export const MESSAGE_ROLE = {
  USER: 'USER',
  ASSISTANT: 'ASSISTANT'
}

// 分页默认值
export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_SIZE: 10,
  PAGE_SIZES: [10, 20, 50, 100]
}
